//
//  DLMainViewCtr.swift
//  DLAudioMerger
//
//  Created by apple on 2021/8/25.
//

import Cocoa
import AVFoundation

class DLMainViewCtr: NSViewController, NSOpenSavePanelDelegate  {
        
    var dataArr = [DLMainAudioItemModel]()
    var fileName : String?
    var savePath : String?
    var isChoseMp3 = true
    lazy var mergeArr = { () -> Array<DLMainAudioItemModel> in
        let arr = [DLMainAudioItemModel]()
        return arr
    }()
    @IBOutlet weak var myCol: NSCollectionView!
    @IBOutlet weak var segCtr: NSSegmentedControl!
    @IBOutlet weak var myColFirst: NSScrollView!
    @IBOutlet weak var mergeColFirst: NSScrollView!
    @IBOutlet weak var mergeCol: NSCollectionView!
    @IBOutlet weak var myProg: NSProgressIndicator!
    @IBOutlet weak var fileNameTF: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        myColFirst.layer?.cornerRadius = 5
        mergeColFirst.layer?.cornerRadius = 5
        fileNameTF.layer?.cornerRadius = 5
        
        myCol.wantsLayer = true
        myCol.layer?.backgroundColor = NSColor(deviceRed:0.95, green:0.95, blue:0.95, alpha:1).cgColor
        myCol.delegate = self
        myCol.dataSource = self
        myCol.register(NSNib.init(nibNamed: NSNib.Name("DLMainAudioItem"), bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DLMainAudioItem"))
        
        mergeCol.wantsLayer = true
        mergeCol.layer?.backgroundColor = NSColor(deviceRed:0.95, green:0.95, blue:0.95, alpha:1).cgColor
        mergeCol.delegate = self
        mergeCol.dataSource = self
        mergeCol.register(NSNib.init(nibNamed: NSNib.Name("DLMainMergeItem"), bundle: nil), forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DLMainMergeItem"))
        
        fileNameTF.layer?.cornerRadius = 3
    }

    @IBAction func setCtrClick(_ sender: NSSegmentedControl) {
        if sender.indexOfSelectedItem == 0 {
            isChoseMp3 = true
        }else{
            isChoseMp3 = false
        }
    }
    @IBAction func choseAudioClick(_ sender: Any) {
        mergeArr.removeAll()
        dataArr.removeAll()
        
        let panel = NSOpenPanel()
        panel.prompt = "打开"// prompt : 修改默认打开按钮的文字
        panel.message = "不要随便选择文件"
        panel.allowedFileTypes = ["mp3","MP3"]
        panel.allowsMultipleSelection = true
//        panel.canCreateDirectories = true
        // 设置默认打开的文件路径
        let pathUrl = URL(string: "\(NSHomeDirectory())/Downloads")
        panel.directoryURL = pathUrl
        panel.delegate = self
        // 显示panel
        panel.begin { (response) in
            if response == NSApplication.ModalResponse.OK {
                for u in panel.urls {
                    let arr = u.absoluteString.components(separatedBy: "/")
                    let name = arr.last! as String
                    let arr2 = name.components(separatedBy: ".")
                    var finalName = arr2.first! as String
                    finalName = finalName.removingPercentEncoding!
                    let mo = DLMainAudioItemModel()
                    mo.name = finalName
                    mo.url = u//.replacingOccurrences(of: "file://", with: "")
                    self.dataArr.append(mo)
                }
                self.myCol.reloadData()
            }
        }
    }
    func alertMethod(msg : String){
        let alert:NSAlert = NSAlert()
        alert.messageText = msg
        alert.addButton(withTitle: "好")
        alert.alertStyle = .critical
        alert.runModal()
    }
    @IBAction func startMergeClick(_ sender: Any) {
        guard mergeArr.count > 0 else {
            alertMethod(msg: "至少选择一个音频文件到音轨")
            return
        }
        guard fileNameTF.stringValue.count > 0 else {
            alertMethod(msg: "导出文件名不能为空")
            return
        }
        generateM4a()
    }
    func generateM4a(){
        savePath = "\(NSHomeDirectory())/Downloads"
        
        var step = CMTimeMake(value: .zero, timescale: 44100)
        let compostion = AVMutableComposition()
        
        for  i in 0 ..< mergeArr.count {
            let mo = mergeArr[i]
            let asset = AVURLAsset(url: mo.url!)
            //音频轨道
            let track = compostion.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID(0))
            let assetTrackArr = asset.tracks(withMediaType: .audio)
            guard assetTrackArr.count > 0 else {
                return
            }
            let assetTrack =  assetTrackArr.first!//获取音频素材轨道
            try?track?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of:assetTrack , at: step)
            step = CMTimeMake(value: asset.duration.value + step.value, timescale: asset.duration.timescale)
        }
        let session = AVAssetExportSession(asset: compostion, presetName: AVAssetExportPresetAppleM4A)
        let outputString = "\(savePath!)/\(fileNameTF.stringValue).m4a"
        session?.outputURL = URL(fileURLWithPath: outputString)
        session?.outputFileType = .m4a
        session?.shouldOptimizeForNetworkUse = true
        
        //删除已存在的同名文件
        let mgr = FileManager.default
        let exist = mgr.fileExists(atPath: outputString)
        if exist {
            _ = Mytools.deleteFile(withPath: outputString)
        }
        
        myProg.isHidden = false
        let timer = Timer(timeInterval: 0.1, repeats: true) { (timer) in
            self.myProg.doubleValue = Double(session?.progress ?? 0.0)*100.0
        }
        RunLoop.main.add(timer, forMode: .common)
        
        session?.exportAsynchronously(completionHandler: {
            timer.invalidate()
            if((session?.status ) == .completed){
                let asetUrl = URL(fileURLWithPath: outputString)
                let aset = AVURLAsset(url: asetUrl)
                DispatchQueue.main.async {
                    if self.isChoseMp3 {
                        let mp3_path = "\(self.savePath!)/merge_output.mp3"
                        let convert = ExtAudioConverter()
                        convert.inputFile = outputString
                        convert.outputFile = mp3_path
                        convert.outputSampleRate = aset.duration.timescale;
                        convert.outputNumberChannels = 2;
                        convert.outputBitDepth = BitDepth_32;
                        convert.outputFormatID = kAudioFormatMPEGLayer3;
                        convert.outputFileType = kAudioFileMP3Type;
                        convert.convert()
                                            
                        let mgr = FileManager.default
                        let exist = mgr.fileExists(atPath: mp3_path)
                        if exist {
                            _ = Mytools.renameFile(withPath: mp3_path, oldName: "merge_output", newName: self.fileNameTF.stringValue)
                            _ = Mytools.deleteFile(withPath: outputString)
                        }
                        
                    }
                    self.myProg.doubleValue = 100.0
                    self.succeedNotify()
                }
            }else{
                print("\(String(describing: session?.error))")
            }
        })
    }
    func succeedNotify(){
        let notification = NSUserNotification()
        notification.title = "合并成功"
        notification.informativeText = "音频文件已保存在下载文件夹"
        notification.deliveryDate = Date()
        let center = NSUserNotificationCenter.default
        center.delegate = self
        center.deliver(notification)
    }
}

extension DLMainViewCtr : NSCollectionViewDataSource,NSCollectionViewDelegate{
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(to: myCol) {
            return dataArr.count
        }
        return mergeArr.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if collectionView.isEqual(to: myCol) {
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DLMainAudioItem"), for: indexPath) as! DLMainAudioItem
            let mo = dataArr[indexPath.item]
            cell.name = mo.name
            return cell
        }else{
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DLMainMergeItem"), for: indexPath) as! DLMainMergeItem
            let mo = mergeArr[indexPath.item]
            weak var weakSelf = self
            cell.callBlock = {()->()in
                weakSelf?.mergeArr.remove(at: indexPath.item)
                collectionView.reloadData()
            }
            cell.name = mo.name
            return cell
        }
    }
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let idx = indexPaths.first
        let mo = dataArr[idx!.item]
        mergeArr.append(mo)
        mergeCol.reloadData()
    }
}
extension DLMainViewCtr: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool  {
        return true
    }
}
