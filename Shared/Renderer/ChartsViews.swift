//
//  ChartsViews.swift
//  ChemStats
//
//  Created by Christian Dominguez on 17/05/2021.
//

import SwiftUI

#warning("TODO: Implement charts for energy vs steps")
//struct EnergyChart: UIViewRepresentable {
//        
//    var entries = [ChartDataEntry]()
//       
//    init(steps: [Step]) {
//        for count in 0..<steps.count {
//            if steps[count].energy != 0 {
//                self.entries.append(ChartDataEntry(x: Double(count), y: steps[count].energy))
//            }
//        }
//    }
//    
//    func makeUIView(context: Context) -> LineChartView {
//        return LineChartView()
//    }
//    
//    func updateUIView(_ uiView: LineChartView, context: Context) {
//        
//        let lineDataSet = LineChartDataSet(entries: entries)
//        let data = LineChartData(dataSet: lineDataSet)
//       
//        uiView.data = data
//        uiView.xAxis.labelTextColor = .label
//        uiView.leftAxis.labelTextColor = .label
//        
//        formatLineChart(dataSet: lineDataSet)
//
//    }
//    
//    func formatLineChart(dataSet: LineChartDataSet) {
//        dataSet.colors = [UIColor.blue]
//    }
//        
//}
