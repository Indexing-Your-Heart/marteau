//
//  JensonStructs.swift
//  Created by Marquis Kurt on 9/6/22.
//  This file is part of Indexing Your Heart.
//
//  Indexing Your Heart is non-violent software: you can use, redistribute, and/or modify it under the terms of the
//  CNPLv7+ as found in the LICENSE file in the source code root directory or at
//  <https://git.pixie.town/thufie/npl-builder>.
//
//  Indexing Your Heart comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import Foundation

public struct JensonEvent: Codable {
    public let type: DialogueType
    public let who: String
    public let what: String
    public let question: JensonQuestion?
}

public struct JensonChoice: Codable {
    public let name: String
    public let events: [JensonEvent]
}

public struct JensonQuestion: Codable {
    public let question: String
    public let options: [JensonChoice]
}

public struct JensonFile: Codable {
    public let version: Int
    public let timeline: [JensonEvent]
}
