//
//  FormListViewModel.swift
//  Wildlife
//
//  Created by Jenya Lebid on 6/17/22.
//

import SwiftUI

class FormListViewModel: ObservableObject {
    
    enum ListType {
        case notExported
        case modified
        case regular
    }
    
    var template: AF_Template
    
    init(template: AF_Template) {
        self.template = template
    }
    
    func selection(form: AF_Form? = nil) {
        FormSelector.shared.template = template
        FormSelector.shared.form = form
        NotificationCenter.default.post(name: Notification.Name("FormSelected"), object: nil)
    }
    
    func formListPredicate(listType: ListType) -> NSPredicate {
        switch listType {
        case .notExported:
            return NSPredicate(format: "template = %@ AND changed_ = TRUE", template)
        case .modified:
            return NSPredicate(format: "template = %@ AND updated_date >= %@", template, Calendar.current.date(byAdding: .day, value: -1, to: Date())! as CVarArg)
        case .regular:
            return NSPredicate(format: "template = %@", template)
        }
    }
}
