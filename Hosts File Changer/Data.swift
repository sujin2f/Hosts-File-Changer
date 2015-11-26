//
//  Data.swift
//  Host Changer Core Data
//
//  Created by Sujin on 2015-08-24.
//  Copyright (c) 2015 Sujin. All rights reserved.
//

import Cocoa
import CoreData

class Data {
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext?

    var hosts = [NSManagedObject]()
    var id: Int = 0
    var entityName = "Hosts"
    var hasImported: Bool = false
    
    init() {
        managedContext = appDelegate.managedObjectContext!
        readData()
    }
    
    func readData() {
        let fetchRequest =  NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if let data = try? managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject] {
            hosts = data
        } else {
            hosts = []
        }
        
        resortData()
        checkHasImported()
    }
    
    func addItem(name:String, rule:String, activation:Bool, imported:Bool, lock:Bool) {
        let entity =  NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext!)
        let dataObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext!)
        
        self.id++
        
        dataObject.setValue(name, forKey: "name")
        dataObject.setValue(rule, forKey: "rule")
        dataObject.setValue(activation, forKey: "activation")
        dataObject.setValue(imported, forKey: "imported")
        dataObject.setValue(lock, forKey: "lock")
        dataObject.setValue(self.id, forKey: "id")
        
        var error: NSError?
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        hosts.append(dataObject)
        self.resortData()
        checkHasImported()
    }
    
    func removeItem(index: Int) {
        let object = hosts[index]
        
        managedContext!.deleteObject(object)
        do {
            try managedContext!.save()
        } catch {
        }
        
        hosts.removeAtIndex(index)
        self.resortData()
        checkHasImported()
    }
    
    func resortData() {
        let count = self.hosts.count
        var i = 0
        
        if count != 0 {
            for i = 0; i < count; ++i {
                self.hosts[i].setValue(i, forKey: "id")
            }
        }
        
        self.id = i - 1
    }
    
    func checkHasImported() {
        appDelegate.window?.enableButton("import")
        hasImported = false

        for host in hosts {
            let imported: Bool = host.valueForKey("imported") as! Bool
            
            if imported {
                appDelegate.window?.disableButton("import")
                hasImported = true
            }
        }
    }
    
    func findItem(item: NSManagedObject) -> Int {
        let count = self.hosts.count
        var i = 0
        
        if count != 0 {
            for i = 0; i < count; ++i {
                if item == self.hosts[i] {
                    return i
                }
            }
        }

        return -1
    }
    
    func saveData() {
        var error: NSError?
        do {
            try managedContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
    }
}










