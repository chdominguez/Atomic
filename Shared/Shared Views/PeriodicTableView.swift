//
//  ElementTable.swift
//  Atomic
//
//  Created by Christian Dominguez on 22/9/21.
//

import SwiftUI


struct PTable: View {
    
    @ObservedObject var ptableController = PeriodicTableViewController.shared
    @ObservedObject var colorSettings = ColorSettings.shared
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    ColorPicker("Atom color", selection: $colorSettings.atomColors[ptableController.selectedAtom.atomicNumber - 1])
                    Spacer()
                }
                VStack(alignment: .center) {
                    HStack {
                        Text("\(ptableController.selectedAtom.atomicNumber)").padding(.horizontal, 1)
                    }
                    Text(ptableController.selectedAtom.rawValue).font(.headline).bold()
                }
                .frame(width: 50, height: 70)
                .background(Color(red: 237/255, green: 240/255, blue: 241/255))
                .border(Color.black)
            }
            VStack(spacing: 2) {
                period1
                period2
                period3
                period4
                period5
                period6
                period7
                VStack {
                    Spacer().frame(height: 10)
                    lanthanids
                    actinides
                }
            }
        }
        .padding()
        .navigationTitle("Periodic table")
        
    }
}

struct ElementView: View {
    
    @ObservedObject var ptablecontroller = PeriodicTableViewController.shared
    
    private var height: CGFloat {45}
    private var width: CGFloat {35}
//    let height = UIScreen.main.bounds.height / 8
//    private var width: CGFloat {height / 1.2}
//    private var fontSize: CGFloat { width / 20 }
//#endif

    let element: Element?
    
    var body: some View {
        if let element = element {
            ZStack {
                Text(element.rawValue).bold()
            }
            .frame(width: width, height: height)
            .background(Color(red: 237/255, green: 240/255, blue: 241/255))
            .border(element == ptablecontroller.selectedAtom ? Color.red : Color.black, width: 2)
            .preferredColorScheme(.light)
            .onTapGesture {
                ptablecontroller.selectedAtom = element
            }
        }
        else {
            ZStack {
                EmptyView()
            }.frame(width: width, height: height)
        }
    }
}

struct PTable_Previews: PreviewProvider {
    static var previews: some View {
        ElementView(ptablecontroller: PeriodicTableViewController.shared, element: .hydrogen)
    }
}

extension PTable {
    
    private var period1: some View {
        HStack(spacing: 2) {
            ElementView(element: .hydrogen)
            ForEach(0..<16) { _ in
                ElementView(element: nil)
            }
            ElementView(element: .helium)
        }
    }
    private var period2: some View {
        HStack(spacing: 2) {
            ElementView(element: .lithium)
            ElementView(element: .beryllium)
            ForEach(0..<10) { _ in
                ElementView(element: nil)
            }
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 10 && p.atomicNumber >= 5 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period3: some View {
        HStack(spacing: 2) {
            ElementView(element: .sodium)
            ElementView(element: .magnesium)
            ForEach(0..<10) { _ in
                ElementView(element: nil)
            }
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 18 && p.atomicNumber >= 13 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period4: some View {
        HStack(spacing: 2) {
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 36 && p.atomicNumber >= 19 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period5: some View {
        HStack(spacing: 2) {
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 54 && p.atomicNumber >= 37 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period6: some View {
        HStack(spacing: 2) {
            ElementView(element: .caesium)
            ElementView(element: .barium)
            ElementView(element: nil)
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 86 && p.atomicNumber >= 72 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period7: some View {
        HStack(spacing: 2) {
            ElementView(element: .francium)
            ElementView(element: .radium)
            ElementView(element: nil)
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 118 && p.atomicNumber >= 104 {
                    ElementView(element: p)
                }
            }
        }
    }
    
    private var lanthanids: some View {
        HStack(spacing: 2) {
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 71 && p.atomicNumber >= 57 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var actinides: some View {
        HStack(spacing: 2) {
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 103 && p.atomicNumber >= 89 {
                    ElementView(element: p)
                }
            }
        }
    }
}


