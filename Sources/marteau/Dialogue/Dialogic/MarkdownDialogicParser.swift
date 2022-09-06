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

    /// Returns a list of JSON-like objects from the source string into Dialogic-readable JSON.
    public func compile() -> [JSONLike] {
        var compiled = [JSONLike]()
        var parts = parser.parse()
        if parts.isEmpty {
            return [JSONLike]()
        }

        // First-pass. Replace character names with their corresponding IDs, if there are definitions.
        if !characterDefinitions.isEmpty {
            func updatePart(_ part: Speakable) -> Dialogable {
                var speaker = part
                if let char = characterDefinitions.first(where: { $0.getAllNames().contains(speaker.who) }) {
                    speaker.who = char.id
                }
                return speaker as! Dialogable
            }

            parts = parts.map { part in
                if part is Speakable { return updatePart(part as! Speakable) }
                if part is Question {
                    let question = part as! Question
                    let newChoices: [Choice] = question.choices.map { choice in
                        let newDialog: [Dialogable] = choice.dialogue
                            .map { diag in updatePart(diag as! Speakable) }
                        return Choice(choice: choice.choice, dialogue: newDialog)
                    }
                    return Question(who: question.who, question: question.question, choices: newChoices)
                }
                return part
            }
        }

        // Second-pass.
        for part in parts {
            if part is Comment { continue }
            if part is JSONCollapsible {
                compiled.append(contentsOf: (part as! JSONCollapsible).flattenDialogicJSON())
                continue
            }
            compiled.append(part.toDialogicJSON())
        }

        print("[i] Compiled \(compiled.count) items.")
        return compiled
    }
}

extension MarkdownDialogicParser: DialogueParser {
    /// Returns a String that represents Dialogic-readable JSON of the parsed content.
    public func compileToString() -> String {
        let compilation: [JSONLike] = compile()
        var jsonResult = ""

        do {
            let json = try JSONSerialization.data(withJSONObject: compilation, options: .prettyPrinted)
            jsonResult = String(decoding: json, as: UTF8.self)
        } catch {
            print("Error: \(error.localizedDescription)")
            jsonResult = "[]"
        }

        return jsonResult
    }
}
