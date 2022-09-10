//
//  Settings.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 04.09.2022.
//

import Foundation

class Settings {
   
    var monitoringStatus: MonitoringStatus?
    var monitoringType: MonitoringType = .byCalendar
    var startTimerDate: Date?
    var timer: Date?
    var activeBrowser: String?
    
    var timerValueLabel: Int?
    
    var countdownInterval: Double {
        guard let timerUnwrapped = timer, let dateUnwrapped = startTimerDate else {
            return 0.0
        }
        return timerUnwrapped.timeIntervalSinceReferenceDate - dateUnwrapped.timeIntervalSinceReferenceDate
    }
    
    var dateTime: Date?
    
    init() {}
}
