//
//  MainWindowVM.swift
//  Atomic
//
//  Created by Christian Dominguez on 12/12/21.
//

import SwiftUI

//Viewmodel for the main window. Controls whether a welcome message or a molecule is displayed.

class StartingWindow: ObservableObject {

    //Animations and toolbars displayed
    @Published var showFile = false
    @Published var showEdit = false
    
    //Present SwiftUI's file importer
    @Published var openFileImporter = false
}
