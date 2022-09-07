//
//  MarkdownDialogicParser.swift
//  Created by Marquis Kurt on 10/1/22.
//  This file is part of Indexing Your Heart.
//
//  Indexing Your Heart is non-violent software: you can use, redistribute, and/or modify it under the terms of the
//  CNPLv7+ as found in the LICENSE file in the source code root directory or at
//  <https://git.pixie.town/thufie/npl-builder>.
//
//  Indexing Your Heart comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.


import Foundation
import Markdown

public class MarkdownDialogicParser {
    public var source: String
    public var characterDefinitions: [DialogicCharacter] = []
    private var parser: InternalMarkdownParser

    public init(from source: String) {
        self.source = source
        self.parser = InternalMarkdownParser(from: source)
    }

    func updatePart(_ part: Speakable) -> Speakable {
        var speaker = part
        if let char = characterDefinitions.first(where: { $0.getAllNames().contains(speaker.who) }) {
            speaker.who = char.id
        }
        return speaker
    }

    func transform(events: [DialogueUnit]) -> [DialogicEvent] {
        var transformed = [DialogicEvent]()
        for event in events {
            if let dialogue = event as? Speakable {
                transformed.append(.dialogue(character: dialogue.who, text: dialogue.what))
            }
            if let question = event as? Question {
                let options = question.choices.flatMap { choice in
                    [
                        .choice(named: choice.choice)
                    ]
                    + transform(events: choice.dialogue)
                }
                transformed.append(.question(character: question.who, question: question.question))
                transformed.append(contentsOf: options)
                transformed.append(.endQuestion())
            }
        }
        return transformed
    }

    /// Returns a list of JSON-like objects from the source string into Dialogic-readable JSON.
    public func compile() -> [DialogicEvent] {
        var parts = parser.parse()
        if parts.isEmpty {
            return [DialogicEvent]()
        }

        if !characterDefinitions.isEmpty {
            parts = parts.map { part in
                if let dialogue = part as? Speakable {
                    let updatedPart = updatePart(dialogue)
                    return updatedPart as! DialogueUnit
                }

                if let question = part as? Question {
                    let newChoices: [Choice] = question.choices.map { choice in
                        let newDialog: [DialogueUnit] = choice.dialogue
                            .map { diag in updatePart(diag as! Speakable) as! DialogueUnit }
                        return Choice(choice: choice.choice, dialogue: newDialog)
                    }
                    return Question(who: question.who, question: question.question, choices: newChoices)
                }

                return part
            }
        }

        Marteau.Dialogue.logger.info("Compiled dialogue.")
        return transform(events: parts)
    }
}

extension MarkdownDialogicParser: DialogueParser {
    /// Returns a String that represents Dialogic-readable JSON of the parsed content.
    public func compileToString() -> String {
        let compilation: [DialogicEvent] = compile()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(compilation)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
