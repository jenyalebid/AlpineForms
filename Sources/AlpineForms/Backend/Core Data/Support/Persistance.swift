//
//  Persistence.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import CoreData

public struct FormsPersistenceController {
    
//    static public let shared = FormsPersistenceController()
//
//    static var preview: FormsPersistenceController = {
//        let result = FormsPersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//
//        for _ in 0..<10 {
//
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()
    
//    public let container: NSPersistentContainer
    public init() {
        
    }
//    public init(inMemory: Bool = false) {
//        let modelURL = Bundle.module.url(forResource:"AlpineForms", withExtension: "momd")
//        let model = NSManagedObjectModel(contentsOf: modelURL!)
//
//        container = NSPersistentContainer(name: "AlpineForms", managedObjectModel: model!)
//
//        if inMemory {
//            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//        }
//
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        container.viewContext.automaticallyMergesChangesFromParent = true
//    }
    
    public func getModule() -> NSManagedObjectModel {
        let modelURL = Bundle.module.url(forResource:"AlpineForms", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
}
    

