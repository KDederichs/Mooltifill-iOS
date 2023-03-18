//
// Created by Kai Dederichs on 19.02.22.
//

import Foundation
protocol MessageFactory {
    func deserialize(data: [Data], debug: Bool) -> MooltipassMessage?
    func serialize(msg: MooltipassMessage) -> [Data]
}
