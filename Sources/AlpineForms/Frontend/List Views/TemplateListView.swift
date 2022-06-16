//
//  TemplateListView.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import SwiftUI

public struct TemplateListView: View {

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \AF_Template.name, ascending: true)]) var templates: FetchedResults<AF_Template>
        
    public init() {
        
    }
    
    public var body: some View {
        ForEach(templates) { template in
            NavigationLink(destination: FormListView(template: template)) {
                Text(template.name ?? "")
            }
        }
    }
}

//struct TemplateListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateListView()
//    }
//}
