//
//  StatusMenuController.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 07.08.2022.
//

import Foundation
import Cocoa

enum MonitoringStatus: String {
    case isNotActive = "Start"
    case isActive = "Stop"
}

enum MonitoringType {
    case byTimer
    case byCalendar
    case byBrowser
}

protocol StatusMenuControllerDelegate: AnyObject {
    var monitoringStatus: MonitoringStatus {get set}
    var monitoringType: MonitoringType? {get set}
}

class StatusMenuController {
    
    weak var statusDelegate: StatusMenuControllerDelegate?
    var settings: Settings
    var settingsViewController: SettingsViewController
    
    var statusItem: NSStatusItem
    let popover = NSPopover()
    
    init(image: NSImage, settings: Settings, settingsViewController: SettingsViewController) {
        self.statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        self.statusItem.button?.image = image
        self.settings = settings
        self.settingsViewController = settingsViewController
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStatusMenu() {
        statusItem.button?.target = self
        statusItem.button?.action = #selector(self.statusBarButtonClicked(_:))
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseUp])
        popover.behavior = .transient
    }
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
//            print("Right Click")
            togglePopover(sender)
//            statusItem.menu = nil
        } else {
//            print("Left Click")
            showMenu()
        }
    }
    
    func showMenu() {
        let menu = NSMenu()
        
        guard let actionTitle = statusDelegate?.monitoringStatus.rawValue else {
            return
        }
        let actionItem = NSMenuItem(title: "\(actionTitle)", action: #selector(toggleAction(_:)), keyEquivalent: "s")
        actionItem.target = self
        menu.addItem(actionItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.popUpMenu(menu)
    }
    
    @objc func toggleAction(_ sender: Any?) {
        
        if statusDelegate?.monitoringStatus == MonitoringStatus.isNotActive {
            statusDelegate?.monitoringStatus = .isActive
        } else {
            statusDelegate?.monitoringStatus = .isNotActive
        }
    }
        
    @objc func togglePopover(_ sender: Any?) {
        popover.contentViewController = settingsViewController
        
//        settingsViewController.statusDelegate = settings
        
        
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    @objc func showPopover(_ sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    func closePopover(_ sender: Any?) {
        popover.performClose(sender)
    }
    
    @objc func updateStatus() {
        if statusDelegate?.monitoringStatus == .isActive {
            self.statusItem.button?.image = NSImage(named: NSImage.Name("StatusItemIconIsActive"))
        } else {
            self.statusItem.button?.image = NSImage(named: NSImage.Name("StatusItemIcon"))
        }
    }
}

extension NSEvent {
    var isRightClickUp: Bool {
        let rightClick = (self.type == .rightMouseUp)
        let controlClick = self.modifierFlags.contains(.control)
        return rightClick || controlClick
    }
}
