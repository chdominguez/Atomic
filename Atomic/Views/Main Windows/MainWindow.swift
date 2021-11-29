//
//  MainWindow.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import Combine

struct MainWindow: View {
        
    @ObservedObject var toolsController: ToolsController = ToolsController.shared
    
    @State var periodicVisible = false
    
    @State var periodicBarVisible = false
    
    var body: some View {
        ZStack {
            demoMolecule
            VStack(spacing: 0) {
                toolbar1.background(Color.gray.opacity(0.5))
                editToolbar.background(Color.gray.opacity(0.5))
                    .opacity(toolsController.selected1Tool == .edit ? 1 : 0)
                Spacer()
            }
        }
    }
}

extension MainWindow {
    
    private var demoMolecule: some View {
        DemoMolecule()
    }
    
    private var editToolbar: some View {
        HStack {
            Button {
                periodicVisible.toggle()
            } label: {
                Text("Periodic table")
            }
            .popover(isPresented: $periodicVisible, content: {
                PTable(visible: $periodicVisible)
                    .frame(width: 800)
            })
            
            Button {
                toolsController.selected2Tool = .selectAtom
            } label: {
                Text("Select")
            }
            
            Button {
                demoMolecule.
            } label: {
                HStack{
                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up.fill").rotationEffect(Angle(degrees: 90))
                    Text("Bond")
                }
            }

            Spacer()
        }.padding()
    }
    
    private var toolbar1: some View {
        HStack(spacing: 5){
            Button {
                print("New file")
            } label: {
                HStack{
                    Image(systemName: "doc.badge.plus")
                    Text("New")
                }
            }
            Button {
                print("Open file")
            } label: {
                HStack{
                    Image(systemName: "doc.on.doc")
                    Text("Open")
                }
            }
            Button {
                print("Save file")
            } label: {
                HStack{
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Save")
                }
            }
            
            Spacer()
            
            Button {
                toolsController.selected1Tool = .manipulate
            } label: {
                HStack{
                    Image(systemName: "hand.point.up.left")
                    Text("Manipulate")
                }
            }
            Button {
                toolsController.selected1Tool = .edit
            } label: {
                HStack {
                    Image(systemName: "paintbrush.pointed")
                    Text("Edit")
                }
            }
            Button {
                toolsController.selected1Tool = .measure
            } label: {
                HStack{
                    Image(systemName: "ruler")
                    Text("Measure")
                }
            }
        }
        .padding(10)
    }
}



