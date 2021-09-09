//
//  DLMainAudioItem.swift
//  DLAudioMerger
//
//  Created by apple on 2021/8/26.
//

import Cocoa

class DLMainAudioItem: NSCollectionViewItem {

    @IBOutlet weak var nameLab: NSTextField!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    var name : String? {
        didSet{
            nameLab.stringValue = name ?? ""
            contentHeight.constant = (name?.sizeWithFont(font: .systemFont(ofSize: 13), maxSize: self.view.frame.size).height)!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        self.view.layer?.cornerRadius = 5
    }
    
}
