//
//  LineView.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier:String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    
    public init(data: [Double],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f") {
        
        self.data = ChartData(points: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {

                ZStack(alignment: .top) {
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                        if(self.showLegend){
                            Legend(data: self.data,
                                   frame: .constant(reader.frame(in: .local)), hideHorizontalLines: self.$hideHorizontalLines)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1).delay(1))
                        }
                        Line(data: self.data,
                             frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width - 30, height: reader.frame(in: .local).height)),
                             touchLocation: self.$indicatorLocation,
                             showIndicator: self.$hideHorizontalLines,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil),
                             showBackground: false
                        )
                        .offset(x: 30, y: 0)
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                    }
                }
 
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataNumber = points[index]
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(data: [8,23,54,32,12,37,7,23,43], title: "Full chart", style: Styles.lineChartStyleOne)
    }
}

