//
//  Data+ByteArray.swift
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

extension Data {
    /// The array of bytes the data represents.
    var bytesArray: [UInt8] {
        var bytes = [UInt8]()
        bytes.append(contentsOf: self)
        return bytes
    }
}
