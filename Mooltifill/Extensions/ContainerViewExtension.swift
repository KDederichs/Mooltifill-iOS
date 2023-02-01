//
//  ContainerView.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import Foundation
import SwiftUI

extension ContainerView {
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }
}
