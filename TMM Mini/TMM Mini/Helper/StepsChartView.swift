//
//  StepsChartView.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import SwiftUI
import Charts

// MARK: - Daily Data Model
struct DailyData: Identifiable {
    let id = UUID()
    let date: Date
    let weekday: String
    let steps: Double
    let calories: Double
    
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, Wed, etc.
        return formatter.string(from: date)
    }
}

// MARK: - Chart Value Type
enum ChartValueType {
    case steps
    case calories
}

// MARK: - 7-Day Bar Chart View
@available(iOS 16.0, *)
struct DailyBarChartView: View {
    let data: [DailyData]
    let accentColor: Color
    let valueType: ChartValueType
    
    // Default to steps if not specified (for backward compatibility)
    init(data: [DailyData], accentColor: Color, valueType: ChartValueType = .steps) {
        self.data = data
        self.accentColor = accentColor
        self.valueType = valueType
    }
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Day", item.shortWeekday),
                y: .value(valueType == .steps ? "Steps" : "Calories", getValue(for: item)),
                width: .fixed(24)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [accentColor, accentColor.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(preset: .aligned) { value in
                AxisValueLabel {
                    if let weekday = value.as(String.self) {
                        Text(weekday)
                            .font(Font(AppFont.font(type: .I_Medium, size: 12)))
                            .foregroundColor(.gray)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                    .foregroundStyle(Color.gray.opacity(0.3))
            }
        }
        .chartYScale(domain: 0...getMaxValue())
        .chartXScale(range: .plotDimension(padding: 16))
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
        .frame(height: 160)
    }
    
    // Get value based on type
    private func getValue(for item: DailyData) -> Double {
        switch valueType {
        case .steps:
            return item.steps
        case .calories:
            return item.calories
        }
    }
    
    // Calculate max based on value type
    private func getMaxValue() -> Double {
        let values = data.map { getValue(for: $0) }
        let max = values.max() ?? (valueType == .steps ? 1000 : 100)
        return max * 1.2
    }
}

// MARK: - Fallback view for iOS 15
struct FallbackChartView: View {
    let data: [DailyData]
    let accentColor: Color
    
    var body: some View {
        VStack {
            Text("Chart requires iOS 16+")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .frame(height: 160)
    }
}

// MARK: - Keep old HourlyData for backward compatibility if needed
struct HourlyData: Identifiable {
    let id = UUID()
    let hour: Int
    let value: Double
}
