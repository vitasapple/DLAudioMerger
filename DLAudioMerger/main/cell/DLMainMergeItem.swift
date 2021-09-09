//
//  DLMainMergeItem.swift
//  DLAudioMerger
//
//  Created by apple on 2021/8/26.
//

import Cocoa

typealias block = () -> ()

class DLMainMergeItem: NSCollectionViewItem {
    
    
    var callBlock : block?
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var bgView: NSView!
    @IBOutlet weak var nameLab: NSTextField!
    var name : String? {
        didSet{
            nameLab.stringValue = name ?? ""
            contentHeight.constant = (name?.sizeWithFont(font: .systemFont(ofSize: 13), maxSize: self.view.frame.size).height)!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.wantsLayer = true
        bgView.layer?.cornerRadius = 5
        bgView.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    @IBAction func delBtnClick(_ sender: Any) {
        
        if callBlock != nil {
            callBlock!()
        }
    }
}
