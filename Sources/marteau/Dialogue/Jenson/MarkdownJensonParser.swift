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
import JensonKit

public class MarkdownJensonParser {
    public var source: String
    private var parser: InternalMarkdownParser

    public init(from source: String) {
        self.source = source
        parser = InternalMarkdownParser(from: source)
    }

    func transform(events: [DialogueUnit]) -> [JensonEvent] {
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

    public func compileToFileObject() -> JensonFile {
        let parts = transform(events: parser.parse())
        DialogueCommand.logger.info("Compiled Jenson timeline (\(parts.count) parts total). ")
        return JensonFile(version: 2, timeline: parts)
    }

    public func transformCompilationToString(file: JensonFile) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(file)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}

extension MarkdownJensonParser: DialogueParser {
    public func compileToString() -> String {
        transformCompilationToString(file: compileToFileObject())
    }
}
