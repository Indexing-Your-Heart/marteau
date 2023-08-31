//
//  SwizzleCommand.swift
//  Created by Marquis Kurt on 8/31/23.
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

struct SwizzleCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swizzle",
        abstract: "Swizzles a given binary file for source code protection.")
    static var logger = Logger(label: "swizzler")

    @Argument(help: "The path to the file to swizzle.")
    var fileToSwizzle: String

    @Argument(help: "The path to where the swizzled file will be written.")
    var outputFile: String = "Data.swizzle"

    @Option(help: "The number of cycles to swizzle the data into.")
    var cycle = 8

    @Option(help: "The size of the chunks in the swizzled file.")
    var chunkSize = 16

    @Flag(help: "Display debugging messages.")
    var debug = false

    func validate() throws {
        let path = URL(fileURLWithPath: fileToSwizzle)
        guard path.isFileURL else {
            throw ValidationError("File path must be valid.")
        }
        guard outputFile.hasSuffix(".swizzle") else {
            throw ValidationError("Output file must be a swizzled file (.swizzle).")
        }
    }

    func run() throws {
        if debug { Self.logger.logLevel = .debug }
        guard let data = data() else {
            Self.logger.error("Failed to load file.")
            return
        }

        let swizzler = DataSwizzler(data: data)
        Self.logger.debug("Swizzling data (chunk size: \(chunkSize), cycles: \(cycle)).")
        guard let swizzled = swizzler.swizzled(into: chunkSize, rotated: cycle) else {
            Self.logger.error("Failed to swizzle data.")
            return
        }

        let outputPath = URL(fileURLWithPath: outputFile)
        do {
            try swizzled.write(to: outputPath)
            Self.logger.info("Wrote swizzled data to \(outputFile))")
        } catch {
            Self.logger.error("Failed to write swizzled data to disk: \(error.localizedDescription)")
        }
    }

    private func data() -> Data? {
        Self.logger.debug("Retrieving data from disk.")
        let path = URL(fileURLWithPath: fileToSwizzle)
        return try? Data(contentsOf: path)
    }
}
