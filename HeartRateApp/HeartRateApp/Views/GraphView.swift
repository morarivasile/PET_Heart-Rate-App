//
//  GraphView.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 18/11/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    typealias Attributes = [NSAttributedString.Key: Any]
    
    var inputData: [InputData] = [] {
        didSet { setNeedsDisplay() }
    }
    
    var viewType: IntervalType = .day {
        didSet { setNeedsDisplay() }
    }
    
    private let maxValue: CGFloat = 200.0
    
    // number of y axis labels
    private let yDivisions: CGFloat = 5.0
    
    // margin between lines
    private var gap: CGFloat {
        return bounds.height / (yDivisions + 1)
    }
    
    private var dayHours: [String] {
        return Array(0...24).map {
            return $0 <= 12 ? String(format: "%02d AM", $0) : String(format: "%02d PM", (12 - (24 - $0)))
        }
    }
    
    private var weekDates: [Date] { lastDates(datesNumber: 7) }
    
    private var monthDates: [Date] { lastDates(datesNumber: 30) }
    
    private var yearDivisionDates: [Date] {
        let currentDate = Date()
        var dates: [Date] = []
        
        for i in 0...12 {
            if let newDate = Calendar.current.date(byAdding: .month, value: -(12 - i), to: currentDate) {
                dates.append(newDate)
            }
        }
        
        return dates
    }
    
    // averaged value spread over y Divisions
    private var eachLabel: CGFloat {
        return maxValue / (yDivisions-1)
    }
    
    var data: [CGPoint] {
        var points: [CGPoint] = []
        
        switch viewType {
        case .day:
            let filteredData = inputData.filter { Calendar.current.isDateInToday($0.date) }
            let grouppedData = Dictionary(grouping: filteredData, by: { Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0.date)})
            
            for data in grouppedData {
                guard let lastValue = data.value.sorted(by: { $0.date < $1.date }).last else { continue }
                let hour = Calendar.current.component(.hour, from: lastValue.date)
                let minutes = Calendar.current.component(.minute, from: lastValue.date)
                
                let drawingWidth = bounds.width - maxYAxisTextWidth - 32
                let divisionWidth = drawingWidth / CGFloat(viewType.divisionsCount)
                
                let initialWidth = CGFloat(hour) * divisionWidth
                let additionalWidth = minutes == 0 ? 0 : divisionWidth / (60 / CGFloat(minutes))
                
                let drawingHeight = gap * (yDivisions - 1)
                
                let point = CGPoint(x: initialWidth + additionalWidth, y: drawingHeight * CGFloat(lastValue.value) / 200)
                
                points.append(point)
            }
        case .week:
            let filteredData = inputData.filter { (weekDates[1]...Calendar.current.endOfDay()).contains($0.date) }
            let grouppedData = Dictionary(grouping: filteredData, by: { Calendar.current.dateComponents([.year, .month, .day], from: $0.date)})
            
            for data in grouppedData {
                if data.value.count > 1 {
                    let values = data.value.map { $0.value }
                    let avgValue = values.reduce(0, +) / values.count
                    let firstDate = data.value.first!.date
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

                    let dayDifference = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: firstDate), to: Calendar.current.startOfDay(for: tomorrow)).day!

                    let drawingWidth = bounds.width - maxYAxisTextWidth - 32
                    let divisionWidth = drawingWidth / CGFloat(viewType.divisionsCount)

                    let initialWidth = drawingWidth - (CGFloat(dayDifference) * divisionWidth)

                    let drawingHeight = gap * (yDivisions - 1)

                    let point = CGPoint(x: initialWidth, y: drawingHeight * CGFloat(avgValue) / 200)

                    points.append(point)
                } else {
                    guard let inputData = data.value.first else { continue }
                    
                    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                    
                    let dayDifference = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: inputData.date), to: Calendar.current.startOfDay(for: tomorrow)).day!
                    
                    let drawingWidth = bounds.width - maxYAxisTextWidth - 32
                    let divisionWidth = drawingWidth / CGFloat(viewType.divisionsCount)
                    let hour = Calendar.current.component(.hour, from: inputData.date)
                    
                    let initialWidth = drawingWidth - (CGFloat(dayDifference) * divisionWidth)
                    let additionalWidth = hour == 0 ? 0 : divisionWidth / (24 / CGFloat(hour))
                    
                    let drawingHeight = gap * (yDivisions - 1)
                    
                    let point = CGPoint(x: initialWidth + additionalWidth, y: drawingHeight * CGFloat(inputData.value) / 200)
                    
                    points.append(point)
                }
            }
        case .month:
            let filteredData = inputData.filter { (monthDates[1]...Calendar.current.endOfDay()).contains($0.date) }
            let grouppedData = Dictionary(grouping: filteredData, by: { Calendar.current.dateComponents([.year, .month, .day], from: $0.date)})
            
            for data in grouppedData {
                let values = data.value.map { $0.value }
                let avgValue = values.reduce(0, +) / values.count
                let firstDate = data.value.first!.date
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

                let dayDifference = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: firstDate), to: Calendar.current.startOfDay(for: tomorrow)).day!

                let drawingWidth = bounds.width - maxYAxisTextWidth - 32
                let divisionWidth = drawingWidth / CGFloat(viewType.divisionsCount)

                let initialWidth = drawingWidth - (CGFloat(dayDifference) * divisionWidth)

                let drawingHeight = gap * (yDivisions - 1)

                let point = CGPoint(x: initialWidth, y: drawingHeight * CGFloat(avgValue) / 200)

                points.append(point)
            }
        case .year:
            guard let firstDate = yearDivisionDates.first else { break }
            
            let filteredData = inputData.filter { (firstDate...Calendar.current.endOfDay()).contains($0.date) }
            
            let grouppedData = Dictionary(grouping: filteredData, by: { Calendar.current.dateComponents([.year, .month], from: $0.date)})
            
            for data in grouppedData {
                let values = data.value.map { $0.value }
                let avgValue = values.reduce(0, +) / values.count
                let firstDate = data.value.first!.date
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

                let monthDifference = Calendar.current.dateComponents([.month], from: Calendar.current.startOfMonth(for: firstDate), to: nextMonth).month!

                let drawingWidth = bounds.width - maxYAxisTextWidth - 32
                let divisionWidth = drawingWidth / CGFloat(viewType.divisionsCount)

                let initialWidth = drawingWidth - (CGFloat(monthDifference) * divisionWidth)

                let drawingHeight = gap * (yDivisions - 1)

                let point = CGPoint(x: initialWidth, y: drawingHeight * CGFloat(avgValue) / 200)

                points.append(point)
            }
        }
        
        return points.sorted(by: { $0.x < $1.x })
    }
    
    private lazy var yAxisText = Array(0..<5).map { i -> (NSString, Attributes, CGSize) in
        let text = NSString(string: Int(maxValue - eachLabel * CGFloat(i)).description)
        let attributes = attributesForYAxisFont(at: i)
        let size = text.size(withAttributes: attributes)
        return (text, attributes, size)
    }
    
    private lazy var maxYAxisTextWidth = yAxisText.map { $0.2.width }.max() ?? 0
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawText(context: context)
        drawHorizontalDivisions(context: context)

        if !data.isEmpty {
            context.saveGState()
            
            context.translateBy(x: maxYAxisTextWidth + 21, y: 0)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -bounds.height)
            context.translateBy(x: 0, y: gap)

            
            let clipPath = UIBezierPath()
            clipPath.interpolatePointsWithHermite(interpolationPoints: data)

            clipPath.addLine(to: CGPoint(x: bounds.width - maxYAxisTextWidth - 32, y: 0))
            clipPath.addLine(to: .zero)
            clipPath.close()
            clipPath.addClip()

            drawGradient(context: context)
            context.restoreGState()

            context.saveGState()
            
            context.translateBy(x: maxYAxisTextWidth + 21, y: 0)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: 0, y: -bounds.height)
            context.translateBy(x: 0, y: gap)

            
            let path = UIBezierPath()
            path.interpolatePointsWithHermite(interpolationPoints: data)
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.75).cgColor)
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.stroke()
            context.restoreGState()

            drawCircles(context: context)
        }
    }
    
    func drawGradient(context: CGContext) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors: NSArray = [UIColor.white.withAlphaComponent(0.0).cgColor, UIColor.white.withAlphaComponent(0.8).cgColor]
        let locations: [CGFloat] = [0.0, 0.5]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors,
                                  locations: locations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient!,
                                   start: startPoint,
                                   end: endPoint, options: [])
    }
    
    func drawText(context: CGContext) {
        context.saveGState()
        
        for i in 0..<5 {
            
            let attributes = yAxisText[i].1
            let string = yAxisText[i].0
            let textSize = yAxisText[i].2
            
            context.translateBy(x: 0, y: gap)
            
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            context.setLineWidth(1)
            context.addLines(between: [CGPoint(x: 10 + maxYAxisTextWidth + 10, y: 0),
                                       CGPoint(x: bounds.width - 10, y: 0)])
            context.strokePath()
            
            string.draw(at: CGPoint(x: maxYAxisTextWidth + 20 - textSize.width - 10 , y: -textSize.height/2), withAttributes: attributes)
        }
        context.restoreGState()
    }
    
    func drawHorizontalDivisions(context: CGContext) {
        context.saveGState()
        
        context.translateBy(x: maxYAxisTextWidth + 20 + 1, y: gap * 5 + 10)
        
        let columnWidth: CGFloat = (bounds.width - maxYAxisTextWidth - 32) / CGFloat(viewType.divisionsCount)
        
        for i in 0...viewType.divisionsCount {
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
            context.setLineWidth(2)
            
            switch viewType {
            case .day:
                if i == 0 || i % 6 == 0 {
                    context.setStrokeColor(UIColor.white.cgColor)
                }
                
                if i > 0 && i < viewType.divisionsCount && i % 6 == 0 {
                    let text = NSString(string: dayHours[i])
                    let size = text.size(withAttributes: attributesForXAxisFont())
                    text.draw(at: .init(x: -size.width / 2, y: size.height / 2), withAttributes: attributesForXAxisFont())
                }
            case .week:
                context.setStrokeColor(UIColor.white.cgColor)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM"
                
                if i > 0 && i < viewType.divisionsCount {
                    let text = NSString(string: formatter.string(from: weekDates[i + 1]))
                    let size = text.size(withAttributes: attributesForXAxisFont())
                    text.draw(at: .init(x: -size.width / 2, y: size.height / 2), withAttributes: attributesForXAxisFont())
                }
            case .month:
                if i == 0 || i % 5 == 0 {
                    context.setStrokeColor(UIColor.white.cgColor)
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM"
                
                if i > 0 && i < viewType.divisionsCount && i % 5 == 0 {
                    let text = NSString(string: formatter.string(from: monthDates[i + 1]))
                    let size = text.size(withAttributes: attributesForXAxisFont())
                    text.draw(at: .init(x: -size.width / 2, y: size.height / 2), withAttributes: attributesForXAxisFont())
                }
            case .year:
                context.setStrokeColor(UIColor.white.cgColor)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                
                if i > 0 && i < viewType.divisionsCount && i % 2 != 0 {
                    let text = NSString(string: formatter.string(from: yearDivisionDates[i + 1]))
                    let size = text.size(withAttributes: attributesForXAxisFont())
                    text.draw(at: .init(x: -size.width / 2, y: size.height / 2), withAttributes: attributesForXAxisFont())
                }
            }
            
            context.addLines(between: [CGPoint(x: 0, y: -3),
                                       CGPoint(x: 0, y: 3)])
            context.strokePath()
            
            context.translateBy(x: columnWidth, y: 0)
        }
        
        context.restoreGState()
    }
    
    func drawCircles(context: CGContext) {
        let circleWidth: CGFloat = 10.0
        
        context.saveGState()
        context.setFillColor(UIColor(red: 252/255.0, green: 115/255.0, blue: 109/255.0, alpha: 1.0).cgColor)
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        
        context.translateBy(x: maxYAxisTextWidth + 21 - circleWidth / 2, y: circleWidth / 2)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -bounds.height)
        context.translateBy(x: 0, y: gap)
        
        for point in data {
            context.addEllipse(in: CGRect(x: point.x, y: point.y, width: circleWidth, height: circleWidth))
        }
        
        context.drawPath(using: .fillStroke)
        context.restoreGState()
    }
    
    func attributesForXAxisFont() -> Attributes {
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: UIColor.white]
    }
    
    func attributesForYAxisFont(at index: Int) -> Attributes {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        attributes[.font] = UIFont.systemFont(ofSize: 13, weight: .heavy)
        
        switch index {
        case 4:
            attributes[.foregroundColor] = UIColor.init(white: 70.0, alpha: 50.0)
        case 3:
            attributes[.foregroundColor] = UIColor.systemGreen
        case 2:
            attributes[.foregroundColor] = UIColor.systemYellow
        case 1:
            attributes[.foregroundColor] = UIColor.systemOrange
        case 0:
            attributes[.foregroundColor] = UIColor.systemRed
        default:
            break
        }
        
        return attributes
    }
    
    private func lastDates(from date: Date = Calendar.current.startOfDay(for: Date()), datesNumber: Int) -> [Date] {
        var dates: [Date] = []
        
        for i in 0...datesNumber {
            if let newDate = Calendar.current.date(byAdding: .day, value: -(datesNumber - i), to: date) {
                dates.append(newDate)
            }
        }
        
        return dates
    }
    
}

extension GraphView {
    struct InputData {
        let date: Date
        let value: Int
    }
}

