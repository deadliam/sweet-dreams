//
//  TimerAction.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 09.06.2022.
//

import Foundation
import IOKit
import AVFoundation
import Cocoa

class TimerAction: StatusMenuControllerDelegate {    
        
    var monitoringType: MonitoringType?
    var monitoringStatus: MonitoringStatus = .isNotActive
    
    var actionTimer = Timer()
    let actionTimerInterval = 2.0
    
    let sleepIdleThreshold: CFTimeInterval = 5.0
    var shouldGoToSleep: Bool = false
    var idleTimeInterval: CFTimeInterval?
        
    var browserStatus: BrowserStatus?
    var previousBrowserStatus: BrowserStatus = .stopped
    
    var settings: Settings
    
    var idleTimeBeforeStop: CFTimeInterval?
    var timerCountdownInterval: Double = 30.0
    var timerinitialCountdownInterval: Double = 0.0

    enum BrowserStatus {
        case playing
        case stopped
    }
    
    init(settings: Settings) {
        self.settings = settings
    }

    func run() {
        if #available(macOS 10.12, *) {
            self.actionTimer = Timer.scheduledTimer(withTimeInterval: self.actionTimerInterval, repeats: true, block: { _ in
                self.action()
            })
        } else {
            actionTimer = Timer.scheduledTimer(
                timeInterval: actionTimerInterval,
                target: self,
                selector: #selector(action),
                userInfo: nil,
                repeats: true
            )
        }
    }

    @objc func action() {
        DispatchQueue.global(qos: .background).async {
            // print("This is run on the background queue")
            
            self.checkSleepBrowserStatus()
            self.getIdleTimeInterval()

            self.updateTimerCountdownIntervalIfChanged()
            
            // DateTime condition
            if self.settings.monitoringType == .byCalendar && self.monitoringStatus == .isActive {
                let date = Date()
                if self.settings.dateTime?.zeroSeconds == date.zeroSeconds {
                    self.shouldGoToSleep = true
                }
            }
            
            // Timer condition
            if self.settings.monitoringType == .byTimer && self.monitoringStatus == .isActive {
                if self.timerCountdownInterval < 0.0 {
                    self.shouldGoToSleep = true
                }
                if self.timerCountdownInterval >= 0.0 {
                    self.timerCountdownInterval -= self.actionTimerInterval
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TimerValueNotification"), object: nil)
                    self.settings.timerValueLabel = Int(self.timerCountdownInterval)
                    print("TIME: \t\t\(self.timerCountdownInterval)")
                }
            }
            
            // Browser condition
            if let idleTime = self.idleTimeInterval,
                idleTime > self.sleepIdleThreshold,
               self.previousBrowserStatus == .playing,
                self.browserStatus == .stopped {
                // go to sleep
                self.shouldGoToSleep = true
            }
            
            self.sleepIfNeeded()
            
            // Set precious browser state
            guard let currentStatus = self.browserStatus else {
                return
            }
            self.previousBrowserStatus = currentStatus
            
            DispatchQueue.main.async {
                // print("This is run on the main queue, after the previous code in outer block")
            }
        }
    }
    
    func updateTimerCountdownIntervalIfChanged() {
        if timerinitialCountdownInterval != settings.countdownInterval {
            
            timerCountdownInterval = settings.countdownInterval
            timerinitialCountdownInterval = settings.countdownInterval
        }
    }
    
    func startScreenSleep() {
        print("================ SLEEEP ==================")
        Utils.executeShellCommand(cmd: "/usr/bin/pmset", arguments: ["sleepnow"])
    }
    
    func sleepIfNeeded() {
        if monitoringStatus == .isActive {
            if shouldGoToSleep {
                setDefaultParameters()
                startScreenSleep()
            }
        }
    }
    
    func setDefaultParameters() {
        shouldGoToSleep = false
        settings.monitoringStatus = .isNotActive
        monitoringStatus = .isNotActive
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TimerValueNotificationStatus"), object: nil)
        browserStatus = .stopped
        timerCountdownInterval = settings.countdownInterval
        // set timer clock to 00:00
    }
  
    func checkSleepBrowserStatus() {
        let (pmsetOutput, _) = Utils.executeShellCommand(cmd: "/usr/bin/pmset", arguments: ["-g"])
        let lines = pmsetOutput.split(whereSeparator: \.isNewline)
        let sleepLine = lines.filter({ $0.starts(with: " sleep") })
        let displaysSleepLine = lines.filter({ $0.starts(with: " displaysleep") })
        let activeDisplaySleepProcesses = displaysSleepLine.first!.split(separator: ",")
        var activeProcesses = sleepLine.first!.split(separator: ",")
        activeProcesses.append(contentsOf: activeDisplaySleepProcesses)
//        let systemProcesses = ["coreaudiod", "useractivityd", "powerd"]
        let possibleProcesses = ["Google Chrome", "Safari"]
        
        browserStatus = .stopped
        for process in possibleProcesses {
            if !activeProcesses.filter({ $0.contains("\(process)") }).isEmpty {
                browserStatus = .playing
                settings.activeBrowser = process
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ActiveBrowserName"), object: nil)
                break
            }
        }
        if browserStatus == .stopped {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BrowserStatusNotActive"), object: nil)
        }
    }
    
    func getIdleTimeInterval() {
        var lastEvent: CFTimeInterval = 0
        lastEvent = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
        self.idleTimeInterval = lastEvent
    }
}

extension Date {

    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }

}
