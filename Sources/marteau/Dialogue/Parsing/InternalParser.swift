//
//  InternalParser.swift
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
import Markdown

typealias Speech = DialogueUnit & Speakable

/// A parser used internally for various parsers.
class InternalMarkdownParser {
    let source: String

    init(from source: String) {
        self.source = source
    }

    public func parse() -> [DialogueUnit] {
        let mdDoc = Document(parsing: source)
        if mdDoc.isEmpty { return [DialogueUnit]() }
        var parts = [DialogueUnit]()

        for child in mdDoc.children {
            if let paragraph = child as? Paragraph {
                parts.append(contentsOf: parseParagraph(paragraph))
            } else if let quote = child as? BlockQuote {
                parts.append(parseBlockQuote(quote))
            } else if let question = child as? UnorderedList {
                if question.childCount != 1 { continue }
                parts.append(parseQuestion(question.child(at: 0)! as! ListItem))
            }
        }

        Marteau.Dialogue.logger.debug("Parsed \(parts.count) items.")
        return parts
    }

    /// Parses a block quote as a comment.
    private func parseBlockQuote(_ blockQuote: BlockQuote) -> Comment {
        var note = ""
        for child in blockQuote.children where child is Paragraph {
            for pChild in child.children where pChild is Text {
                note += (pChild as? Text)?.plainText ?? ""
            }
        }
        return Comment(note: note)
    }

    /// Parses a list item as a choice.
    private func parseChoice(_ choice: ListItem) -> Choice {
        let choiceName = choice.child(through: 0, 0) as! Text
        let choiceResults = choice.child(through: 1) as! UnorderedList
        var dialogues = [DialogueUnit]()

        for dialogue in choiceResults.children {
            if let dList = dialogue as? ListItem {
                for children in dList.children where children is Paragraph {
                    dialogues.append(contentsOf: parseParagraph(children as! Paragraph))
                }
            }
        }

        return Choice(choice: choiceName.plainText, dialogue: dialogues)
    }

    /// Parses a paragraph, extracting narration and dialogue elements as necessary.
    private func parseParagraph(_ paragraph: Paragraph) -> [DialogueUnit] {
        if paragraph.isEmpty { return [DialogueUnit]() }
        var dialogues = [DialogueUnit]()
        let diaRegex = #"([A-Za-z\?]+):\s*“([\w\.\!\?\s,;'‘’\-…\[\]]+)”+(\s+)?"#
        var patchEmphasis = false
        for child in paragraph.children {
            if let italics = child as? Emphasis {
                patchEmphasis = true
                guard let text = italics.child(at: 0) as? Text else {
                    continue
                }
                if let lastPart = dialogues.popLast() as? Speech {
                    dialogues.append(
                        lastPart.type == .narration
                            ? Narration(what: lastPart.what + "*\(text.plainText)*")
                            : Dialogue(who: lastPart.who, what: lastPart.what + "*\(text.plainText)*")
                    )
                } else {
                    dialogues.append(Narration(what: "*\(text.plainText)*"))
                }
                continue
            }

            if let line = child as? Text {
                var who = ""
                var what = ""
                if line.plainText.range(of: diaRegex, options: [.regularExpression]) == nil {
                    what = line.plainText
                } else {
                    let splitContents = line.plainText.components(separatedBy: ": ")
                    if splitContents.count != 2 { continue }
                    who = splitContents.first!
                    what = splitContents.last!
                }

                if patchEmphasis {
                    var didUpdate = false
                    if let oldElement = dialogues.popLast() as? Speech {
                        dialogues.append(
                            who
                                .isEmpty ? Narration(what: oldElement.what + what) :
                                Dialogue(who: who, what: oldElement.what + what)
                        )
                        didUpdate = true
                    }
                    patchEmphasis = false
                    if didUpdate {
                        continue
                    }
                }

                dialogues.append(
                    who.isEmpty ? Narration(what: what) : Dialogue(who: who, what: what)
                )
            }
        }
        return dialogues
    }

    /// Parses a list item as a question
    private func parseQuestion(_ question: ListItem) -> Question {
        let questionNameField = question.child(through: 0, 0) as! Text
        let choiceList = question.child(at: 1) as! UnorderedList
        let ques = questionNameField.plainText == "(Choice)" ? "" : questionNameField.plainText
        var choices = [Choice]()

        for choice in choiceList.children {
            if let choiceLI = choice as? ListItem {
                choices.append(parseChoice(choiceLI))
            }
        }

        return Question(question: ques, choices: choices)
    }
}
