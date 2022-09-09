//
//  DialogicStructs.swift
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

public struct DialogicEvent: Codable {
    public let eventId: String
    public let character: String?
    public let portrait: String?
    public let text: String?
    public let question: String?
    public let choice: String?
    public let condition: String?
    public let definition: String?
    public let value: String?

    public static func eventId(for type: DialogueType) -> String {
        switch type {
        case .dialogue, .narration:
            return "dialogic_001"
        case .question:
            return "dialogic_010"
        case .choice:
            return "dialogic_011"
        case .comment:
            return ""
        }
    }

    public static func dialogue(character: String, text: String) -> DialogicEvent {
        .init(
            eventId: eventId(for: .dialogue),
            character: character,
            portrait: "",
            text: text,
            question: nil,
            choice: nil,
            condition: nil,
            definition: nil,
            value: nil
        )
    }

    public static func choice(named choiceName: String) -> DialogicEvent {
        .init(
            eventId: eventId(for: .choice),
            character: nil,
            portrait: nil,
            text: nil,
            question: nil,
            choice: choiceName,
            condition: "",
            definition: "",
            value: ""
        )
    }

    public static func question(character: String, question: String) -> DialogicEvent {
        .init(
            eventId: eventId(for: .dialogue),
            character: character,
            portrait: nil,
            text: nil,
            question: question,
            choice: nil,
            condition: nil,
            definition: nil,
            value: nil
        )
    }

    public static func endQuestion() -> DialogicEvent {
        .init(
            eventId: "dialogic_013",
            character: nil,
            portrait: nil,
            text: nil,
            question: nil,
            choice: nil,
            condition: nil,
            definition: nil,
            value: nil
        )
    }
}
