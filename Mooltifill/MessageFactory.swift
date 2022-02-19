//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
protocol MessageFactory {
    func deserialize(data: [Data]) -> MooltipassMessage?
    func serialize(msg: MooltipassMessage) -> [Data]
}