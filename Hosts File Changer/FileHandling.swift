//
//  FileHandling.swift
//  Hosts File Changer
//
//  Created by Sujin on 2015-08-28.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa

class FileHandling {
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

    let fileManager = NSFileManager.defaultManager()
    let hostsFile = "/private/etc/hosts"
    
    var importQueue: Int = 0
    
    var authorization: NSData = NSData()
    var helperToolConnection: NSXPCConnection? = nil
    var xpcServiceConnection: NSXPCConnection? = nil

    func isWritable() -> Bool {
        return self.fileManager.isWritableFileAtPath(self.hostsFile)
    }
    
    func showMessage(message: String, info: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = message
        myPopup.informativeText = info
        myPopup.alertStyle = NSAlertStyle.InformationalAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.runModal()
    }

    func copyToClipBoard(text: String) {
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text])
    }

    func importFromHostsFile() {
        let text = try? String(contentsOfFile: hostsFile as String, encoding: NSUTF8StringEncoding)
        self.appDelegate.data.addItem("Imported hosts", rule:text!, activation:false, imported: true, lock: true)
        
        let tableOutlet = appDelegate.viewController!.table
        let textView = appDelegate.textView!
        
        tableOutlet.reloadData()
        textView.reload()
        
        appDelegate.tableView!.selectRow(appDelegate.data.id)
    }
    
    func importFromHostsFileQueue() {
        if importQueue == 1 {
            importFromHostsFile()
        } else {
            importQueue++
        }
    }

    func exportFromHostsFile() {
        var hostsText: String = ""
        var name: String = ""
        
        for data in self.appDelegate.data.hosts {
            if (data.valueForKey("activation") as? Bool == true) {
                name = (data.valueForKey("name") as? String)!
                hostsText = hostsText + "##########################\n"
                hostsText = hostsText + "## Hosts Rule : \(name)\n"
                hostsText = hostsText + "##########################\n"
                hostsText = hostsText + "\n"
                hostsText = hostsText + (data.valueForKey("rule") as? String)! + "\n\n"
            }
        }

        if !self.isWritable() {
            let script = "do shell script \"sudo echo '\(hostsText)' > \(hostsFile)\" with administrator privileges"
            NSAppleScript(source:script )!.executeAndReturnError(nil)


        } else {
            let file: NSFileHandle? = NSFileHandle(forUpdatingAtPath: self.hostsFile)
            
            if file == nil {
                let message = "The hosts file \(self.hostsFile) is not exists."
                let info = "The text will be stored into your clipboard"
                self.showMessage(message, info: info)
                self.copyToClipBoard(hostsText)

            } else {
                let data = (hostsText as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                
                file?.truncateFileAtOffset(0)
                file?.seekToFileOffset(0)
                file?.writeData(data!)
                file?.closeFile()
            }
        }

        let mainWindow:MainWindow = NSApplication.sharedApplication().mainWindow?.windowController as! MainWindow
        mainWindow.setMessageAlpha(true)
}
}