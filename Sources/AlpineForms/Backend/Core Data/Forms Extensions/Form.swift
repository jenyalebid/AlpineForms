//
//  Form.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import CoreData

extension AF_Form {
    
    public func update(missingRequirements: Bool?) {
        if let missingRequirements = missingRequirements {
            missingRequirements_ = missingRequirements
        }
        changed_ = true
        updated_date = Date()
    }
    
    static func sync(in managedObjectContext: NSManagedObjectContext, handler: @escaping ((Bool)->Void)) {
        managedObjectContext.performAndWait {
            do {
                let lastUpdate = AF_UpdateTracker.lastUpdate(in: managedObjectContext, tableName: "Form")
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
                            parent_id,
                            date
                            FROM flex.data_forms
                            """
                        
//                        if let lastUpdate = lastUpdate {
//                            text = "\(text) WHERE updated >= timestamp '\(lastUpdate.toString(format: "YYYY-MM-dd HH:mm:ss"))'";
//                        }
                        
                        print("---------------->>> Importing Forms")
                        
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
//                                print("---------------->>> No Updates to Forms found")
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
                                        var form = AF_Form.find(in: managedObjectContext, by: id!)
                                        if form == nil {
                                            form = AF_Form(context: managedObjectContext)
                                            form?.guid = id
                                        }
                                        if let form = form {
                                            form.template = template
                                            form.parentGUID = try UUID(uuidString: columns[2].optionalString() ?? "")
//                                            if let parentID = try UUID(uuidString: columns[2].optionalString() ?? "") {
//                                                if let parent = AF_Form.find(in: managedObjectContext, by: parentID) {
//                                                    form.parent = parent
//                                                }
//                                            }
                                            form.updated_date = try columns[3].timestampWithTimeZone().date
                                            form.save(context: managedObjectContext)
                                        }
                                    }
                                }
                            }
                            catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                        AF_UpdateTracker.recordImport(in: managedObjectContext, tableName: "Form")
                        handler(true)
                    }
                    catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    static func find(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, by id: UUID) -> AF_Form? {
        var result: AF_Form? = nil
        do {
            let fetchRequest: NSFetchRequest<AF_Form>
            fetchRequest = AF_Form.fetchRequest()
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "guid = %@", id as CVarArg)
            
            result = try managedObjectContext.fetch(fetchRequest).first
        }
        catch {
            fatalError(error.localizedDescription)
        }
        return result
    }
    
    public static func findFromsBy(_ template: AF_Template) -> [AF_Form] {
        do {
            let fetchRequest: NSFetchRequest<AF_Form>
            fetchRequest = AF_Form.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "template = %@", template)
            
            return try Database.shared._mainContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func fetchTemplateFields(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, template: AF_Template) -> [AF_TemplateField] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AF_TemplateField.entity().name ?? "" )
        let predicate = NSPredicate(format: "template.guid = %@", template.guid! as CVarArg)
        let sort = NSSortDescriptor(keyPath: \AF_TemplateField.field_order, ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result as? [AF_TemplateField] ?? []
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func find(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, template: AF_Template, parent: UUID?) -> AF_Form? {
        let fetchRequest: NSFetchRequest<AF_Form> = AF_Form.fetchRequest()
        if let parent = parent {
            fetchRequest.predicate = NSPredicate(format: "template.guid = %@ AND parentGUID = %@", template.guid! as CVarArg, parent as CVarArg)
        }
        else {
            fetchRequest.predicate = NSPredicate(format: "template.guid = %@", template.guid! as CVarArg)
        }
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            for result in results {
                return result
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
        return nil
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, template: AF_Template, parent: UUID?) -> AF_Form {
        let form = self.init(context: managedObjectContext)
        form.guid = UUID()
        form.updated_date = Date()
        form.template = template
        
        _ = createFields(in: managedObjectContext, form: form, template: template)
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return form
    }
    
    static func createFields(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, form: AF_Form, template: AF_Template) -> [AF_FormField] {
        let templateFields = fetchTemplate(template: template)
        
        var fields: [AF_FormField] = []
        
        for field in templateFields {
            fields.append(AF_FormField.getFieldFromTemplate(form: form, templateField: field, in: managedObjectContext))
        }
        return fields
    }
    
    static func fetchTemplate(in managedObjectContext: NSManagedObjectContext = Database.shared._mainContext, template: AF_Template) -> [AF_TemplateField] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AF_TemplateField.entity().name ?? "" )
        let predicate = NSPredicate(format: "template.guid = %@", template.guid! as CVarArg)
        let sort = NSSortDescriptor(keyPath: \AF_TemplateField.field_order, ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sort]
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            return result as? [AF_TemplateField] ?? []
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
//    static func fetchFields(in managedObjectContext: NSManagedObjectContext, form: Form) -> [FormField] {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FormField.entity().name ?? "" )
//        let predicate = NSPredicate(format: "form.id = %@", form.id! as CVarArg)
//        let sort = NSSortDescriptor(keyPath: \FormField.id, ascending: true)
//        fetchRequest.predicate = predicate
//        fetchRequest.sortDescriptors = [sort]
//
//        do {
//            let result = try managedObjectContext.fetch(fetchRequest)
//            return result as? [FormField] ?? []
//
//        } catch {
//            fatalError(error.localizedDescription)
//        }
//    }
}
