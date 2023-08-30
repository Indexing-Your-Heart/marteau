//
//  DataSwizzler.swift
//  Created by Marquis Kurt on 12/1/22.
//  This file is part of Indexing Your Heart.
//
//  Indexing Your Heart is non-violent software: you can use, redistribute, and/or modify it under the terms of the
//  CNPLv7+ as found in the LICENSE file in the source code root directory or at
//  <https://git.pixie.town/thufie/npl-builder>.
//
//  Indexing Your Heart comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Algorithms
import Foundation

/// A structure that can swizzle data.
public struct DataSwizzler {
    var data: Data

    private var magicBytes: [UInt8] {
        Array("_swzl".utf8)
    }

    public init(data: Data) {
        self.data = data
    }

    public func swizzled(into chunks: Int, rotated rotations: Int) -> Data? {
        guard !data.isEmpty else { return nil }
        var transformedData = Data()
        transformedData.append(contentsOf: magicBytes)
        transformedData.append(contentsOf: [0, UInt8(chunks), 0, UInt8(rotations)])
        transformedData.append(contentsOf: Array(repeating: UInt8(0), count: 8))

        var dataByteArray = data.bytesArray
        dataByteArray.rotate(toStartAt: chunks * rotations)
        transformedData.append(contentsOf: dataByteArray)

        return transformedData
    }

    public func decoded() -> Data? {
        guard !data.isEmpty else { return nil }
        var dataByteArray = data.bytesArray

        // Check magic bytes match
        var internalMagicBytes = Data()
        internalMagicBytes.append(contentsOf: dataByteArray[...4])
        if internalMagicBytes.bytesArray != magicBytes {
            return nil
        }
        dataByteArray.removeFirst(6)

        // Get chunk and rotation data
        let offset = Int(dataByteArray.first ?? 0)
        dataByteArray.removeFirst(2)

        let chunks = Int(dataByteArray.first ?? 0)
        dataByteArray.removeFirst(9)

        // Unswizzle file data
        var unswizzledData = Data()
        dataByteArray.rotate(toStartAt: dataByteArray.endIndex - (chunks * offset))
        unswizzledData.append(contentsOf: dataByteArray)
        return unswizzledData
    }
}

