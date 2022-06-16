//
//  FormView.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/16/22.
//

import SwiftUI

public struct FormView: View {
    
    @StateObject var viewModel: FormViewModel
    
    public init(template: AF_Template, form: AF_Form?) {
        _viewModel = StateObject(wrappedValue: FormViewModel(template: template, form: form))
    }
    
    public var body: some View {
        ScrollViewReader { view in
            ScrollView {
                VStack {
                    ForEach(viewModel.fields) { field in
                        TemplateFieldView(template: viewModel.template, templateField: field, form: viewModel.form)
                            .environmentObject(viewModel)
                    }
                }
            }
        }
    }
}

//struct FormView_Previews: PreviewProvider {
//    static var previews: some View {
//        FormView()
//    }
//}
