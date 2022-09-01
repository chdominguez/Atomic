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
                        .navigationTitle("About Atomic")
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
        AboutAtomic()
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
             LazyVStack {
                Section {
                    ColorPicker("Line color: ", selection: $settings.colorSettings.chartColor)
                } header: {
                    Text("Charts").bold()
                }
                Section {
                    VStack(alignment: .leading) {
                        ColorPicker("Background color: ", selection: $settings.colorSettings.backgroundColor)
                        Spacer()
                        ColorPicker("Bond color: ", selection: $settings.colorSettings.bondColor)
                        Spacer()
                        ColorPicker("Selection color: ", selection: $settings.colorSettings.selectionColor)
                    }
                } header: {
                    Text("Scene").bold()
                }
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Roughness")
                            Slider(value: $settings.colorSettings.roughness, in: 0...1)
                        }
                        HStack {
                            Text("Metalness")
                            Slider(value: $settings.colorSettings.metalness, in: 0...1)
                        }
                        HStack {
                            Picker("Light type", selection: $settings.lightType) {
                                Text("Ambient").tag(SCNLight.LightType.ambient)
                                Text("Directional").tag(SCNLight.LightType.directional)
                                Text("Area").tag(SCNLight.LightType.area)
                                Text("Omni").tag(SCNLight.LightType.omni)
                                Text("Spot").tag(SCNLight.LightType.spot)
                            }.onChange(of: settings.lightType) { newValue in
                                settings.modifyLightType(newValue)
                            }
                        }
                        HStack {
                            Text("Light intensity")
                            Slider(value: $settings.lightIntensity, in: 0...2000).onChange(of: settings.lightIntensity) { newValue in
                                settings.modifyLightIntensity(newValue)
                            }
                        }

                    }
                } header: {
                    Text("Atoms").bold()
                }
            }.navigationTitle("View")
        }
    }
}

struct AboutAtomic: View {
    var body: some View {
        VStack {
            List {
                Section {
                    Text("Atomic is a free, open-source molecular visualizer and anybody with knwoledge of macOS, iOS, Swift or SwiftUI is welcomed to participate into the project.")
                    Link("GitHub", destination: URL(string: "https://github.com/chdominguez/Atomic")!)
                } header: {
                    Text("Contribute")
                }
                Section {
                    Text("MIT License. Copyright (c) 2022 Atomic")
                } header: {
                    Text("License")
                }
                Section {
                    Text("Atomic \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
                } header: {
                    Text("Version")
                }
            }
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
