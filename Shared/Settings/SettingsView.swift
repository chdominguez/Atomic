//
//  SettingsView.swift
//  Atomic
//
//  Created by Christian Dominguez on 19/9/21.
//

import SwiftUI
import SceneKit

//MARK: Settings main view
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    GeneralSettings()
                } label: {
                    Label("General", systemImage: "gear")
                }
                NavigationLink {
                    ViewSettings()
                } label: {
                    Label("View", systemImage: "paintbrush")
                }
                NavigationLink {
                    AboutAtomic()
                } label: {
                    Label("About Atomic", systemImage: "atom")
                }
 
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
            SettingsView().previewDevice(PreviewDevice(rawValue: "Mac")).frame(width: 800, height: 600, alignment: .center)
    }
}

struct GeneralSettings: View {
    var body: some View {
        Text("General settings")
    }
}
struct ViewSettings: View {
    @ObservedObject var settings = GlobalSettings.shared
    var body: some View {
        ScrollView {
            HStack {
                ColorPicker("Background color: ", selection: $settings.colorSettings.backgroundColor)
                Spacer()
                ColorPicker("Bond color: ", selection: $settings.colorSettings.bondColor)
                Spacer()
                ColorPicker("Selection color: ", selection: $settings.colorSettings.selectionColor)
            }.padding()
            Divider()
            Slider(value: $settings.colorSettings.roughness, in: 0...1) {
                Text("Roughness")
            }.padding()
            Slider(value: $settings.colorSettings.metalness, in: 0...1) {
                Text("Metalness")
            }.padding()
            Divider()
            PTable()
        }
    }
}
struct AboutAtomic: View {
    var body: some View {
        VStack {
            Text("Atomic \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
            Image("icon")
                .resizable()
                .frame(width: 150, height: 150, alignment: .center)
        }
    }
}

//MARK: Colors, quality, and render settings
struct RenderSettings {
    let geometry: SCNGeometry
    let physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    let constraints = [SCNBillboardConstraint()]
    
    
    init() {
        let geometry = SCNSphere(radius: 1)
        let material = SCNMaterial()
        
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.4
        material.roughness.contents = 0.5
        
        geometry.materials = [material]
        
        self.geometry = geometry
    }
    
}
