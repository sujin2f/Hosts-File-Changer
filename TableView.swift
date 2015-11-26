//
//  TableView.swift
//  Hosts File Changer
//
//  Created by Sujin on 2015-09-16.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa

class TableView: NSView, NSTableViewDataSource, NSTableViewDelegate, NSControlTextEditingDelegate, NSTextFieldDelegate {
    /*********************************
    *** 멤버 변수들
    *********************************/
    let appDelegate:AppDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

    var textOutlet: NSTextView? = nil
    var tableOutlet: NSTableView? = nil
    var data: Data? = nil

    let LOCAL_REORDER_PASTEBOARD_TYPE = "HostFileChangerOutlineViewPboardType"

    let lockedImage = NSImage(named: "locked")
    let unlockedImage = NSImage(named: "unlocked")


    override func awakeFromNib() {
        super.awakeFromNib()
        
        appDelegate.tableView = self
        textOutlet = appDelegate.viewController?.text
        tableOutlet = appDelegate.viewController?.table
        data = appDelegate.data
        
        if data!.hosts.count == 0 {
            appDelegate.fileHandling?.importFromHostsFileQueue()
        }
        
        tableOutlet!.registerForDraggedTypes([LOCAL_REORDER_PASTEBOARD_TYPE, NSStringPboardType]);
        tableOutlet!.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
    } // 초기화

    /*********************************
    *** 데이터 표시
    *********************************/
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.data!.hosts.count
    } // 총 열의 개수
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let identifier = tableColumn!.identifier
        let item = self.data!.hosts[row] as NSManagedObject
        
        switch identifier {
        case "cName":
            return item.valueForKey("name") as? String
            
        case "cCheck":
            return item.valueForKey("activation") as? Bool
            
        case "cLock":
            let locked = item.valueForKey("lock") as? Bool
            
            if (locked == true) {
                return self.lockedImage
            } else {
                return self.unlockedImage
            }
            
        default:
            return nil
            
        }
    } // 각각의 컬럼에 데이터 표시

    /*********************************
    *** 이름 변경
    *********************************/
    func showEditButton(rowNum: Int) {
        let colView: AnyObject? = tableOutlet?.viewAtColumn(1, row: rowNum, makeIfNecessary: false)
        
        if let button = colView?.subviews[1] as? NSButton {
            button.hidden = false
        }
    }
    func hideAllEditButton() {
        let numberOfRow = tableOutlet?.numberOfRows
        for var i = 0; i < numberOfRow; i++ {
            let colView: AnyObject? = tableOutlet?.viewAtColumn(1, row: i, makeIfNecessary: false)

            if let button = colView?.subviews[1] as? NSButton {
                button.hidden = true
            }
        }
    }
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let identifier: String = tableColumn!.identifier {
            let cellView: NSTableCellView = tableView.makeViewWithIdentifier(identifier, owner: self) as! NSTableCellView
            
            if identifier == "cName" {
                cellView.textField?.delegate = self
            }
            
            return cellView
        }
        
        return nil
    } // 뷰 생성 및 초기화
    override func controlTextDidEndEditing(obj: NSNotification) {
        let cellView = obj.object?.superview as! NSTableCellView
        let row: Int = (tableOutlet?.rowForView(cellView))!
        let textField: NSTextField = obj.object as! NSTextField

        if textField.stringValue != "" {
            self.data!.hosts[row].setValue(obj.object?.stringValue, forKey: "name")
        } else {
            textField.stringValue = (self.data!.hosts[row].valueForKey("name") as? String)!
        }
        
        textField.editable = false
        showEditButton(row)
    } // 이름 변경이 끝난 후

    /*********************************
    *** Row 클릭시
    *********************************/
    func tableView(tableView: NSTableView, didClickTableColumn tableColumn: NSTableColumn) {
        Swift.print(1)
    }
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let selectedItem = self.data!.hosts[row] as NSManagedObject
        appDelegate.textView!.selectedData(selectedItem)

        return true
    } // 텍스트뷰에 표시하라고 명령 보내기
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedRow = tableOutlet!.selectedRow
        changeBackgroudColor(selectedRow)
        setRemoveButton()

        hideAllEditButton()
        if selectedRow > -1 {
            showEditButton(selectedRow)
        }
    } // 선택했을 때 콜백
    func selectRow(index: Int) {
        if data!.hosts.count > index {
            let rowIndex = NSIndexSet(index: index)
            let item = data!.hosts[index]
            
            tableOutlet!.selectRowIndexes(rowIndex, byExtendingSelection: false)
            
            appDelegate.textView!.selectedData(item)
            changeBackgroudColor(index)
            
        }
    } // 강제로 선택하기
    func changeBackgroudColor(index: Int) {
        let rows = tableOutlet!.numberOfRows
        
        for var i = 0; i < rows; ++i {
            let view = tableOutlet!.rowViewAtRow(i, makeIfNecessary: true)
            view!.backgroundColor = i == index ? NSColor(calibratedRed: 0.9, green: 0.9, blue: 0.9, alpha: 1) : tableOutlet!.backgroundColor
        }
    } // 선택 열 배경 변경

    /*********************************
    *** 메뉴 관련
    *********************************/
    func addItem() {
        data!.addItem("New Rule", rule:"", activation:false, imported: false, lock: false)
        tableOutlet!.reloadData()
        
        selectRow(data!.id)
    } // 항목 추가
    func removeItem() {
        var index: Int = tableOutlet!.selectedRow as Int
        
        if index > -1 && data!.hosts.count > index {
            let hostsData: NSManagedObject = data!.hosts[index]
            if hostsData.valueForKey("lock") as? Bool == false {
                let numRows: Int = tableOutlet!.numberOfRows
                
                data!.removeItem(index)
                
                tableOutlet!.reloadData()
                appDelegate.textView!.reload()
                
                if numRows == index {
                    index--
                }
                
                selectRow(index)
            }
        }
    } // 항목 삭제
    func setRemoveButton() {
        let selectedRow = tableOutlet!.selectedRow
        
        if selectedRow > -1 {
            let selecteData = data!.hosts[selectedRow]
            let locked = selecteData.valueForKey("lock") as! Bool
            
            if locked {
                appDelegate.window?.disableButton("remove")
            } else {
                appDelegate.window?.enableButton("remove")
            }
        } else {
            appDelegate.window?.disableButton("remove")
        }
    } // 항목 삭제 버튼 새로 고침

    /*********************************
    *** 드래그 & 드롭
    *********************************/
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pasteboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject([rowIndexes])
        
        pasteboard.declareTypes([LOCAL_REORDER_PASTEBOARD_TYPE], owner:self)
        pasteboard.setData(data, forType: LOCAL_REORDER_PASTEBOARD_TYPE)
        
        return true
    } // 드래그 시작
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .Above {
            return NSDragOperation.Move
        }
        return NSDragOperation.Generic

    } // 드래그 중
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let rowData = pasteboard.dataForType(LOCAL_REORDER_PASTEBOARD_TYPE)
        
        if(rowData != nil) {
            let dataArray = NSKeyedUnarchiver.unarchiveObjectWithData(rowData!) as! Array<NSIndexSet>
            let indexSet = dataArray[0]
            let movingFromIndex = indexSet.firstIndex
            
            if movingFromIndex == row {
                return true
            }
            
            var newHosts = [NSManagedObject]()
            
            for var i = 0; i <= self.data!.hosts.count; i++ {
                if i == row {
                    newHosts.append(self.data!.hosts[movingFromIndex])
                }

                if i != movingFromIndex && i < self.data!.hosts.count {
                    newHosts.append(self.data!.hosts[i])
                }
            }
            
            self.data!.hosts = newHosts
            self.data!.resortData()
            self.data!.saveData()
            tableOutlet!.reloadData()

            return true
        }
        else {
            return false
        }

    } // 드롭
}


// Layout still needs update after calling -[NSTableRowView layout].  NSTableRowView or one of its superclasses may have overridden -layout without calling super. Or, something may have dirtied layout in the middle of updating it.  Both are programming errors in Cocoa Autolayout.  The former is pretty likely to arise if some pre-Cocoa Autolayout class had a method called layout, but it should be fixed















