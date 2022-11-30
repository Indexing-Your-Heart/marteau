//
//  JensonCommand.swift
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
import JensonKit
import Logging
import Marteau

struct JensonCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "jenson",
        abstract: "Converts a formatted Markdown file into a Jenson file."
    )
    static var logger = Logger(label: "jenson")

    /// The path to the Markdown file to convert.
    @Argument(help: "The path to the Markdown file to convert.")
    var markdownFile: String

    /// The path to where the out JSON file should go.
    @Argument(help: "The path to where the output Jenson file should go.")
    var outputFile: String = "compiled.jenson"

    @Option(help: "The author that wrote the file.")
    var author: String = ""

    @Option(help: "The name of the chapter this file represents.")
    var chapterName: String = ""

    @Option(help: "A custom copyright string to be included in the file.")
    var copyright: String = ""

    @Flag(help: "Display debugging messages.")
    var debug = false

    @Flag(help: "Disable compression for Jenson files.")
    var disableCompression = false

    func validate() throws {
        guard markdownFile.hasSuffix(".md") else {
            throw ValidationError("Supplied file must be a Markdown (.md) file.")
        }
        guard outputFile.hasSuffix(".jenson") else {
            throw ValidationError("Supplied output path must point to a Jenson file (.jenson).")
        }
    }

    func run() throws {
        if debug { Self.logger.logLevel = .debug }
        let markdownText: String = try FileUtilities.read(from: markdownFile, encoding: .utf8)
        let parser = MarkdownJensonParser(from: markdownText)
        let originalData = parser.compileToFileObject()
        let resultData = JensonFile(
            version: originalData.version,
            application: makeJensonApplication(),
            story: makeJensonStory(),
            timeline: originalData.timeline
        )
        if debug { try createDebuggingOutput(from: resultData, parser: parser) }
        let writer = JensonWriter(contentsOf: resultData)
        Self.logger.debug("Jenson compression setting set to: \(String(!disableCompression).uppercased())")
        writer.compressed = !disableCompression
        try writer.write(to: outputFile)
        Self.logger.info("Jenson file written to '\(outputFile)'.")
    }

    private func makeJensonApplication() -> JensonApp {
        .init(name: "Marteau", website: "https://github.com/Indexing-Your-Heart/marteau")
    }

    private func makeJensonStory() -> JensonStory {
        let date = Calendar.current.component(.year, from: .now)
        let defaultAuthor = "Marquis Kurt et. al. Indexing Your Heart authors"
        return JensonStory(
            name: "Indexing Your Heart",
            author: author.isEmpty ? defaultAuthor : author,
            chapter: chapterName.isEmpty ? nil : chapterName,
            copyright: copyright.isEmpty ? "(C) \(date) \(defaultAuthor). All rights reserved." : copyright
        )
    }

    private func createDebuggingOutput(from resultData: JensonFile, parser: MarkdownJensonParser) throws {
        Self.logger.info("Debugging enabled; creating a Jenson debug dump.")
        let debugString = parser.transformCompilationToString(file: resultData)
        try debugString.write(
            toFile: outputFile.replacingOccurrences(of: ".json", with: ".debug.json"),
            atomically: true, encoding: .utf8
        )
        Self.logger.debug("Debug Jenson file written.")
    }
}
