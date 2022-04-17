//
//  ChartView.swift
//  Atomic
//
//  Created by Christian Dominguez on 17/4/22.
//

import SwiftUI

import LineChartView

struct AtomicLineChartView: View {
    
    let paramenters: LineChartParameters
    
    init(data: [Double]) {
        let color = GlobalSettings.shared.colorSettings.chartColor
        self.paramenters = LineChartParameters(data: data, indicatorPointColor: .purple, indicatorPointSize: 20, lineColor: color, dotsWidth: 15)
    }
    
    var body: some View {
        LineChartView(lineChartParameters: paramenters)
    }
}

