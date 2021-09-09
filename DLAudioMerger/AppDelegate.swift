//
//  AppDelegate.swift
//  DLAudioMerger
//
//  Created by apple on 2021/8/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    lazy var mainWindowController: DLBaseWindow = {
        let mainWin = DLBaseWindow()
        return mainWin
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            mainWindowController.window?.makeKeyAndOrderFront(self)
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

