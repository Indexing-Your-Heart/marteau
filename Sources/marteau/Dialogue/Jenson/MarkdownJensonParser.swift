//
//  MarkdownJensonParser.swift
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

public class MarkdownJensonParser {
    public var source: String
    private var parser: InternalMarkdownParser

    public init(from source: String) {
        self.source = source
        self.parser = InternalMarkdownParser(from: source)
    }

    func transform(events: [Dialogable]) -> [JensonEvent] {
        var transformed = [JensonEvent]()
        for event in events {
            if let comment = event as? Comment {
                transformed.append(.init(type: .comment, who: "", what: comment.note, question: nil))
                continue
            }
            if let dialogue = event as? Speakable {
                transformed.append(.init(type: .dialogue, who: dialogue.who, what: dialogue.what, question: nil))
                continue
            }
            if let question = event as? Question {
                let options = question.choices.map { choice in
                    JensonChoice(name: choice.choice, events: transform(events: choice.dialogue))
                }
                let question = JensonQuestion(question: question.question, options: options)
                transformed.append(.init(type: .question, who: "", what: "", question: question))
                continue
            }
        }
        return transformed
    }

}

extension MarkdownJensonParser: DialogueParser {
    public func compileToString() -> String {
        let parts = transform(events: parser.parse())
        let fileContents = JensonFile(version: 1, timeline: parts)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(fileContents)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
