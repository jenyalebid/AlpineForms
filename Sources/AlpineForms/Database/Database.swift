//
//  Database.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import CoreData


public class Database {
    
    var _mainContext: NSManagedObjectContext!
    var _privateMOC: NSManagedObjectContext!
    
    static public var shared = Database(mc: nil, pc: nil)
    
    public init(mc: NSManagedObjectContext?, pc: NSManagedObjectContext?) {
        guard mc != nil && pc != nil else { return }
        _mainContext = mc!
//        _mainContext = FormsPersistenceController.shared.container.viewContext
//        _mainContext.persistentStoreCoordinator = FormsPersistenceController.shared.container.persistentStoreCoordinator
        _privateMOC = pc!
//        _privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        _privateMOC.parent = _mainContext
//        _privateMOC.automaticallyMergesChangesFromParent = true
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
        AF_Template.sync(in: context, handler: { templateResult in
            if templateResult {
                AF_TemplateField.sync(in: context, handler: { fieldResult in
                    if fieldResult {
                        completionHandler(true)
                    }
                })
            }
        })
    }
    
    func syncForm(with dispatchGroup: DispatchGroup, in context: NSManagedObjectContext, completionHandler: @escaping(Bool) -> Void) {
        AF_Form.sync(in: context, handler: { formResult in
            if formResult {
                AF_FormField.sync(in: context, handler: { fieldResult in
                    if fieldResult {
                        completionHandler(true)
                    }
                })
            }
        })
    }
}
