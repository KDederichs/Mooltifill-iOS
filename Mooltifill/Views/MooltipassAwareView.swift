//
//  MooltipassAwareView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI
import Combine

struct MooltipassAwareView<Content: View>: ContainerView {
    
    var content: () -> Content
    @StateObject private var model = MooltipassAwareModel()
    
    var body: some View {
        if (model.isLocked) {
            DeviceLockedView()
        } else if (!model.isConnected) {
            DeviceNotConnectedView()
        } else if (!model.bluetoothEnabled) {
            BluetoothDisabledView()
        } else {
            content()
        }
    }
}

struct MooltipassAwareView_Previews: PreviewProvider {
    static var previews: some View {
        MooltipassAwareView {
            GetPasswordView()
        }
    }
}
