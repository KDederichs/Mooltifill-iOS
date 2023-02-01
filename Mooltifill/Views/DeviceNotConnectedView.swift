//
//  DeviceNotConnectedView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct DeviceNotConnectedView: View {
    var body: some View {
        VStack {
            Text("It seems like your Mooltipass is not paired.")
            Text("Please pair it in the Settings and try again.")
            HStack {
                OpenBluetoothSettingsButton().padding()
                CheckAgainButton().padding()
            }.padding()
        }
    }
}

struct DeviceNotConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceNotConnectedView()
    }
}
