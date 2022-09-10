//
//  AppDelegate.swift
//  Sweet Dreams
//
//  Created by Anatolii Kasianov on 07.08.2022.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var settings: Settings = Settings()
    var timerAction: TimerAction
    let settingsViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        .instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SettingsViewController")) as! SettingsViewController
        
    private(set) var image = NSImage(named: NSImage.Name("StatusItemIcon"))!
    lazy var menu = StatusMenuController(image: image, settings: settings, settingsViewController: settingsViewController)
    
    override init() {
        timerAction = TimerAction(settings: settings)
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        settingsViewController.settings = settings

        menu.statusDelegate = timerAction
        timerAction.run()
        menu.setupStatusMenu()
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
