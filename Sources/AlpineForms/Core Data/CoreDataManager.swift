//
//  File.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import CoreData

class CoreDataManager: NSPersistentContainer {
 
    init() {
        guard
            let objectModelURL = Bundle.main.url(forResource: "AlpineForms", withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: objectModelURL)
        else {
            fatalError("Failed to retrieve the object model")
        }
        super.init(name: "Symptoms", managedObjectModel: objectModel)
        self.initialize()
    }
    
    private func initialize() {
        self.loadPersistentStores { description, error in
            if let err = error {
                fatalError("Failed to load CoreData: \(err)")
            }
            print("Core data loaded: \(description)")
        }
    }
    
//    func symptoms() throws -> [SymptomEntity] {
//        let fetchRequest = NSFetchRequest<SymptomEntity>(entityName: "SymptomEntity")
//        return try self.viewContext.fetch(fetchRequest)
//    }
//    
//    func saveSymptom(entity: SymptomEntity) throws {
//        self.viewContext.insert(entity)
//        try self.viewContext.save()
//    }
    
}
