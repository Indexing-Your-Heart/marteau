//
//  Marteau.swift
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
import ArgumentParser
import FigSwiftArgumentParser
import JensonKit
import Logging

/// The main entry struct that holds all of the program commands.
@main
struct Marteau: ParsableCommand {
    /// An option group that creates a Fig autocomplete spec.
    @OptionGroup var generateFigSpec: GenerateFigSpec<Self>

    /// The logging facility for the program.
    static let logger = Logger(label: "marteau")

    /// The configuration for the main program.
    static let configuration = CommandConfiguration(
        abstract: "A set of utilities for Indexing Your Heart.",
        subcommands: [Dialogue.self]
    )

    /// The subcommand struct for dialogue conversion.
    struct Dialogue: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Converts a Markdown document into Dialogic JSON.")
        static var logger = Logger(label: "dialogue")

        /// The path to the Markdown file to convert.
        @Argument(help: "The path to the Markdown file to convert.")
        var markdownFile: String

        /// The path to where the out JSON file should go.
        @Argument(help: "The path to where the output JSON file should go.")
        var outputFile: String = "timeline.json"

        /// The export strategy.
        @Option(help: "The JSON format to use during export.")
        var format: String = "dialogic"

        /// (Optional) The path to a directory of character definitions in Dialogic format.
        @Option(help: "The path to a directory of character definitions.")
        var characters: String?

        @Flag(help: "Display debugging messages.")
        var debug = false

        @Flag(help: "Disable compression for Jenson files.")
        var disableCompression = false

        func validate() throws {
            guard markdownFile.hasSuffix(".md") else {
                throw ValidationError("Supplied file must be a Markdown (.md) file.")
            }
        }

        func run() throws {
            if debug { Self.logger.logLevel = .debug }
            let markdownText: String = try FileUtilities.read(from: markdownFile, encoding: .utf8)
            switch format {
            case "dialogic":
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
            case "jenson":
                let outPath = outputFile.replacingOccurrences(of: "json", with: "jenson")
                let jsParser = MarkdownJensonParser(from: markdownText)
                let resultData = jsParser.compileToFileObject()
                if debug {
                    Self.logger.info("Debugging enabled; creating a Jenson debug dump.")
                    let debugString = jsParser.transformCompilationToString(file: resultData)
                    try debugString.write(
                        toFile: outputFile.replacingOccurrences(of: ".json", with: ".debug.json"),
                        atomically: true, encoding: .utf8
                    )
                    Self.logger.debug("Debug Jenson file written.")
                }
                let writer = JensonWriter(contentsOf: resultData)
                Self.logger.debug("Jenson compression setting set to: \(String(!disableCompression).uppercased())")
                writer.compressed = !disableCompression
                try writer.write(to: outPath)
                Self.logger.info("Jenson file written to '\(outPath)'.")
            default:
                Self.logger.critical("Unknown format type \(format). Aborting.")
                return
            }
        }
    }
}
