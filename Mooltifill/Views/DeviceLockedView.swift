//
//  DeviceLockedView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import SwiftUI

struct DeviceLockedView: View {
    var body: some View {
        VStack {
            Image("Lock")
            Text("Mooltipass is locked, please unlock")
        }
    }
}

struct DeviceLockedView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceLockedView()
    }
}
