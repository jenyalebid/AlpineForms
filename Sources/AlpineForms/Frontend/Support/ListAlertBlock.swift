//
//  ListAlertBlock.swift
//  AlpineForms
//
//  Created by Jenya Lebid on 6/17/22.
//

import SwiftUI

struct ListAlertBlock: View {
    
    var missingRequirements: Bool
    var notExported: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            if missingRequirements || notExported {
                Divider()
                    .frame(width: 20)
            }
            if missingRequirements {
                Text("Missing Required Fields")
                    .foregroundColor(Color.red)
                    .font(.caption2)
            }
            if notExported {
                Text("Not Exported")
                    .foregroundColor(Color("NotExported"))
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ListAlertBlock_Previews: PreviewProvider {
    static var previews: some View {
        ListAlertBlock(missingRequirements: true, notExported: true)
    }
}
