//
//  FormSelector.swift
//  Wildlife
//
//  Created by Jenya Lebid on 6/16/22.
//

import Foundation

public struct FormSelector {
    
    public static var shared = FormSelector()
    
    public var template: AF_Template?
    public var form: AF_Form?
}
