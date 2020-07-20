//
//  HeartRateViewController.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

final class HeartRateViewController: UIViewController {
    
    @IBOutlet weak private var lineChartView: LineChartView!
    
    private var chartDataEntries: [ChartDataEntry] = []
    
    var presenter: HeartRatePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
    }
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        presenter?.didTapActionButton()
    }
}

// MARK: - HeartRateViewProtocol
extension HeartRateViewController: HeartRateViewProtocol {
    func updateGraph(with luminanceValues: [CGFloat]) {
        var values: [ChartDataEntry] = []
        
        for (index, value) in luminanceValues.enumerated() {
            values.append(ChartDataEntry(x: Double(index), y: Double(value)))
        }
        
        let dataSet = LineChartDataSet(entries: values, label: "DataSet 1")
        
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawFilledEnabled = false
        dataSet.mode = .linear //.cubicBezier
        dataSet.drawValuesEnabled = false
        dataSet.lineWidth = 2
        dataSet.setColor(.red)
        
        lineChartView.data = LineChartData(dataSet: dataSet)
    }
}
