//
//  GaussianKeywords.swift
//  Atomic
//
//  Created by Christian Dominguez on 28/12/21.
//

import Foundation

extension BaseReader {
    
    // General gaussian job types
    enum jobKeywords: String, CaseIterable {
        case opt     = "opt"
        case freq    = "freq"
        case energy  = ""
        case optfreq = "opt freq"
        case irc     = "irc"
        case scan    = "scan"
        case stable  = "stable"
        case nmr     = "NMR"
    }
    
    // Optimization specific keywords
    enum optKeywords: String, CaseIterable {
        case minimum = ""
        case ts      = "ts"
        case qst2    = "qst2"
        case qst3    = "qst3"
        case calcfc  = "calcfc"
        case calcall = "calcall"
        case readfc  = "readfc"
        case rcfc    = "rcfc"
        case rfostep = "rfo"
        case tight   = "tight"
    }
    
    // Frequency specific keywords
    enum freqKeywords: String, CaseIterable {
        case raman             = "raman"
        case noraman           = "noraman"
        case savenormalmodes   = "savenormalmodes"
        case nosavenormalmodes = "nosavenormalmodes"
        case vcd               = "vcd"
        case roa               = "roa"
        case cphf              = "cphf=rdfreq"
        case nodiagfull        = "nodiagfull"
        case projected         = "projected"
        case anharmonic        = "anharmonic"
        case anharmonicModes   = "anharmonicModes"
    }
    
    // IRC specific keywords
    enum ircKeywords: String, CaseIterable {
        case followIRCforward = "forward"
        case followIRCReverse = "reverse"
        case folowIRCBoth     = ""
        case recorrectYes     = "recorrect=yes"
        case recorrectNever   = "recorrect=never"
        case recorrectAlways  = "recorrect=always"
        case recorrectTest    = "recorrect=test"
    }
    
    // Scan specific keywords
    enum scanKeywords: String, CaseIterable {
        case relaxed = "z-matrix"
        case redundant = "modredundant"
        case rigid = ""
    }
    
    // Stability specific keywords
    enum stabilityKeywords: String, CaseIterable {
        case reoptimize = "opt"
    }
    
    // NMR specific keywords
    enum NMRKeywords: String, CaseIterable {
        case giao     = "giao"
        case csgt     = "csgt"
        case igaim    = "igaim"
        case all      = "all"
        case spinspin = "spinspin"
        case mixed    = "mixed"
    }
    
    // Methods
    
    enum CalculationMethods: String, CaseIterable {
        // Hartree-Fock
        case hf         = "hf"
        
        // DFT methods...
        case b3lyp      = "b3lyp"
        case pbe0       = "pbepbe"
        case m062x      = "m062x"
        // More to be added....
        
        // Fallthrough
        case other = ""
    }
    
    enum EnergyMethods: String, CaseIterable {
        // Hartree-Fock
        case hf         = "HF"
        
        // Coupled-cluster and Møller–Plesset
        case ccsdt      = "CCSD(T)"
        case ccsd       = "CCSD"
        case mp2        = "MP2"
        case mp4        = "MP4"
        
        #warning("TODO: Gaussian keywords")
        // Fallthrought WIP
    }
}
