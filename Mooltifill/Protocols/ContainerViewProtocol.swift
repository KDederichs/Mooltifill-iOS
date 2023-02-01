//
//  ContainerViewProtocol.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 01.02.23.
//

import Foundation
import SwiftUI

protocol ContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}
