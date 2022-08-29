//
//  ArrayAppStorage.swift
//  Atomic
//
//  Created by Christian Dominguez on 23/8/22.
//

import SwiftUI

class RecentsStore: ObservableObject {
    
    @Published var bookmarks: [(uuid: String, url: URL)] = []
    
    public init() {
        if createDirectory() {
            loadBookmarks()
        }
    }
    
    private func createDirectory() -> Bool {
        do {
            try FileManager.default.createDirectory(at: saveDataPath(), withIntermediateDirectories: true)
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func saveDataPath() -> URL {
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("com.cdominguez.Atomic")
    }
    
    public func addBookmark(for url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {return}
            defer { url.stopAccessingSecurityScopedResource() }
            
            if bookmarks.contains(where: {$0.url == url}) {
                let thisOneIndex = bookmarks.firstIndex {$0.url == url}
                guard let thisOneIndex = thisOneIndex else {return}
                let bookmark = bookmarks[thisOneIndex]
                bookmarks.remove(at: thisOneIndex)
                bookmarks.insert(bookmark, at: 0)
                return
            }
            
            let bData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil)
            
            let id = UUID().uuidString
            
            try bData.write(to: saveDataPath().appendingPathComponent(id))
            
            withAnimation {
                bookmarks.insert((id, url), at: 0)
            }
            
            if bookmarks.count > 4 {
                removeOldestBookmark()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadBookmarks() {
        // Get URLS from bookmarks
        let files = try? FileManager.default.contentsOfDirectory(at: saveDataPath(), includingPropertiesForKeys: nil)
        
        self.bookmarks = files?.compactMap { file in
            do {
                let bData = try Data(contentsOf: file)
                var isStale = false
                let url = try URL(resolvingBookmarkData: bData, bookmarkDataIsStale: &isStale)
                
                guard !isStale else {
                    return nil
                }
                return (file.lastPathComponent, url)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } ?? []
    }
    
    public func removeOldestBookmark() {
        let uuid = bookmarks[0].uuid
        bookmarks.removeFirst()
        let url = saveDataPath().appendingPathComponent(uuid)
        try? FileManager.default.removeItem(at: url)
    }
}
