//
//  ViewController.swift
//  Hosts File Changer
//
//  Created by Sujin on 2015-08-26.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

    @IBOutlet weak var table: NSTableView!
    @IBOutlet var text: NSTextView!

    @IBAction func checkboxClick(sender:NSButton) {
        let rowView: NSTableRowView = sender.superview?.superview as! NSTableRowView
        let index = table.rowForView(rowView)
        
        let hostData: NSManagedObject = appDelegate.data!.hosts[index]

        if sender.objectValue as! Int == 1 {
            hostData.setValue(true, forKey: "activation")
        } else {
            hostData.setValue(false, forKey: "activation")
        }
    } // 리스트 : 체크박스
    @IBAction func lockClick(sender:NSButton) {
        let rowView: NSTableRowView = sender.superview?.superview as! NSTableRowView
        let index = table.rowForView(rowView)
        let rowIndexes = NSIndexSet(index: index)
        let columnIndexes = NSIndexSet(index: 2)
        let selectedRow = table.selectedRow
        
        let hostData: NSManagedObject = appDelegate.data!.hosts[index]
        let locked = hostData.valueForKey("lock") as? Bool

        if locked == true {
            hostData.setValue(false, forKey: "lock")
        } else {
            hostData.setValue(true, forKey: "lock")
        }
        
        table.reloadDataForRowIndexes(rowIndexes, columnIndexes: columnIndexes)

        if selectedRow == index {
            appDelegate.textView!.selectedData(hostData)
        }
        
        appDelegate.tableView!.setRemoveButton()
    } // 리스트 : 롹
    @IBAction func editClick(sender:NSButton) {
        let rowView: NSTableRowView = sender.superview?.superview as! NSTableRowView
        let index = table.rowForView(rowView)
        let cellView: NSTableCellView = sender.superview as! NSTableCellView
        
        let rect: NSRect = cellView.frame as NSRect
        let width = rect.size.width - 6
        
        cellView.textField?.setFrameSize(NSMakeSize(width, 17.0))
        cellView.textField?.editable = true
        table.editColumn(1, row: index, withEvent: nil, select: true)
        appDelegate.tableView?.hideAllEditButton()
    } // 리스트 : 에디트

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        appDelegate.viewController = self
        appDelegate.data = Data()
        appDelegate.fileHandling = FileHandling()
    }
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}





