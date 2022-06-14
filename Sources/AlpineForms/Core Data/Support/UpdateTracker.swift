//
//  UpdateTracker.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import Foundation
import CoreData

extension UpdateTracker {
    
    static func lastUpdate(in managedObjectContext:NSManagedObjectContext, tableName: String) -> Date? {
        var lastUpdate: UpdateTracker? = nil
        managedObjectContext.performAndWait {
            let fetchRequest: NSFetchRequest<UpdateTracker> = UpdateTracker.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "tableName = %@", tableName)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try managedObjectContext.fetch(fetchRequest)
                for result in results {
                    lastUpdate = result
                }
            }
            catch {
                fatalError(error.localizedDescription)
            }
            
                    if (lastUpdate != nil) {
                        do {
                            lastUpdate = try managedObjectContext.existingObject(with: lastUpdate!.objectID) as? UpdateTracker
                        }
                        catch {
                            fatalError(error.localizedDescription)
                        }
                    }
        }
        return lastUpdate?.lastUpdate
    }
    
    static func recordImport(in managedObjectContext: NSManagedObjectContext, tableName: String) {
        let fetchRequest: NSFetchRequest<UpdateTracker> = UpdateTracker.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tableName = %@", tableName)
        managedObjectContext.performAndWait {
            do {
                let results = try managedObjectContext.fetch(fetchRequest)
                for result in results {
                    managedObjectContext.delete(result)
                }
                let record = UpdateTracker.init(context: managedObjectContext)
                record.tableName = tableName
                record.lastUpdate = Date()
            }
            catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
