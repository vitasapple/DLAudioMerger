//
//  Mytools.swift
//  DoNotRemember
//
//  Created by apple on 2020/9/24.
//

import Cocoa
enum SandBoxType {
    case document
    case cache
    case tmp
}

class Mytools: NSObject {
    //获取当前时间戳
    class func getCurrentTimestamp() -> NSInteger {
        let date = NSDate.init(timeIntervalSinceNow: 0)
        let interval = date.timeIntervalSince1970
        return NSInteger(interval)
    }
    //方法的第二个参数名及后续的参数名，默认既是内部参数名，又是外部参数名，如果不想提供外部参数名，可以在参数名前添加下划线来忽略外部参数名。
    class func timestamp2Time(stamp:String ,_ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: Double(stamp) ?? 0)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    class func howManyDaysInDate(year:Int,month:Int) -> Int {
        if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12)){
            return 31
        }
        if((month == 4) || (month == 6) || (month == 9) || (month == 11)){
            return 30
        }
        if((year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3)){
            return 28;
        }
        if(year % 400 == 0){
            return 29;
        }
        if(year % 100 == 0){
            return 28;
        }
        return 29;
    }
    class func getSandBoxInsidePath(type:SandBoxType) -> String{
        switch type {
        case .document:
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        case .cache:
            return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
        case .tmp:
            return NSTemporaryDirectory()
        default: break
            
        }
    }
    //删除文件
    class func deleteFile(withPath:String) -> Bool{
        let manager = FileManager.default
        let exist = manager.fileExists(atPath: withPath)
        var state = false
        if exist {
            do{
                try manager.removeItem(at: URL(fileURLWithPath: withPath))
                state = true
            }catch{
                print("删除失败")
            }
        }
        return state
    }
    class func renameFile(withPath:String, oldName:String, newName:String) -> Bool{
        let fileMgr = FileManager.default
        let url = URL(fileURLWithPath: withPath)
        var state = false
        do{
            let newPath = withPath.replacingOccurrences(of: oldName, with: newName)
            try fileMgr.moveItem(at: url, to:URL(fileURLWithPath: newPath))
            state = true
        }catch let error as NSError{
            print("重命名文件失败 \(error)")
        }
        return state
    }
}

