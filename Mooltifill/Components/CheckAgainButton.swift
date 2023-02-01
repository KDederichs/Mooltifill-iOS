//
//  CheckAgainButton.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct CheckAgainButton: View {
    let bleManager = BleManager.shared
    
    var body: some View {
        Button("Check again") {
            bleManager.bleManager.getStatus()
        }
    }
}

struct CheckAgainButton_Previews: PreviewProvider {
    static var previews: some View {
        CheckAgainButton()
    }
}
