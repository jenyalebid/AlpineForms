//
//  FormsListView.swift
//  Wildlife
//
//  Created by Jenya Lebid on 6/14/22.
//

import SwiftUI

public struct FormsListView: View {
    
//    @Environment(\.managedObjectContext) var context
    
//    @FetchRequest private var forms: FetchedResults<Form>
    
    var forms: [Form]

    public init(template: Template) {
//        self._forms = FetchRequest(entity: Form.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Form.updated_date, ascending: true)], predicate: NSPredicate(format: "template == %@", template), animation: .default)
        
        forms = Form.findFromsBy(template)
    }
    
    public var body: some View {
        List {
            ForEach(forms, id: \.self) { form in
                Text("\(form.updated_date ?? Date())")
            }
        }
    }
}

//struct FormsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormsListView()
//    }
//}
