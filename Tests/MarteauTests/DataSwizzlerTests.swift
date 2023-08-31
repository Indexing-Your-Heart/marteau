//
//  DataSwizzlerTests.swift
//  Created by Marquis Kurt on 12/1/22.
//  This file is part of Indexing Your Heart.
//
//  Indexing Your Heart is non-violent software: you can use, redistribute, and/or modify it under the terms of the
//  CNPLv7+ as found in the LICENSE file in the source code root directory or at
//  <https://git.pixie.town/thufie/npl-builder>.
//
//  Indexing Your Heart comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation
import XCTest
@testable import Marteau

private enum DataSwizzlerTestError: Error {
    case imageDataNotFound
}

final class DataSwizzlerTests: XCTestCase {
    var swizzler: DataSwizzler?

    var imageData: Data? {
        guard let path = Bundle.module.path(forResource: "SampleImage", ofType: "png") else { return nil }
        let url = URL(filePath: path)
        return try? Data(contentsOf: url)
    }

    var swizzleFileData: Data? {
        guard let path = Bundle.module.path(forResource: "SampleImage", ofType: "swizzle") else { return nil }
        let url = URL(filePath: path)
        return try? Data(contentsOf: url)
    }

    override func setUpWithError() throws {
        guard let imageData else { throw DataSwizzlerTestError.imageDataNotFound }
        self.swizzler = DataSwizzler(data: imageData)
    }

    override func tearDownWithError() throws {
        self.swizzler = nil
    }

    // NOTE: Only run this test to write a sample swizzle file.
//    func testSwizzleFileWrite() throws {
//        if let data = swizzler?.swizzled(into: 16, rotated: 8),
//           let path = Bundle.module.path(forResource: "SampleImage", ofType: "png")?
//            .replacingOccurrences(of: "png", with: "swizzle") {
//            try data.write(to: .init(filePath: path))
//        }
//    }

    func testMagicBytesAtFileHeader() throws {
        guard let swizzledData = swizzler?.swizzled(into: 16, rotated: 8) else {
            return XCTFail("No data was returned.")
        }

        let string = String(data: Data(swizzledData.bytesArray[...4]), encoding: .utf8)
        XCTAssertEqual(string, "_swzl")
    }

    func testSwizzleImplementation() throws {
        guard let swizzledData = swizzler?.swizzled(into: 16, rotated: 8) else {
            return XCTFail("No data was returned.")
        }
        XCTAssertEqual(swizzledData, swizzleFileData)
    }

    func testSwizzleDecoder() throws {
        guard let swizzleFileData else {
            return XCTFail("Swizzled file data is missing")
        }
        let swizzler = DataSwizzler(data: swizzleFileData)
        guard let decodedData = swizzler.decoded() else {
            return XCTFail("Decoder returned no data.")
        }
        XCTAssertEqual(decodedData, imageData)
    }
}
