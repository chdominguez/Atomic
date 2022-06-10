//
//  PeriodicTable.swift
//  PeriodicTable
//
//  Created by Christian Dominguez on 17/8/21.
//

import SwiftUI

enum Element: String, CaseIterable {
    
    case hydrogen       = "H"
    case helium         = "He"
    case lithium        = "Li"
    case beryllium      = "Be"
    case boron          = "B"
    case carbon         = "C"
    case nitrogen       = "N"
    case oxygen         = "O"
    case fluorine       = "F"
    case neon           = "Ne"
    case sodium         = "Na"
    case magnesium      = "Mg"
    case aluminium      = "Al"
    case silicon        = "Si"
    case phosphorus     = "P"
    case sulphur        = "S"
    case chlorine       = "Cl"
    case argon          = "Ar"
    case potassium      = "K"
    case calcium        = "Ca"
    case scandium       = "Sc"
    case titanium       = "Ti"
    case vanadium       = "V"
    case chromium       = "Cr"
    case manganese      = "Mn"
    case iron           = "Fe"
    case cobalt         = "Co"
    case nickel         = "Ni"
    case copper         = "Cu"
    case zinc           = "Zn"
    case gallium        = "Ga"
    case germanium      = "Ge"
    case arsenic        = "As"
    case selenium       = "Se"
    case bromine        = "Br"
    case krypton        = "Kr"
    case rubidium       = "Rb"
    case strontium      = "Sr"
    case yttrium        = "Y"
    case zirconium      = "Zr"
    case niobium        = "Nb"
    case molybdenum     = "Mo"
    case technecium     = "Tc"
    case ruthenium      = "Ru"
    case rhodium        = "Rh"
    case palladium      = "Pd"
    case silver         = "Ag"
    case cadmium        = "Cd"
    case indium         = "In"
    case tin            = "Sn"
    case antimony       = "Sb"
    case tellurium      = "Te"
    case iodine         = "I"
    case xenon          = "Xe"
    case caesium        = "Cs"
    case barium         = "Ba"
    case lanthanum      = "La"
    case cerium         = "Ce"
    case praseodymium   = "Pr"
    case neodymium      = "Nd"
    case promethium     = "Pm"
    case samarium       = "Sm"
    case europium       = "Eu"
    case gadolinium     = "Gd"
    case terbium        = "Tb"
    case dysprosium     = "Dy"
    case holmium        = "Ho"
    case erbium         = "Er"
    case thulium        = "Tm"
    case ytterbium      = "Yb"
    case lutetium       = "Lu"
    case hafnium        = "Hf"
    case tantalum       = "Ta"
    case tungsten       = "W"
    case rhenium        = "Re"
    case osmium         = "Os"
    case iridium        = "Ir"
    case platinum       = "Pt"
    case gold           = "Au"
    case mercury        = "Hg"
    case thalium        = "Tl"
    case lead           = "Pb"
    case bismuth        = "Bi"
    case polonium       = "Po"
    case astatine       = "At"
    case radon          = "Rn"
    case francium       = "Fr"
    case radium         = "Ra"
    case actinium       = "Ac"
    case thorium        = "Th"
    case protoactinium  = "Pa"
    case uranium        = "U"
    case neptunium      = "Mp"
    case plutonium      = "Pu"
    case americium      = "Am"
    case curium         = "Cm"
    case berkelium      = "Bk"
    case californium    = "Cf"
    case einstenium     = "Es"
    case fermium        = "Fm"
    case mendelevium    = "Md"
    case nobelium       = "No"
    case lawrencium     = "Lr"
    case rutherfordium  = "Rf"
    case dubnium        = "Db"
    case seaborgium     = "Sg"
    case bohrium        = "Bh"
    case hassium        = "Hs"
    case meitnerium     = "Mt"
    case darmstadtium   = "Ds"
    case roentgenium    = "Rg"
    case copernicium    = "Cn"
    case nihonium       = "Nh"
    case flerovium      = "Fl"
    case moscovium      = "Mc"
    case livermorium    = "Lv"
    case tenessine      = "Ts"
    case oganesson      = "Og"
    case dummy          = "X"
    
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
        case .rubidium:
            return "Rubidium"
        case .strontium:
            return "Strontium"
        case .yttrium:
            return "Yttrium"
        case .zirconium:
            return "Zirconium"
        case .niobium:
            return "Niobium"
        case .molybdenum:
            return "Molybdenum"
        case .technecium:
            return "Technecium"
        case .ruthenium:
            return "Ruthenium"
        case .rhodium:
            return "Rhodium"
        case .palladium:
            return "Palladium"
        case .silver:
            return "Silver"
        case .cadmium:
            return "Cadmium"
        case .indium:
            return "Indium"
        case .tin:
            return "Tin"
        case .antimony:
            return "Antimony"
        case .tellurium:
            return "Tellurium"
        case .iodine:
            return "Iodine"
        case .xenon:
            return "Xenon"
        case .caesium:
            return "Caesium"
        case .barium:
            return "Barium"
        case .lanthanum:
            return "Lanthanum"
        case .cerium:
            return "Cerium"
        case .praseodymium:
            return "Praseodymium"
        case .neodymium:
            return "Neodymium"
        case .promethium:
            return "Promethium"
        case .samarium:
            return "Samarium"
        case .europium:
            return "Europium"
        case .gadolinium:
            return "Gadolinium"
        case .terbium:
            return "Terbium"
        case .dysprosium:
            return "Dysprosium"
        case .holmium:
            return "Holmium"
        case .erbium:
            return "Erbium"
        case .thulium:
            return "Thulium"
        case .ytterbium:
            return "Ytterbium"
        case .lutetium:
            return "Lutetium"
        case .hafnium:
            return "Hafnium"
        case .tantalum:
            return "Tantalum"
        case .tungsten:
            return "Tungsten"
        case .rhenium:
            return "Rhenium"
        case .osmium:
            return "Osmium"
        case .iridium:
            return "Iridium"
        case .platinum:
            return "Platinum"
        case .gold:
            return "Gold"
        case .mercury:
            return "Mercury"
        case .thalium:
            return "Thalium"
        case .lead:
            return "Lead"
        case .bismuth:
            return "Bismuth"
        case .polonium:
            return "Polonium"
        case .astatine:
            return "Astatine"
        case .radon:
            return "Radon"
        case .francium:
            return "Francium"
        case .radium:
            return "Radium"
        case .actinium:
            return "Actinium"
        case .thorium:
            return "Thorium"
        case .protoactinium:
            return "Protoactinium"
        case .uranium:
            return "Uranium"
        case .neptunium:
            return "Neptunium"
        case .plutonium:
            return "Plutonium"
        case .americium:
            return "Americium"
        case .curium:
            return "Curium"
        case .berkelium:
            return "Berkelium"
        case .californium:
            return "Californium"
        case .einstenium:
            return "Einstenium"
        case .fermium:
            return "Fermium"
        case .mendelevium:
            return "Mendelevium"
        case .nobelium:
            return "Nobelium"
        case .lawrencium:
            return "Lawrencium"
        case .rutherfordium:
            return "Rutherfordium"
        case .dubnium:
            return "Dubnium"
        case .seaborgium:
            return "Seaborgium"
        case .bohrium:
            return "Bohrium"
        case .hassium:
            return "Hassium"
        case .meitnerium:
            return "Meitnerium"
        case .darmstadtium:
            return "Darmstadtium"
        case .roentgenium:
            return "Roentgenium"
        case .copernicium:
            return "Copernicium"
        case .nihonium:
            return "Nihonium"
        case .flerovium:
            return "Flerovium"
        case .moscovium:
            return "Moscovium"
        case .livermorium:
            return "Livermorium"
        case .tenessine:
            return "Tenessine"
        case .oganesson:
            return "Oganesson"
        case .dummy:
            return "Dummy atom"
        }
    }
    
    #warning("TODO: Assign custom RGB colors")
    // Default atom colors
    var color: Color {
        switch self {
        case .hydrogen:
            return .white
        case .helium:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        case .lithium:
            return .purple
        case .beryllium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        case .boron:
            return Color(red: 255/255, green: 152/255, blue: 8/255)
        case .carbon:
            return .black
        case .nitrogen:
            return Color(red: 0/255, green: 0/255, blue: 255/255)
        case .oxygen:
            return .red
        case .fluorine:
            return .green
        case .neon:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        case .sodium:
            return .purple
        case .magnesium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        case .aluminium:
            return .gray
        case .silicon:
            return .black // TEMPORARY
        case .phosphorus:
            return .orange
        case .sulphur:
            return .yellow
        case .chlorine:
            return .green
        case .argon:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        case .bromine:
            return Color(red: 150/255, green: 23/255, blue: 0/255)
        case .iodine:
            return Color(red: 109/255, green: 0/255, blue: 143/255)
        /// Noble gases
        case .krypton:
            return Color(red: 69/255, green: 165/255, blue: 245/255)    
        case .xenon:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        case .radon:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        case .oganesson:
            return Color(red: 69/255, green: 165/255, blue: 245/255)
        /// Alkali metals
        case .potassium:
            return .purple
        case .rubidium:
            return .purple
        case .caesium:
            return .purple
        case .francium:
            return .purple
        /// Alkaline earths
        case .calcium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        case .strontium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        case .barium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        case .radium:
            return Color(red: 2/255, green: 128/255, blue: 14/255)
        /// Specific Ones
        case .titanium:
            return .gray
        case .iron:
            return Color(red: 158/255, green: 94/255, blue: 5/255)
        case .dummy:
            return .blue
        default:
            return .pink
        }
    }

/// COVALENT RADIUS
    var radius: CGFloat {
        switch self {
        case .hydrogen:
            return 0.32
        case .helium:
            return 0.37
        case .lithium:
            return 1.30
        case .beryllium:
            return 0.99
        case .boron:
            return 0.84
        case .carbon:
            return 0.75
        case .nitrogen:
            return 0.71
        case .oxygen:
            return 0.64
        case .fluorine:
            return 0.60
        case .neon:
            return 0.62
        case .sodium:
            return 1.60
        case .magnesium:
            return 1.40
        case .aluminium:
            return 1.24
        case .silicon:
            return 1.14
        case .phosphorus:
            return 1.09
        case .sulphur:
            return 1.04
        case .chlorine:
            return 1.00
        case .argon:
            return 1.01
        default:
            return 1.5
        }
    }

/// ATOMIC RADIUS
///    var radius: CGFloat {
///     switch self {
///     case .hydrogen:
///         return 1.10
///     case .helium:
///         return 1.40
///     case .lithium:
///         return 1.82
///     case .beryllium:
///         return 1.53
///     case .boron:
///         return 1.92
///     case .carbon:
///         return 1.70
///     case .nitrogen:
///         return 1.55
///     case .oxygen:
///         return 1.52
///     case .fluorine:
///         return 1.47
///     case .neon:
///         return 1.54
///     case .sodium:
///         return 2.27
///     case .magnesium:
///         return 1.73
///     case .aluminium:
///         return 1.84
///     case .silicon:
///         return 2.10
///     case .phosphorus:
///         return 1.80
///     case .sulphur:
///         return 1.80
///     case .chlorine:
///         return 1.75
///     case .argon:
///         return 1.88
///     default:
///         return 2.0
///     }
/// }

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
        case .rubidium:
            return 37
        case .strontium:
            return 38
        case .yttrium:
            return 39
        case .zirconium:
            return 40
        case .niobium:
            return 41
        case .molybdenum:
            return 42
        case .technecium:
            return 43
        case .ruthenium:
            return 44
        case .rhodium:
            return 45
        case .palladium:
            return 46
        case .silver:
            return 47
        case .cadmium:
            return 48
        case .indium:
            return 49
        case .tin:
            return 50
        case .antimony:
            return 51
        case .tellurium:
            return 52
        case .iodine:
            return 53
        case .xenon:
            return 54
        case .caesium:
            return 55
        case .barium:
            return 56
        case .lanthanum:
            return 57
        case .cerium:
            return 58
        case .praseodymium:
            return 59
        case .neodymium:
            return 60
        case .promethium:
            return 61
        case .samarium:
            return 62
        case .europium:
            return 63
        case .gadolinium:
            return 64
        case .terbium:
            return 65
        case .dysprosium:
            return 66
        case .holmium:
            return 67
        case .erbium:
            return 68
        case .thulium:
            return 69
        case .ytterbium:
            return 70
        case .lutetium:
            return 71
        case .hafnium:
            return 72
        case .tantalum:
            return 73
        case .tungsten:
            return 74
        case .rhenium:
            return 75
        case .osmium:
            return 76
        case .iridium:
            return 77
        case .platinum:
            return 78
        case .gold:
            return 79
        case .mercury:
            return 80
        case .thalium:
            return 81
        case .lead:
            return 82
        case .bismuth:
            return 83
        case .polonium:
            return 84
        case .astatine:
            return 85
        case .radon:
            return 86
        case .francium:
            return 87
        case .radium:
            return 88
        case .actinium:
            return 89
        case .thorium:
            return 90
        case .protoactinium:
            return 91
        case .uranium:
            return 92
        case .neptunium:
            return 93
        case .plutonium:
            return 94
        case .americium:
            return 95
        case .curium:
            return 96
        case .berkelium:
            return 97
        case .californium:
            return 98
        case .einstenium:
            return 99
        case .fermium:
            return 100
        case .mendelevium:
            return 101
        case .nobelium:
            return 102
        case .lawrencium:
            return 103
        case .rutherfordium:
            return 104
        case .dubnium:
            return 105
        case .seaborgium:
            return 106
        case .bohrium:
            return 107
        case .hassium:
            return 108
        case .meitnerium:
            return 109
        case .darmstadtium:
            return 110
        case .roentgenium:
            return 111
        case .copernicium:
            return 112
        case .nihonium:
            return 113
        case .flerovium:
            return 114
        case .moscovium:
            return 115
        case .livermorium:
            return 116
        case .tenessine:
            return 117
        case .oganesson:
            return 118
        case .dummy:
            return 119
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
            return false
        default:
            return true
        }
    }
}
