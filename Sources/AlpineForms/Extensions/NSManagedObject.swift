//
//  NSManagedObject.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import CoreData

extension NSManagedObject {
    
    func save(context: NSManagedObjectContext? = nil) {
        guard let ctx = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            if ctx.hasChanges {
                try ctx.save()
            }
        } catch {
            print("Failure to save context: \(error.localizedDescription)")
            print(error)
        }
    }
    
    static func MainAsyncSave(_ context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            do {
                try context.save()
            }
            catch {
                print("Could not save changed value:", error)
            }
        }
    }
    
    func delete(context: NSManagedObjectContext? = nil) {
        guard let ctx = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            ctx.delete(self)
            try ctx.save()
        } catch {
            print("Failure to delete object: \(error.localizedDescription)")
            print(error)
        }
    }
}
