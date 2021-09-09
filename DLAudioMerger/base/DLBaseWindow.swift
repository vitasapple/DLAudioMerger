//
//  DLBaseWindow.swift
//  DLAudioMerger
//
//  Created by apple on 2021/8/25.
//

import Cocoa

class DLBaseWindow: NSWindowController {

    lazy var mainViewController: DLMainViewCtr = {
        let mainVc = DLMainViewCtr()
        return mainVc
    }()
    override func windowDidLoad() {
        super.windowDidLoad()
        
        contentViewController = mainViewController
        window?.delegate = self
    }
    override var windowNibName: NSNib.Name? {
        return NSNib.Name("DLBaseWindow")
    }
    
}
extension DLBaseWindow: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true;
    }
}
