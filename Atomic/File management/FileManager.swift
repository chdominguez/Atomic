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
    
    static let types = [UTType("com.MolViewer.qfi")!, UTType("com.MolViewer.gjf")!, .log]
    
    static func getFile(res: Result<URL, Error>) -> URL? {
        do {
            let fileURL = try res.get()
            return fileURL
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
