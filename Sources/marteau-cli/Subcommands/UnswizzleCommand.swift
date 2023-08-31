//
//  UnswizzleCommand.swift
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

struct UnswizzleCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "unswizzle",
        abstract: "Unswizzles a given binary file into its original form.")

    static var logger = Logger(label: "unswizzler")

    @Argument(help: "The path to the swizzled file to restore.")
    var fileToRestore: String

    @Argument(help: "The path to where the restored file will be written.")
    var outputFile: String = "Data.swizzle"

    @Flag(help: "Display debugging messages.")
    var debug = false

    func validate() throws {
        guard fileToRestore.hasSuffix(".swizzle") else {
            throw ValidationError("Input must be a swizzled file (.swizzle).")
        }

        let path = URL(fileURLWithPath: outputFile)
        guard path.isFileURL else {
            throw ValidationError("Output file path must be valid.")
        }
    }

    func run() throws {
        if debug { Self.logger.logLevel = .debug }
        guard let data = data() else {
            Self.logger.error("Failed to load file.")
            return
        }

        let decoder = DataSwizzler(data: data)
        Self.logger.debug("Decoding swizzled data.")
        guard let decodedData = decoder.decoded() else {
            Self.logger.error("Failed to decode swizzled data.")
            return
        }

        let outputPath = URL(fileURLWithPath: outputFile)
        do {
            try decodedData.write(to: outputPath)
            Self.logger.info("Wrote decoded data to: \(outputFile)")
        } catch {
            Self.logger.error("Failed to write decoded data to disk: \(error.localizedDescription)")
        }
    }

    private func data() -> Data? {
        Self.logger.debug("Retrieving data from disk.")
        let path = URL(fileURLWithPath: fileToRestore)
        return try? Data(contentsOf: path)
    }
}
