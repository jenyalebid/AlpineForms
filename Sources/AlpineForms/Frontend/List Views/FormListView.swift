//
//  FormListView.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/14/22.
//

import SwiftUI

public struct FormListView: View {
        
    @StateObject var viewModel: FormListViewModel
        
    public init(template: AF_Template) {
        _viewModel = StateObject(wrappedValue: FormListViewModel(template: template))
    }
    
    public var body: some View {
        List {
            Section("Form Status") {
                NavigationLink(destination: InnerFormListView(template: viewModel.template, predicate: viewModel.formListPredicate(listType: .notExported), title: "Not Exported")
                    .environmentObject(viewModel)) {
                    Text("Not Exported")
                }
                .listRowBackground(Color("NotExported"))
                NavigationLink(destination: InnerFormListView(template: viewModel.template, predicate: viewModel.formListPredicate(listType: .modified), title: "Modified")
                    .environmentObject(viewModel)) {
                    Text("Modified")
                }
                .listRowBackground(Color("Modified"))
            }
            Section("\(viewModel.template.name ?? "") Forms") {
                InnerFormListView(template: viewModel.template, predicate: viewModel.formListPredicate(listType: .regular), title: "", inner: false)
                    .environmentObject(viewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.selection()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(viewModel.template.name ?? "")")
    }
}

//struct FormListView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormsListView()
//    }
//}
