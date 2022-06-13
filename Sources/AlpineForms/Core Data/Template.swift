//
//  Template.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/13/22.
//

import CoreData
import PostgresClientKit

extension Template {
    
    static func sync(in managedObjectContext: NSManagedObjectContext, handler: @escaping ((Bool)->Void)) {
        managedObjectContext.performAndWait {
            do {
                let lastUpdate = UpdateTracker.lastUpdate(in: managedObjectContext, tableName: "Template")
                FormsClientManager.shared.pool?.withConnection { con_from_pool in
                    do {
                        let connection = try con_from_pool.get()
                        defer {
                            connection.close()
                        }
                        
                        var text = """
                            SELECT
                            id,
                            name,
                            navigation_table_name,
                            navigation_table_field,
                            report,
                            updated
                            FROM flex.templates
                            WHERE deleted IS FALSE
                            """
                        
                        if let lastUpdate = lastUpdate {
                            text = "\(text) AND updated >= timestamp '\(lastUpdate.toString(format: "YYYY-MM-dd HH:mm:ss"))'";
                        }
                        
                        print("---------------->>> Importing Templates")
                        
                        //get records count
                        let c_text = "select count(*) from (\(text)) as temp"
                        let c_statement = try connection.prepareStatement(text: c_text)
                        defer { c_statement.close() }
                        let c_cursor = try c_statement.execute()
                        defer { c_cursor.close() }
                        
                        for row in c_cursor {
                            let recCount = try row.get().columns[0].int()
                            print(recCount)
                            if recCount == 0 {
                                print("---------------->>> No Updates to Templates found")
                                handler(true)
                                return
                            }
                        }
                        
                        let statement = try connection.prepareStatement(text: text)
                        defer { statement.close() }
                        
                        let cursor = try statement.execute()
                        defer { cursor.close() }
                        
                        managedObjectContext.performAndWait {
                            do {
                                var counter = 0
                                for row in cursor {
                                    counter += 1
                                    let columns = try row.get().columns
                                    let id = try UUID(uuidString: columns[0].string())
                                    var template = Template.find(in: managedObjectContext, by: id!)
                            
                                    if template == nil {
                                        template = Template(context: managedObjectContext)
                                        template?.guid = id
                                    }
                                    if let template = template {
                                        template.name = try columns[1].string()
                                        template.navigation_table_name = try columns[2].optionalString()
                                        template.navigation_table_field = try columns[3].optionalString()
                                        template.report = try columns[4].optionalByteA()?.data
                                        
                                        template.save(context: managedObjectContext)
                                    }
                                }
                            }
                            catch {
                                fatalError("\(error)")
                            }
                        }
                        handler(true)
                    }
                    catch {
                        fatalError("\(error)")
                    }
                }
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            }
            catch {
                print("Failure to save context: \(error)")
            }
        }
    }
    
    static func find(in managedObjectContext: NSManagedObjectContext, by id: UUID) -> Template? {
        var result: Template? = nil
        do {
            let fetchRequest = Template.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "guid == %@", id as CVarArg)

            result = try managedObjectContext.fetch(fetchRequest).first
        }
        catch {
            fatalError(error.localizedDescription)
        }
        return result
    }
}
