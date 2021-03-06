//
//  FileManager.swift
//  FileManager
//
//  Created by Christian Dominguez on 16/8/21.
//

import UniformTypeIdentifiers
import SwiftUI

/// Manages file extensions and file URLs.
class AtomicFileOpener: ObservableObject {
    
    static let shared = AtomicFileOpener()
    
    //File types that the app supports as UTTypes
    internal let types: [UTType]
    
    //Initialize the class with the allowed file extensions present in the AllowedFileExtension enum
    private init() {
        var types: [UTType] = []
        for fileExt in AFE.allCases {
            let uttype = UTType(filenameExtension: fileExt.rawValue)!
            types.append(uttype)
        }
        self.types = types
    }
    
    ///Get the url when opening the file from the document picker.
    static func getFileURLForPicked(_ res: Result<URL, Error>) -> URL? {
        do {
            let fileURL = try res.get()
            return fileURL
        }
        catch {
            return nil
        }
    }
    /// File from URL gets returned as a String.
    static func getFileAsString(from file: URL) throws -> String {
        do {
            return try String(contentsOf: file)
        }
        catch {
            throw FileErrors.cannotOpen
        }
    }
    
    
    static func getURL(fromDroppedFile file: [NSItemProvider], completion: @escaping (URL) -> Void) {
        _ = file.first?.loadObject(ofClass: String.self, completionHandler: { value, error in
            guard let url = value else {return}
            completion(URL(string: url)!)
        })
    }
    
    enum FileErrors: Error, LocalizedError {
        case cannotOpen
        var errorDescription: String? {
            switch self {
            case .cannotOpen:
                return "Could not open file"
            }
        }
    }
}

/// XYZ files are saved from this struct, which conforms to FileDocument.
struct xyzFile: FileDocument {
    
    static var readableContentTypes = [UTType(filenameExtension: AFE.xyz.rawValue)!]
    
    var text: String = ""
    
    init(initialText: String = "") {
        text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
    
    
}
