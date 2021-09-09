//
//  DLStringExt.swift
//  DoNotRemember
//
//  Created by apple on 2020/9/24.
//

import CommonCrypto
import Cocoa

extension String {
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
     
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    func getMD5() ->String!{
      let str = self.cString(using: String.Encoding.utf8)
      let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
      let digestLen = Int(CC_MD5_DIGEST_LENGTH)
      let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
      CC_MD5(str!, strLen, result)
      let hash = NSMutableString()
      for i in 0 ..< digestLen {
          hash.appendFormat("%02x", result[i])
      }
      result.deinitialize(count: 16)
      return String(format: hash as String)
    }
    //验证url
    func verifyUrl() -> Bool {
        let pattern = "^(((http[s]{0,1}|ftp|Http[s]{0,1})://)?[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    //josn转字典
    func json2Dictionary() -> NSDictionary! {
        guard let jsonData = self.data(using:.utf8) else { return nil }
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return (dict as! NSDictionary)
        }
        return NSDictionary()
    }
    //josn转数组
    func json2Array() -> NSArray! {
        guard let jsonData = self.data(using:.utf8) else { return nil }
        let arr = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if arr != nil {
            return (arr as! NSArray)
        }
        return NSArray()
    }
    //验证邮箱
    func verifyEmail() ->Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    //验证身份证
    func verifyIdCard() ->Bool {
        let pattern = "\\d{18}$|(\\d{17}[xX])$"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    //验证银行卡
    func verifyBankCard() ->Bool {
        guard self.count > 0 else {
            return false
        }
        let pattern = "^(\\d{15,30})"
        let pred = NSPredicate(format: "SELF MATCHES %@",pattern)
        return pred.evaluate(with: self)
    }
    //是否是中文
    func isChinese() -> Bool {
        let match: String = "(^[\\u4e00-\\u9fa5]+$)"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: self)
    }
    //是否是座机
    func isTel() -> Bool {
        let match: String = "^0\\d{2,3}-\\d{7,8}$"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return predicate.evaluate(with: self)
    }
    //非法字符判断
    func hasIllegalCharacter() -> Bool{
        let match: String = "^[A-Za-z0-9\\u4e00-\\u9fa5]+$"
        let predicate = NSPredicate(format: "SELF matches %@", match)
        return !predicate.evaluate(with: self)
    }
    //文本纯整型判断
    func isPureInt() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    //文本纯浮点型判断
    func isPureFloat() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val:Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }
    func verticalText() -> String{
        var newString : String = ""
        for charStr in self {
            newString.append(charStr)
            newString.append("\n")
        }
        return newString
    }
    func regexGetSub(pattern:String) -> [String] {
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options:[])
        let matches = regex.matches(in: self, options: [], range: NSRange(self.startIndex...,in: self))
        //解析出子串
        for  match in matches {
            subStr.append(contentsOf: [String(self[Range(match.range(at: 1), in: self)!]),String(self[Range(match.range(at: 2), in: self)!])])
        }
        return subStr
    }
    func base64Encoding()->String{
        let plainData = self.data(using: String.Encoding.utf8)
        let base64String = plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }
    func base64Decoding()->String{
        let decodedData = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }
    func sizeWithFont(font : NSFont, maxSize : CGSize) -> CGSize{
        let attrs = [NSAttributedString.Key.font : font]
        return self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attrs, context: nil).size
    }
}
extension NSDate {
    func date2String() -> String{
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: self as Date)
    }
    func string2Date(str:String) -> NSDate {
        let format = DateFormatter.init()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.date(from: str)! as NSDate
    }
    
}
extension Dictionary{
    func dictionary2Json() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: self, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
    //拼接参数
    func dealWithParam() -> String {
        var result = NSMutableString()
        for (key,value) in self {
            let str = "\(key)" + "=" + "\(value)" + "&"
            result = result.appending(str) as! NSMutableString
        }
        if result.length > 0 {
            let finalstr = result.substring(with: NSMakeRange(0, result.length - 1))
            return finalstr
        }else{
            return ""
        }
    }
}
extension NSArray {
    func array2Json() -> String {
         
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSONString")
            return ""
        }
         
        let data : NSData! = try? JSONSerialization.data(withJSONObject: self, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
         
    }
}

extension NSColor{
    class func hexColor(hexString:String,alpha:Double = 1) -> NSColor? {
        if (hexString.count <= 0){
            return nil
        }
        let colorString = hexString.replacingOccurrences(of: "#", with: "").uppercased()
        var alpha = 0.0
        var red = 0.0
        var blue = 0.0
        var green = 0.0
        switch (colorString.count) {
            case 3: // #RGB
                alpha = 1.0;
                red   = colorComponentFrom(str: colorString, start: 0, length: 1)
                green = colorComponentFrom(str: colorString, start: 1, length: 1)
                blue  = colorComponentFrom(str: colorString, start: 2, length: 1)
                break;
            case 4: // #ARGB
                alpha = colorComponentFrom(str: colorString, start: 0, length: 1)
                red   = colorComponentFrom(str: colorString, start: 1, length: 1)
                green = colorComponentFrom(str: colorString, start: 2, length: 1)
                blue  = colorComponentFrom(str: colorString, start: 3, length: 1)
                break;
            case 6: // #RRGGBB
                alpha = 1.0;
                red   = colorComponentFrom(str: colorString, start: 0, length: 2)
                green = colorComponentFrom(str: colorString, start: 2, length: 2)
                blue  = colorComponentFrom(str: colorString, start: 4, length: 2)
                break;
            case 8: // #AARRGGBB
                alpha = colorComponentFrom(str: colorString, start: 0, length: 2)
                red   = colorComponentFrom(str: colorString, start: 2, length: 2)
                green = colorComponentFrom(str: colorString, start: 4, length: 2)
                blue  = colorComponentFrom(str: colorString, start: 5, length: 2)
                break;
            default:
                return nil;
        }
        return NSColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
    fileprivate class func colorComponentFrom(str:String,start:Int,length:Int) -> Double {
        let substring = dl_substring(string: str, start: start, length: length)
        let fullHex = length == 2 ? substring : substring + substring
        var hexComponent : UInt32 = 0
        
        Scanner(string: fullHex).scanHexInt32(&hexComponent)
        return Double(hexComponent) / 255.0;
    }
    class func dl_substring(string:String,start:Int,length:Int) -> String {
        let indexStart = string.startIndex
        let indexTwo = string.index(indexStart, offsetBy: start)
        let indexFive = string.index(indexStart, offsetBy: start + length)
        let subString = string[indexTwo..<indexFive]
        return String(subString)
    }
    class func randomColor() -> NSColor {
        return NSColor(red: CGFloat(arc4random_uniform(255))/255.0, green: CGFloat(arc4random_uniform(255))/255.0, blue: CGFloat(arc4random_uniform(255))/255.0, alpha: 1.0)
    }
}
