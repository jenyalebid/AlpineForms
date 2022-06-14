//
//  Database.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import CoreData


public class Database {
    
    var _mainContext: NSManagedObjectContext
    var _privateMOC: NSManagedObjectContext
    
    static public let shared = Database()
    
    public init() {
        _mainContext = FormsPersistenceController.shared.container.viewContext
        _mainContext.persistentStoreCoordinator = FormsPersistenceController.shared.container.persistentStoreCoordinator
        _privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        _privateMOC.parent = _mainContext
        _privateMOC.automaticallyMergesChangesFromParent = true
    }
    
    public func sync(completionHandler: @escaping(Bool) -> Void) {
        let dispatchGroup = DispatchGroup()
        syncTemplate(with: dispatchGroup, in: self._mainContext, completionHandler: { templateResult in
            if templateResult {
                self.syncForm(with: dispatchGroup, in: self._mainContext, completionHandler: { formResult in
                    if formResult {
                        completionHandler(true)
                        dispatchGroup.leave()
                    }
                })
            }
        })
    }
    
    func syncTemplate(with dispatchGroup: DispatchGroup, in context: NSManagedObjectContext, completionHandler: @escaping(Bool) -> Void) {
        dispatchGroup.enter()
        Template.sync(in: context, handler: { templateResult in
            if templateResult {
                TemplateField.sync(in: context, handler: { fieldResult in
                    if fieldResult {
                        completionHandler(true)
                    }
                })
            }
        })
    }
    
    func syncForm(with dispatchGroup: DispatchGroup, in context: NSManagedObjectContext, completionHandler: @escaping(Bool) -> Void) {
        Form.sync(in: context, handler: { formResult in
            if formResult {
                FormField.sync(in: context, handler: { fieldResult in
                    if fieldResult {
                        completionHandler(true)
                    }
                })
            }
        })
    }
}
