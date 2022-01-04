//
//  FileManager.swift
//  FileManager
//
//  Created by Christian Dominguez on 16/8/21.
//
import UniformTypeIdentifiers
import SwiftUI
import SceneKit

class FileOpener: ObservableObject {
    
    private init() {}
    
    //File types that the app supports.
    static let types: [UTType] = [UTType(filenameExtension: "gjf")!,
                                  UTType(filenameExtension: "log")!,
                                  UTType(filenameExtension: "qfi")!]
    
    //Function to get the url when opening the file from the document picker.
    static func getFileURLForPicked(_ res: Result<URL, Error>) -> URL? {
        do {
            let fileURL = try res.get()
            return fileURL
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func getFileAsString(from file: URL) throws -> String {
        do {
            return try String(contentsOf: file)
        }
        catch {
            throw FileErrors.cannotOpen
        }
    }
    
    static func getMolecules(fromFileURL fileURL: URL) throws -> [Step]? {
        let fileData = try String(contentsOf: fileURL)
        let molreader = MolReader()
        let steps = try molreader.readFile(fileURL: fileURL, dataString: fileData)
        return steps
    }
    
    static func getURL(fromDroppedFile file: [NSItemProvider], completion: @escaping (URL) -> Void) {
        _ = file.first?.loadObject(ofClass: String.self, completionHandler: { value, error in
            guard let url = value else {return}
            print(url)
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
