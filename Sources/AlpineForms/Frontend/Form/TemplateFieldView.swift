//
//  TemplateFieldView.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/16/22.
//

import SwiftUI
import AlpineUI

struct TemplateFieldView: View {
    
    @EnvironmentObject var formViewModel: FormViewModel
    @StateObject var viewModel: FormFieldViewModel
    
    init(template: AF_Template, templateField: AF_TemplateField, form: AF_Form) {
        _viewModel = StateObject(wrappedValue: FormFieldViewModel(template: template, templateField: templateField, form: form))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.templateField.type {
            case "Text":
                TextFieldBlock(title: viewModel.templateField.caption ?? "", value: $viewModel.formField.string_data.toUnwrapped(defaultValue: ""), changed: $formViewModel.chanaged)
            case "Dropdown":
                DropdownBlock(title: viewModel.templateField.caption ?? "", values: [["HELLO"]], selection: $viewModel.formField.string_data.toUnwrapped(defaultValue: ""), changed: $formViewModel.chanaged)
            default:
                TextDisplayBlock(title: "Unknown Field", text: viewModel.templateField.type ?? "")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6.0)
        .onChange(of: formViewModel.chanaged) { _ in
            formViewModel.save()
        }
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

//struct TemplateFieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateFieldView()
//    }
//}
