//
//  FormListView.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import SwiftUI

public struct FormListView: View {
        
    @FetchRequest private var forms: FetchedResults<AF_Form>
    
    var template: AF_Template
    
    public init(template: AF_Template) {
        self.template = template
        self._forms = FetchRequest(entity: AF_Form.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AF_Form.updated_date, ascending: true)], predicate: NSPredicate(format: "template == %@", template), animation: .default)
    }
    
    public var body: some View {
        List {
            ForEach(forms, id: \.self) { form in
                Text("\(form.updated_date ?? Date())")
                    .onTapGesture {
                        selection(form: form)
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    selection()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(template.name ?? "")")
    }
    
    func selection(form: AF_Form? = nil) {
        FormSelector.shared.template = template
        FormSelector.shared.form = form
        NotificationCenter.default.post(name: Notification.Name("FormSelected"), object: nil)
    }
}

//struct FormListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormsListView()
//    }
//}
