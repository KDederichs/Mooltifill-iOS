//
//  NoteListModel.swift
//  Mooltifill
//
//  Created by Kai Dederichs on 19.04.23.
//

import Foundation
import Combine

struct ListNode: Identifiable, Hashable
{
    let name: String
    let id = UUID()
}

class NoteListModel: ObservableObject
{
    let bleManager = BleManager.shared
    
    @Published var notes: [ListNode] = []
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init()
    {
        bleManager
            .notes
            .map{ noteNames in return noteNames.map{noteName in ListNode(name: noteName)}}
            .receive(on: RunLoop.main)
            .assign(to: \.notes, on: self)
            .store(in: &cancellableSet)
    }
}
