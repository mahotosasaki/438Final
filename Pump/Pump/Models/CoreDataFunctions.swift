//
//  CoreDataFunctions.swift
//  Pump
//
//  Created by Akash Kaul on 12/2/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataFunctions {
    
    static func save(_ user: User) {
        if checkForDuplicates(user) {return}
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "UserSaveData", in: managedContext) else {return}
        
        let userToSave = NSManagedObject(entity: entity, insertInto: managedContext)
        userToSave.setValue(user.following, forKey: "following")
        userToSave.setValue(user.username, forKey: "displayName")
        userToSave.setValue(user.email, forKey: "email")
        userToSave.setValue(user.experience, forKey: "experience")
        userToSave.setValue(user.height, forKey: "height")
        userToSave.setValue(user.uid, forKey: "uid")
        userToSave.setValue(user.name, forKey: "name")
//        userToSave.setValue(user., forKey: "password")
        userToSave.setValue(user.profile_pic, forKey: "profile_pic")
        userToSave.setValue(user.weight, forKey: "weight")
        
        appDelegate.saveContext()
    }
    
    static func delete(_ deleteUser: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(deleteUser)
        
        appDelegate.saveContext()
    }
    
    static func getData() -> [NSManagedObject]{
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
        
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserSaveData")
            
            do {
                let currUser = try managedContext.fetch(fetchRequest)
                return currUser
            } catch {
                let error = error as NSError
                print("Could not fetch data \(error), \(error.userInfo)")
            }
        }
        return [NSManagedObject]()
    }
    
    // Checks for duplicates in core data based on id
    // https://stackoverflow.com/questions/2252109/fastest-way-to-check-if-an-object-exists-in-core-data-or-not
    
    static func checkForDuplicates(_ user: User) -> Bool {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
        
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserSaveData")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "uid == %d", user.uid)
            
            do {
                let count = try managedContext.count(for: fetchRequest)
                return count > 0
            } catch {
                let error = error as NSError
                print("Could not fetch data \(error), \(error.userInfo)")
                return false
            }
        }
        return false
    }
    
    static func deleteAllData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSaveData")
        fetchRequest.returnsObjectsAsFaults = false

        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
                print("delete everything")
            }
        } catch let error as NSError {
            print("Detele all data in \("UserSaveData") error : \(error) \(error.userInfo)")
        }
    }
}
