//
//  WindowsController.swift
//  Hosts File Changer
//
//  Created by Sujin on 2015-08-28.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa

class MainWindow: NSWindowController {
    /*********************************
    *** 멤버 변수들
    *********************************/
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

    // 메시지
    @IBOutlet weak var successMessage: NSTextField!

    // 버튼
    @IBOutlet weak var btnAddRule: NSButton!
    @IBOutlet weak var btnRemoveRule: NSButton!
    @IBOutlet weak var btnImport: NSButton!
    @IBOutlet weak var btnExport: NSButton!

    override func windowDidLoad() {
        self.window!.titleVisibility = NSWindowTitleVisibility.Hidden

        setMessageAlpha(false)
        
        appDelegate.window = self
        
        disableButton("remove")
        appDelegate.data!.checkHasImported()
    } // 초기화
    
    /*********************************
    *** 버튼 바인딩
    *********************************/
    @IBAction func toolbarAddClick(sender: AnyObject) {
        self.appDelegate.tableView!.addItem()
    } // 추가
    @IBAction func toolbarRemoveClick(sender: AnyObject) {
        self.appDelegate.tableView!.removeItem()
    } // 삭제
    @IBAction func toolbarImportClick(sender: AnyObject) {
        self.appDelegate.fileHandling!.importFromHostsFile()
    } // 임포트
    @IBAction func toolbarExportButtonClick(sender: AnyObject) {
        self.appDelegate.fileHandling!.exportFromHostsFile()
    } // 익스포트
    @IBAction func chmod644(sender: AnyObject) {
        var shellScript = "tell application \"Terminal\""
        shellScript = shellScript + "activate"
        shellScript = shellScript + "do script \"sudo chmod 644 /private/etc/hosts\""
    
        NSAppleScript(source: shellScript)!.executeAndReturnError(nil)
    }
    @IBAction func chmod646(sender: AnyObject) {}
    @IBAction func setDefaultHosts(sender: AnyObject) {
//        127.0.0.1 localhost
//        255.255.255.255 broadcasthost
//        ::1 localhost
//        fe80::1%lo0 localhost
    }
    @IBAction func toggleMiniMode(sender: AnyObject) {}

    /*********************************
    *** 메시지
    *********************************/
    func setMessageAlpha(bool:Bool) {
        if bool {
            self.successMessage.alphaValue = 1
        } else {
            self.successMessage.alphaValue = 0
        }
    }
    
    /*********************************
    *** 버튼 활성화/ 비활성화
    *********************************/
    func disableButton(name: String) {
        var btn: NSButton? = nil

        switch name {

        case "add" :
            btn = btnAddRule
        case "remove" :
            btn = btnRemoveRule
        case "import" :
            btn = btnImport
        case "export" :
            btn = btnExport
        default :
            btn = nil
        }

        btn!.enabled = false
    }
    func enableButton(name: String) {
        var btn: NSButton? = nil
        
        switch name {
            
        case "add" :
            btn = btnAddRule
        case "remove" :
            btn = btnRemoveRule
        case "import" :
            btn = btnImport
        case "export" :
            btn = btnExport
        default :
            btn = nil
        }
        
        btn!.enabled = true
    }
}