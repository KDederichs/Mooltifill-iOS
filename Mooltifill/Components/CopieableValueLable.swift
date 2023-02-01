//
//  CopieableValueLable.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct CopieableValueLable: View {
    var label = ""
    var value = ""
    
    var body: some View {
        HStack{
            Text(label + ":").bold()
            Text(value)
            Button(action:{
                UIPasteboard.general.string = value
            }) {
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

struct CopieableValueLable_Previews: PreviewProvider {
    static var previews: some View {
        CopieableValueLable(label: "Foo", value: "Bar")
    }
}
