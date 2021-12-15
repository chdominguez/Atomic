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
    
    static func getMolecules(fromFileURL fileURL: URL) -> [Step]? {
        do {
            let fileData = try String(contentsOf: fileURL)
            let molreader = MolReader()
            let steps = molreader.readFile(fileURL: fileURL, dataString: fileData)
            return steps
        }
        catch {
            return nil
        }
    }
    
    static func getURL(fromDroppedFile file: [NSItemProvider], completion: @escaping (URL) -> Void) {
        _ = file.first?.loadObject(ofClass: String.self, completionHandler: { value, error in
            guard let url = value else {return}
            print(url)
            completion(URL(string: url)!)
        })
    }
//        do {
//            let fileData = try String(contentsOfFile: fileURL)
//            let molreader = MolReader()
//            let steps = molreader.readFile(fileURL: fileURL, dataString: fileData)
//            return steps
//        }
//        catch {
//            return nil
//        }
    
//    static func getMolecules(_ fromDroppedFile: [NSItemProvider]) -> [Step] {
//
//        var finalURL: URL? = nil
//        let g = DispatchGroup()
//        g.enter()
//        drop.first?.loadInPlaceFileRepresentation(forTypeIdentifier: "public.data", completionHandler: { fileURL, completed, error in
//            guard let fileURL = fileURL else {return}
//            print("*** URL from drop: \(fileURL)")
//            let textContent = try! String(contentsOf: fileURL)
//            print(textContent)
//            finalURL = fileURL
//            g.leave()
//
//        })
//        g.notify(queue: .main) {
//            self.fileURL = finalURL!
//            self.getMolecules(urlFile: finalURL!)
//            //mainWindowVM.userDidOpenAFile = true
//        }
//
//        loading = true
//        DispatchQueue.main.async { [self] in
//            let reader = MolReader()
//            guard let steps = reader.readFile(urlFile) else {fatalError()}
//            self.steps = steps
//            controller.molecule = steps[0].molecule
//            self.loading = false
//            self.moleculeReady = true
//        }
//    }
}
