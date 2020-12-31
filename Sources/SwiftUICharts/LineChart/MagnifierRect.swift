//
//  MagnifierRect.swift
//  
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

public struct MagnifierRect: View {
    @Binding var selectedPoint: (String, Double)
    let valueSpecifier: String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
	
    public var body: some View {
        ZStack {
			Text("\(self.selectedPoint.1, specifier: valueSpecifier)")
				.font(.system(size: 14, weight: .medium))
                .offset(x: 0, y: -110)
                .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
			Text(self.selectedPoint.0)
				.font(.system(size: 14, weight: .light))
				.offset(x: 0, y: -88)
				.foregroundColor(Color(.systemGray))
            if self.colorScheme == .dark {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: self.colorScheme == .dark ? 2 : 0)
                    .frame(width: 66, height: 260)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 66, height: 280)
                    .foregroundColor(Color.white)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                    .blendMode(.multiply)
            }
        }
    }
}
