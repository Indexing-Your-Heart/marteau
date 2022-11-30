//
//  DialogicCommand.swift
//  Created by Marquis Kurt on 9/12/22.
//  This file is part of Indexing Your Heart.
//
//  Indexing Your Heart is non-violent software: you can use, redistribute, and/or modify it under the terms of the
//  CNPLv7+ as found in the LICENSE file in the source code root directory or at
//  <https://git.pixie.town/thufie/npl-builder>.
//
//  Indexing Your Heart comes with ABSOLUTELY NO WARRANTY, to the extent permitted by applicable law. See the CNPL for
//  details.

import ArgumentParser
import Foundation
import Logging
import Marteau

struct DialogicCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "dialogic",
        abstract: "Converts a formatted Markdown file into a Dialogic timeline JSON file."
    )
    static var logger = Logger(label: "dialogic")

    /// The path to the Markdown file to convert.
    @Argument(help: "The path to the Markdown file to convert.")
    var markdownFile: String

    /// The path to where the out JSON file should go.
    @Argument(help: "The path to where the output file should go.")
    var outputFile: String = "timeline.json"

    /// (Optional) The path to a directory of character definitions in Dialogic format.
    @Option(help: "The path to a directory of character definitions.")
    var characters: String?

    func validate() throws {
        guard markdownFile.hasSuffix(".md") else {
            throw ValidationError("Supplied file must be a Markdown (.md) file.")
        }
    }

    func run() throws {
        let markdownText: String = try FileUtilities.read(from: markdownFile, encoding: .utf8)
        let mdParser = MarkdownDialogicParser(from: markdownText)
        if let charpath = characters {
            let characterGlobs = try FileUtilities.readAll(from: charpath)
            mdParser.characterDefinitions = try characterGlobs
                .map { try JSONDecoder().decode(DialogicCharacter.self, from: $0) }
            Self.logger.debug("Character definitions added.")
        }
        let resultData = mdParser.compileToString()
        try FileUtilities.write(resultData, to: outputFile, encoding: .utf8)
        Self.logger.info("Dialogic file written to '\(outputFile)'.")
        Self.logger.warning("Remember to transplant the file into a Dialogic timeline file correctly.")
    }
}
