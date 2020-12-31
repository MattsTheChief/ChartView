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
    public var valueSpecifier: String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
	
	@State private var magnifierContext: MagnifierContext = MagnifierContext()
	@GestureState private var dragLocation: CGPoint = .zero
	
	private let yAxisWidth: CGFloat = 50.0
    
    public init(data: [(String, Double)],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String? = "%.1f") {
        
        self.data = ChartData(values: data)
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier!
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group{
                    if (self.title != nil){
                        Text(self.title!)
                            .font(.title)
                            .bold().foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if (self.legend != nil){
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                    }
                }.offset(x: 0, y: 20)
                ZStack{
                    GeometryReader{ reader in
                        Rectangle()
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                        if self.showLegend {
                            Legend(data: self.data,
								   valueSpecifier: valueSpecifier,
								   frame: .constant(reader.frame(in: .local)),
								   hideHorizontalLines: self.$magnifierContext.hideHorizontalLines)
                                .transition(.opacity)
                                .animation(Animation.easeOut(duration: 1).delay(1))
                        }
                        Line(data: self.data,
                             frame: .constant(CGRect(x: yAxisWidth,
													 y: 0,
													 width: reader.frame(in: .local).width - yAxisWidth,
													 height: reader.frame(in: .local).height)),
							 touchLocation: self.$magnifierContext.indicatorLocation,
							 showIndicator: self.$magnifierContext.hideHorizontalLines,
                             minDataValue: .constant(nil),
                             maxDataValue: .constant(nil),
                             showBackground: false,
                             gradient: self.style.gradientColor
                        )
						.offset(x: yAxisWidth)
                        .onAppear(){
                            self.showLegend = true
                        }
                        .onDisappear(){
                            self.showLegend = false
                        }
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 240)
                    .offset(x: 0, y: 40)
					MagnifierRect(
						selectedPoint: self.$magnifierContext.selectedPoint,
						valueSpecifier: self.valueSpecifier
					)
						.opacity(self.magnifierContext.opacity)
						.offset(x: self.magnifierContext.dragLocation.x - geometry.frame(in: .local).size.width/2, y: 36)
                }
                .frame(width: geometry.frame(in: .local).size.width, height: 240)
                .gesture(DragGesture()
					.updating($dragLocation) { value, state, transaction in
						state = value.location
					}
                )
            }
			.onChange(of: dragLocation) { newValue in
				
				guard newValue.x >= yAxisWidth,
					  newValue.x < geometry.frame(in: .local).size.width else {
					magnifierContext = MagnifierContext()
					return
				}
				
				magnifierContext = MagnifierContext(opacity: 1.0,
													dragLocation: newValue,
													selectedPoint: self.getSelectedDataPoint(toPoint: newValue,
																							 width: geometry.frame(in: .local).size.width - yAxisWidth),
													indicatorLocation: CGPoint(x: max(newValue.x, 0), y: 32),
													hideHorizontalLines: true)
			}
        }
    }
	
	func getSelectedDataPoint(toPoint: CGPoint, width: CGFloat) -> (String, Double) {
		let points = self.data.points
		let stepWidth: CGFloat = width / CGFloat(points.count)
				
		let index = Int(floor((toPoint.x-yAxisWidth)/stepWidth))
		if index >= 0 && index < points.count {
			return points[index]
		}
		
		return ("", 0.0)
	}
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LineView(data: [("a", 8), ("b", 23), ("c", 54)], title: "Full chart", style: Styles.lineChartStyleOne)
        }
    }
}

// MARK: - MagnifierContext
class MagnifierContext: ObservableObject {
	@Published var opacity: Double
	@Published var dragLocation: CGPoint
	@Published var selectedPoint: (String, Double)
	@Published var indicatorLocation: CGPoint
	@Published var hideHorizontalLines: Bool
	
	init(opacity: Double = 0.0,
		 dragLocation: CGPoint = .zero,
		 selectedPoint: (String, Double) = ("", 0.0),
		 indicatorLocation: CGPoint = .zero,
		 hideHorizontalLines: Bool = false) {
		self.opacity = opacity
		self.dragLocation = dragLocation
		self.selectedPoint = selectedPoint
		self.indicatorLocation = indicatorLocation
		self.hideHorizontalLines = hideHorizontalLines
	}
}
