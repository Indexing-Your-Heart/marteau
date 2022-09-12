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

import ArgumentParser
import FigSwiftArgumentParser
import Foundation
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
        subcommands: [DialogueCommand.self, DialogicCommand.self, JensonCommand.self]
    )
}
