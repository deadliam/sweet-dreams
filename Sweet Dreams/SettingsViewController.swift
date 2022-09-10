//
//  QuotesViewController.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 26.08.2022.
//

import Foundation
import AppKit

class SettingsViewController: NSViewController {
    
    @IBOutlet var errorLabel: NSTextField!
    @IBOutlet var sleepDateTimePicker: NSDatePicker!
    @IBOutlet var sleepTimerPicker: NSDatePicker!
    @IBOutlet var browserLabel: NSTextField!
    @IBOutlet var countdownLabel: NSTextField!
    @IBOutlet var dateTimeRadioButton: NSButton!
    @IBOutlet var timerRadioButton: NSButton!
    @IBOutlet var browserRadioButton: NSButton!
    
    var settings: Settings?
    
    required init(settings: Settings) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func setupUI() {
        errorLabel.isHidden = true
        browserRadioButton.state = .on
        if let activeBrowser = settings?.activeBrowser {
            browserLabel.stringValue = activeBrowser
        }
        
        setupTimerValues()
        setupDateTimeValues()
    }
    
    func setupTimerValues() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: "00:00")
        sleepTimerPicker.dateValue = date!
        settings?.startTimerDate = date!
        settings?.timer = sleepTimerPicker.dateValue
        countdownLabel.isHidden = true
    }
    
    func setupDateTimeValues() {
        settings?.dateTime = sleepDateTimePicker.dateValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self,
            selector: #selector(self.handleCountdownTimer(_:)),
            name: NSNotification.Name("TimerValueNotification"),
            object: nil)
        
        defaultCenter.addObserver(self,
            selector: #selector(self.handleCountdownTimerStatus(_:)),
            name: NSNotification.Name("TimerValueNotificationStatus"),
            object: nil)
        
        defaultCenter.addObserver(self,
            selector: #selector(self.handleBrowserNameLabel(_:)),
            name: NSNotification.Name("ActiveBrowserName"),
            object: nil)
        
        defaultCenter.addObserver(self,
            selector: #selector(self.handleBrowserStatus(_:)),
            name: NSNotification.Name("BrowserStatusNotActive"),
            object: nil)
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    @objc func handleCountdownTimer(_ sender: AnyObject) {
        guard let value = self.settings?.timerValueLabel else {
            return
        }
        let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(value)
        var hoursString = "00"
        var minutesString = "00"
        var secondsString = "00"
        if hours != 0 {
            if hours < 10 {
                hoursString = "0\(hours)"
            } else {
                hoursString = "\(hours)"
            }
        }
        if minutes != 0 {
            if minutes < 10 {
                minutesString = "0\(minutes)"
            } else {
                minutesString = "\(minutes)"
            }
            
        }
        if seconds != 0 {
            if seconds < 10 {
                secondsString = "0\(seconds)"
            } else {
                secondsString = "\(seconds)"
            }
        }
        DispatchQueue.main.sync {
            countdownLabel.isHidden = false
            countdownLabel.stringValue = "\(hoursString):\(minutesString):\(secondsString)"
        }
    }
    
    @objc func handleCountdownTimerStatus(_ sender: AnyObject) {
        guard let status = self.settings?.monitoringStatus else {
            return
        }
        DispatchQueue.main.sync {
            if status == .isNotActive {
                countdownLabel.isHidden = true
            }
        }
    }
    
    @objc func handleBrowserNameLabel(_ sender: AnyObject) {
        guard let browserName = self.settings?.activeBrowser else {
            return
        }
        DispatchQueue.main.sync {
            browserLabel.isHidden = false
            browserLabel.stringValue = "🎬 \(browserName)"
        }
    }
    
    @objc func handleBrowserStatus(_ sender: AnyObject) {
        DispatchQueue.main.sync {
            browserLabel.isHidden = true
        }
    }
    
    @IBAction func radioButtonChanged(_ sender: AnyObject) {
        if browserRadioButton.state == .on {
            settings?.monitoringType = .byBrowser
        } else if timerRadioButton.state == .on {
            settings?.monitoringType = .byTimer
        } else if dateTimeRadioButton.state == .on {
            settings?.monitoringType = .byCalendar
        }
    }
    
    @IBAction func dateTimeChanged(_ sender: AnyObject) {
        settings?.dateTime = sleepDateTimePicker.dateValue
    }
    
    @IBAction func timerChanged(_ sender: AnyObject) {
        settings?.timer = sleepTimerPicker.dateValue
    }
    
    func printError(error: String) {
        errorLabel.isHidden = false
        errorLabel.textColor = .red
        errorLabel.stringValue = error
    }
}
