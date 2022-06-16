//
//  FormFieldViewModel.swift
//  Wildlife
//
//  Created by Jenya Lebid on 6/16/22.
//

import SwiftUI

class FormFieldViewModel: ObservableObject {
    
    @Published var formField: AF_FormField
    var templateField: AF_TemplateField
    
    init(template: AF_Template, templateField: AF_TemplateField, form: AF_Form) {
        self.templateField = templateField
        formField = AF_FormField.fetchField(templateField: templateField, form: form)
    }
}
