//
//  FormField.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import CoreData

extension FormField {
    
    static func sync(in managedObjectContext: NSManagedObjectContext, handler: @escaping ((Bool)->Void)) {
        managedObjectContext.performAndWait {
            do {
                let lastUpdate = UpdateTracker.lastUpdate(in: managedObjectContext, tableName: "FormField")
                FormsClientManager.shared.pool?.withConnection { con_from_pool in
                    do {
                        let connection = try con_from_pool.get()
                        defer {
                            connection.close()
                        }
                        
                        var text = """
                            SELECT
                            id,
                            template_field_id,
                            data_form_id,
                            string_data,
                            double_data,
                            binary_data,
                            boolean_data,
                            ST_AsText(ST_Transform(geometry, 4326))
                            FROM flex.data_form_fields
                            """
                        
//                        if let lastUpdate = lastUpdate {
//                            text = "\(text) WHERE updated >= timestamp '\(lastUpdate.toString(format: "YYYY-MM-dd HH:mm:ss"))'";
//                        }
                        
                        print("---------------->>> Importing Form Fields")
                        
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
//                                print("---------------->>> No Updates to Form Fields found")
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
                                    let id = try UUID(uuidString: columns[2].string())
                                    let form = Form.find(in: managedObjectContext, by: id!)
                                    
                                    if let form = form {
                                        let columns = try row.get().columns
                                        let id = try UUID(uuidString: columns[1].string())
                                        let templateField = TemplateField.find(in: managedObjectContext, by: id!)
                                        
                                        if let templateField = templateField {
                                            let id = try UUID(uuidString: columns[0].string())
                                            var formField = FormField.find(in: managedObjectContext, by: id!)
                                            if formField == nil {
                                                formField = FormField(context: managedObjectContext)
                                                formField?.guid = id
                                            }
                                            if let formField = formField {
                                                formField.form = form
                                                formField.templateField = templateField
                                                formField.string_data = try columns[3].optionalString()
                                                formField.double_data = try columns[4].optionalDouble() ?? 0
                                                formField.binary_data = try columns[5].optionalByteA()?.data
                                                formField.boolean_data = try columns[6].optionalBool() as NSNumber?
                                                formField.geometry = try columns[7].optionalString()
                                                
                                                formField.save(context: managedObjectContext)
                                            }
                                        }
                                    }
                                    UpdateTracker.recordImport(in: managedObjectContext, tableName: "FormField")
                                }
                            }
                            catch {
                                fatalError(error.localizedDescription)
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
    
    static func find(in managedObjectContext: NSManagedObjectContext, by id: UUID) -> FormField? {
        var result: FormField? = nil
        do {
            let fetchRequest: NSFetchRequest<FormField>
            fetchRequest = FormField.fetchRequest()
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
