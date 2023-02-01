//
//  OpenBluetoothSettingsButton.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct OpenBluetoothSettingsButton: View {
    var body: some View {
        Button("Open Settings") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
}

struct OpenBluetoothSettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        OpenBluetoothSettingsButton()
    }
}
