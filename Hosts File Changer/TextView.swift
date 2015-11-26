//
//  OutlineController.swift
//  Hosts File Changer
//
//  Created by Sujin on 2015-08-27.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa

class TextView: NSView, NSTextViewDelegate {
    /*********************************
    *** 멤버 변수들
    *********************************/
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

    var textOutlet: NSTextView? = nil
    var tableOutlet: NSTableView? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        
        appDelegate.textView = self
        textOutlet = appDelegate.viewController?.text
        tableOutlet = appDelegate.viewController?.table
        
        disable()
        setDefaultAttributes()

        if appDelegate.data!.hosts.count == 0 {
            appDelegate.fileHandling?.importFromHostsFileQueue()
        }
    } // 초기화
    
    /*********************************
    *** 스타일
    *********************************/
    func setDefaultAttributes() {
        let attributes: [String: AnyObject] = [NSKernAttributeName : 1.1]
        textOutlet!.typingAttributes = attributes
        textOutlet!.font = NSFont(name: "Helvetica-Light", size: 14)
    } // 초기화
    func disable() {
        textOutlet!.editable = false
        textOutlet!.backgroundColor = NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
    } // 롹
    func enable() {
        textOutlet!.editable = true
        textOutlet!.backgroundColor = NSColor.whiteColor()

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.whiteColor().CGColor
    } // 언롹

    /*********************************
    *** 데이터 표시
    *********************************/
    func selectedData(selectedItem: NSManagedObject) {
        let rule: NSString = (selectedItem.valueForKey("rule") as? NSString)!
        let locked: Bool = (selectedItem.valueForKey("lock") as? Bool)!
        
        let text = textOutlet!.textStorage!.string as NSString
        let textRange = NSMakeRange(0,  text.length)
        
        textOutlet!.replaceCharactersInRange(textRange, withString: "\(rule)")
        
        if locked == true {
            disable()
        } else {
            enable()
        }
    } // 데이터 표시
    func textDidChange(notification: NSNotification) {
        let text = textOutlet!.textStorage!.string
        let index = tableOutlet!.selectedRow as Int
        
        if index > -1 {
            self.appDelegate.data.hosts[index].setValue(text, forKey: "rule")
        }
    } // 텍스트 변경 시
    func deleteAll() {
        let text = textOutlet!.textStorage!.string as NSString
        let textRange = NSMakeRange(0,  text.length)
        
        textOutlet!.replaceCharactersInRange(textRange, withString: "")
    } // 내용 삭제
    func reload() {
        deleteAll()
        
        let index = tableOutlet!.selectedRow as Int
        
        if index > -1 {
            let data = appDelegate.data.hosts[index]
            self.selectedData(data)
        } else {
            disable()
        }
    } // 새로고침
}













