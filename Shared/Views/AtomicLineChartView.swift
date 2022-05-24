//
//  ChartView.swift
//  Atomic
//
//  Created by Christian Dominguez on 17/4/22.
//

import SwiftUI

import LineChartView

struct AtomicLineChartView: View {
    
    let parameters: LineChartParameters
    
    init(data: [Double]) {
        let color = GlobalSettings.shared.colorSettings.chartColor
        self.parameters = LineChartParameters(data: data, dataPrecisionLength: 6, indicatorPointColor: .purple, indicatorPointSize: 20, lineColor: color, dotsWidth: 15)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Energy").font(.headline)
            LineChartView(lineChartParameters: parameters).border(Color.primary).padding()
        }
    }
}

