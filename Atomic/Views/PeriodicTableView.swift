//
//  ElementTable.swift
//  Atomic
//
//  Created by Christian Dominguez on 22/9/21.
//

import SwiftUI


struct PTable: View {
    
    @EnvironmentObject var ptablecontroller: PeriodicTableViewController
    @Binding var visible : Bool
    
    var body: some View {
        
        VStack {
            Button {
                visible = false
            } label: {
                Text("Dismiss")
            }

            Text("Selected: \(ptablecontroller.selectedAtom.name)")
            ScrollView([.horizontal, .vertical]) {
                VStack {
                    period1
                    period2
                    period3
                    period4
                    period4
                }
            }
            .padding()
            
        }
        .navigationTitle("eriodic table")
   
    }
}

struct ElementView: View {
    
    @EnvironmentObject var ptablecontroller: PeriodicTableViewController
    
#if targetEnvironment(macCatalyst)
    private var height: CGFloat {60}
    private var width: CGFloat {50}
    private var fontSize: CGFloat {12}
#else
    let height = UIScreen.main.bounds.height / 8
    private var width: CGFloat {height / 1.2}
    private var fontSize: CGFloat { width / 20 }
#endif

    let element: Element
    
    var body: some View {
        HStack {
            Spacer().frame(width: 10)
            VStack(alignment: .leading) {
                Text("\(element.atomicNumber)").font(.system(size: fontSize))
                Text(element.rawValue).font(.title).bold()
                Text(element.name).font(.caption).truncationMode(.tail).lineLimit(1).padding(.horizontal, 1)
            }
            Spacer()
        }
        .onTapGesture {
            ptablecontroller.selectedAtom = element
        }
        .frame(width: width, height: height)
        .background(Color(red: 237/255, green: 240/255, blue: 241/255))
        .border(element == ptablecontroller.selectedAtom ? Color.red : Color.black, width: 2)
        .preferredColorScheme(.light)
    }
}

struct PTable_Previews: PreviewProvider {
    static var previews: some View {
        ElementView(element: .magnesium).environmentObject(PeriodicTableViewController.shared)
    }
}

extension PTable {
    
    private var period1: some View {
        HStack {
            ElementView(element: .hydrogen)
            Spacer()
            ElementView(element: .helium)
        }
    }
    private var period2: some View {
        HStack {
            ElementView(element: .lithium)
            ElementView(element: .beryllium)
            Spacer()
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 10 && p.atomicNumber >= 5 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period3: some View {
        HStack {
            ElementView(element: .sodium)
            ElementView(element: .magnesium)
            Spacer()
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 18 && p.atomicNumber >= 13 {
                    ElementView(element: p)
                }
            }
        }
    }
    private var period4: some View {
        HStack {
            ForEach(Element.allCases, id: \.self) { p in
                if p.atomicNumber <= 36 && p.atomicNumber >= 19 {
                    ElementView(element: p)
                }
            }
        }
    }
}


