//
//  BluetoothDisabledView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct BluetoothDisabledView: View {
    var body: some View {
        VStack {
            Text("Your Bluetooth is disabled.")
            Text("This App requires Bluetooth to work,")
            Text("so please enable it.")
            HStack {
                OpenBluetoothSettingsButton().padding()
                CheckAgainButton().padding()
            }.padding()
        }
    }
}

struct BluetoothDisabledView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothDisabledView()
    }
}
