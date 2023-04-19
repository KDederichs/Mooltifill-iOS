//
//  NodeContentModel.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import Foundation
import Combine

class NoteContentModel: ObservableObject
{
    let bleManager = BleManager.shared
    
    @Published var content: String = ""
    @Published var isLoading = true
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init()
    {
        bleManager
            .noteContent
            .receive(on: RunLoop.main)
            .assign(to: \.content, on: self)
            .store(in: &cancellableSet)
        
        bleManager
            .isLoading
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellableSet)
    }
    
    func fetchNote(noteName: String) {
        bleManager.getNoteData(noteName: noteName)
    }
}
