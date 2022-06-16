//
//  TemplateField.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import CoreData

extension AF_TemplateField {
    
    static func sync(in managedObjectContext: NSManagedObjectContext, handler: @escaping ((Bool)->Void)) {
        managedObjectContext.performAndWait {
            do {
//                let lastUpdate = AF_UpdateTracker.lastUpdate(in: managedObjectContext, tableName: "TemplateField")
                FormsClientManager.shared.pool?.withConnection { con_from_pool in
                    do {
                        let connection = try con_from_pool.get()
                        defer {
                            connection.close()
                        }
                        
                        var text = """
                            SELECT
                            id,
                            template_id,
                            field_type,
                            caption,
                            font_size,
                            is_required,
                            field_order,
                            custom_script,
                            table_field,
                            table_name
                            FROM flex.template_fields
                            """
                        
//                        if let lastUpdate = lastUpdate {
//                            text = "\(text) WHERE updated >= timestamp '\(lastUpdate.toString(format: "YYYY-MM-dd HH:mm:ss"))'";
//                        }
                        
                        print("---------------->>> Importing Template Fields")
                        
                        //get records count
//                        let c_text = "select count(*) from (\(text)) as temp"
//                        let c_statement = try connection.prepareStatement(text: c_text)
//                        defer { c_statement.close() }
//                        let c_cursor = try c_statement.execute()
//                        defer { c_cursor.close() }
//                        var recCount: Int = 0
//                        for row in c_cursor {
//                            recCount = try row.get().columns[0].int()
//                            if recCount == 0 {
//                                print("---------------->>> No Updates to Templates Fields found")
//                                handler(true)
//                                return
//                            }
//                        }
//                        print(recCount)
                        
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
                                    let id = try UUID(uuidString: columns[1].string())
                                    let template = AF_Template.find(in: managedObjectContext, by: id!)
                                    
                                    if let template = template {
                                        let id = try UUID(uuidString: columns[0].string())
                                        var templateField = AF_TemplateField.find(in: managedObjectContext, by: id!)
                                        if templateField == nil {
                                            templateField = AF_TemplateField(context: managedObjectContext)
                                            templateField?.guid = id
                                        }
                                        if let templateField = templateField {
                                            templateField.template = template
                                            templateField.type = try columns[2].optionalString()
                                            templateField.caption = try columns[3].string()
                                            templateField.font_size = Int16(try columns[4].int())
                                            templateField.required = try columns[5].bool()
                                            templateField.field_order = try Int16(columns[6].int())
                                            templateField.custom_script = try columns[7].optionalString()
                                            templateField.table_field = try columns[8].optionalString()
                                            templateField.table_name = try columns[9].optionalString()
                                            
                                            if templateField.custom_script != nil {
                                                
                                            }
                                            templateField.save(context: managedObjectContext)
                                        }
                                    }
                                }
                            }
                            catch {
                                fatalError("\(error)")
                            }
                        }
                        AF_UpdateTracker.recordImport(in: managedObjectContext, tableName: "TemplateField")
                        handler(true)
                    }
                    catch {
                        fatalError("\(error)")
                    }
                }
            }
        }
    }
    
    static func find(in managedObjectContext: NSManagedObjectContext, by id: UUID) -> AF_TemplateField? {
        var result: AF_TemplateField? = nil
        do {
            let fetchRequest: NSFetchRequest<AF_TemplateField>
            fetchRequest = AF_TemplateField.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "guid = %@", id as CVarArg)

            result = try managedObjectContext.fetch(fetchRequest).first
        }
        catch {
            fatalError(error.localizedDescription)
        }
        return result
    }
}
