//
//  PeriodicTable.swift
//  PeriodicTable
//
//  Created by Christian Dominguez on 17/8/21.
//

import SwiftUI

enum Element: String, CaseIterable {
    
    case hydrogen = "H"
    case helium = "He"
    case lithium = "Li"
    case beryllium = "Be"
    case boron = "B"
    case carbon = "C"
    case nitrogen = "N"
    case oxygen = "O"
    case fluorine = "F"
    case neon = "Ne"
    case sodium = "Na"
    case magnesium = "Mg"
    case aluminium = "Al"
    case silicon = "Si"
    case phosphorus = "P"
    case sulphur = "S"
    case chlorine = "Cl"
    case argon = "Ar"
    case potassium = "K"
    case calcium = "Ca"
    case scandium = "Sc"
    case titanium = "Ti"
    case vanadium = "V"
    case chromium = "Cr"
    case manganese = "Mn"
    case iron = "Fe"
    case cobalt = "Co"
    case nickel = "Ni"
    case copper = "Cu"
    case zinc = "Zn"
    case gallium = "Ga"
    case germanium = "Ge"
    case arsenic = "As"
    case selenium = "Se"
    case bromine = "Br"
    case krypton = "Kr"
    
    var name: String {
        switch self {
        case .hydrogen:
            return "Hydrogen"
        case .helium:
            return "Helium"
        case .lithium:
            return "Lithium"
        case .beryllium:
            return "Beryllium"
        case .boron:
            return "Boron"
        case .carbon:
            return "Carbon"
        case .nitrogen:
            return "Nitrogen"
        case .oxygen:
            return "Oxygen"
        case .fluorine:
            return "Fluorine"
        case .neon:
            return "Neon"
        case .sodium:
            return "Sodium"
        case .magnesium:
            return "Magnesium"
        case .aluminium:
            return "Aluminium"
        case .silicon:
            return "Silicon"
        case .phosphorus:
            return "Phosphorus"
        case .sulphur:
            return "Sulfur"
        case .chlorine:
            return "Chlorine"
        case .argon:
            return "Argon"
        case .potassium:
            return "Potassium"
        case .calcium:
            return "Calcium"
        case .scandium:
            return "Scandium"
        case .titanium:
            return "Titanium"
        case .vanadium:
            return "Vanadium"
        case .chromium:
            return "Chromium"
        case .manganese:
            return "Manganese"
        case .iron:
            return "Iron"
        case .cobalt:
            return "Cobalt"
        case .nickel:
            return "Nickel"
        case .copper:
            return "Copper"
        case .zinc:
            return "Zinc"
        case .gallium:
            return "Gallium"
        case .germanium:
            return "Germanium"
        case .arsenic:
            return "Arsenic"
        case .selenium:
            return "Selenium"
        case .bromine:
            return "Bromine"
        case .krypton:
            return "Krypton"
        }
    }
    
    var color: Color {
        switch self {
        case .hydrogen:
            return .white
        case .helium:
            return .cyan
        case .lithium:
            return .yellow
        case .beryllium:
            return .green
        case .boron:
            return .black // TEMPORARY
        case .carbon:
            return .gray
        case .nitrogen:
            return .blue
        case .oxygen:
            return .red
        case .fluorine:
            return .cyan
        case .neon:
            return .black
        case .sodium:
            return .orange
        case .magnesium:
            return .white
        case .aluminium:
            return .gray
        case .silicon:
            return .black // TEMPORARY
        case .phosphorus:
            return .orange
        case .sulphur:
            return .yellow
        case .chlorine:
            return .purple
        case .argon:
            return .black // TEMPORARY
        default:
            return .gray
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .hydrogen:
            return 0.2
        case .helium:
            return 0.5
        case .lithium:
            return 0.5
        case .beryllium:
            return 0.5
        case .boron:
            return 0.5
        case .carbon:
            return 0.5
        case .nitrogen:
            return 0.5
        case .oxygen:
            return 0.5
        case .fluorine:
            return 0.5
        case .neon:
            return 0.5
        case .sodium:
            return 0.5
        case .magnesium:
            return 0.5
        case .aluminium:
            return 0.5
        case .silicon:
            return 0.5
        case .phosphorus:
            return 0.5
        case .sulphur:
            return 0.5
        case .chlorine:
            return 0.5
        case .argon:
            return 0.5
        default:
            return 0.5
        }
    }
    
    var atomicNumber: Int {
        switch self {
        case .hydrogen:
            return 1
        case .helium:
            return 2
        case .lithium:
            return 3
        case .beryllium:
            return 4
        case .boron:
            return 5
        case .carbon:
            return 6
        case .nitrogen:
            return 7
        case .oxygen:
            return 8
        case .fluorine:
            return 9
        case .neon:
            return 10
        case .sodium:
            return 11
        case .magnesium:
            return 12
        case .aluminium:
            return 13
        case .silicon:
            return 14
        case .phosphorus:
            return 15
        case .sulphur:
            return 16
        case .chlorine:
            return 17
        case .argon:
            return 18
        case .potassium:
            return 19
        case .calcium:
            return 20
        case .scandium:
            return 21
        case .titanium:
            return 22
        case .vanadium:
            return 23
        case .chromium:
            return 24
        case .manganese:
            return 25
        case .iron:
            return 26
        case .cobalt:
            return 27
        case .nickel:
            return 28
        case .copper:
            return 29
        case .zinc:
            return 30
        case .gallium:
            return 31
        case .germanium:
            return 32
        case .arsenic:
            return 33
        case .selenium:
            return 34
        case .bromine:
            return 35
        case .krypton:
            return 36
        }
    }
    
    var canDoubleBond: Bool {
        switch self {
        case .hydrogen:
            return false
        case .helium:
            return false
        case .lithium:
            return false
        case .beryllium:
            return false
        case .boron:
            return true
        case .carbon:
            return true
        case .nitrogen:
            return true
        case .oxygen:
            return true
        case .fluorine:
            return true
        case .neon:
            return true
        case .sodium:
            return true
        case .magnesium:
            return true
        case .aluminium:
            return true
        case .silicon:
            return true
        case .phosphorus:
            return true
        case .sulphur:
            return true
        case .chlorine:
            return true
        case .argon:
            return true
        default:
            return true
        }
    }
}

