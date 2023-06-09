//
//  Controller.swift
//  ComeOnBack
//
//  Created by Calvin Shultz on 3/10/23.
//

import Foundation

enum ControllerStatus: String, Codable {
    case AVAILABLE
    case PAGED_BACK
    case ON_POSITION
    case OTHER_DUTIES
}

struct Controller: Hashable, Identifiable, Codable  {
    var id = UUID()
    var initials: String
    var area: String
    var isDev: Bool
    var status: ControllerStatus
    var beBack: BeBack? = nil
    
    enum CodingKeys: String, CodingKey {
        case initials
        case area
        case isDev
        case status
        case beBack
    }
    
    static func newControllerFrom(_ controller: Controller, withStatus status: ControllerStatus) -> Controller {
        var newController = controller
        newController.status = status
        if status == .AVAILABLE {
            newController.beBack = nil
        }
        return newController
    }
}

extension Controller: CustomStringConvertible {
    var description: String {
        if let beBack = self.beBack {
            return "\(initials)-\(status)-\(beBack)"
        }
        return "\(initials)-\(status)"
    }
    
}

extension Controller {
    static let mock_data = [
        Controller(initials: "XX", area: "Departure", isDev: false, status: .AVAILABLE),
        Controller(initials: "YY", area: "Arrival", isDev: true, status: .ON_POSITION),
        Controller(initials: "ZZ", area: "Arrival", isDev: false, status: .PAGED_BACK, beBack:
                    BeBack(initials: "ZZ", time: try! Time("06:15"))
                  )
    ]
}
