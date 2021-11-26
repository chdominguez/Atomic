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
            DemoMolecule()
            VStack {
                toolbar1.background(Color.red)
                
                editToolbar
                    .opacity(toolsController.selected1Tool == .edit ? 1 : 0)
                Spacer()
            }
        }
    }
}

extension MainWindow {
    
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



