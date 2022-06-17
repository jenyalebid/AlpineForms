//
//InnerFormListView.swift
//  
//
//  Created by Jenya Lebid on 6/17/22.
//

import SwiftUI

struct InnerFormListView: View {
    
    @FetchRequest private var forms: FetchedResults<AF_Form>
    
    @EnvironmentObject var viewModel: FormListViewModel
    
    var title: String
    var inner: Bool
    
    public init(template: AF_Template, predicate: NSPredicate, title: String, inner: Bool = true) {
        self._forms = FetchRequest(entity: AF_Form.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \AF_Form.updated_date, ascending: true)], predicate: predicate, animation: .default)
        self.title = title
        self.inner = inner
    }
    
    var body: some View {
        if inner {
            List {
                Section("\(viewModel.template.name ?? "") Forms") {
                    formsList
                }
            }
            .listStyle(.plain)
            .navigationTitle(title)
        }
        else {
            formsList
        }
    }
    
    var formsList: some View {
        ForEach(forms, id: \.self) { form in
            VStack(alignment: .leading, spacing: 6) {
                Text("\(form.updated_date ?? Date())")
                ListAlertBlock(missingRequirements: form.missingRequirements_, notExported: form.changed_)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selection(form: form)
            }
        }
    }
}

//struct InnerFormListView_Previews: PreviewProvider {
//    static var previews: some View {
//        InnerFormListView()
//    }
//}
