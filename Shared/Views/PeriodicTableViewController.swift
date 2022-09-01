//
//  PeriodicTableViewController.swift
//  Atomic
//
//  Created by Christian Dominguez on 4/10/21.
//

import SwiftUI
import ProteinKit


class PeriodicTableViewController: ObservableObject {
    
    static let shared = PeriodicTableViewController()
    
    @Published var selectedAtom = Element.hydrogen
    
}
