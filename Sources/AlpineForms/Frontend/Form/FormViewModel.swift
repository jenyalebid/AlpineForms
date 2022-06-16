//
//  FormViewModel.swift
//  Wildlife
//
//  Created by Jenya Lebid on 6/16/22.
//

import SwiftUI

class FormViewModel: ObservableObject {
    
    var template: AF_Template
    var fields: [AF_TemplateField]
    var form: AF_Form
    
    @Published var chanaged = false
    
    init (template: AF_Template, form: AF_Form?) {
        self.template = template
        self.form = form ?? AF_Form.create(template: template, parent: nil)
        fields = AF_Form.fetchTemplateFields(template: template)
    }
    
    func save() {
        form.update(missingRequirements: false)
        form.save()
    }
    
    func checkMissingRequirements() {
        
    }
}
