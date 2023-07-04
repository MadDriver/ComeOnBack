//
//  PagingViewModel.swift
//  ComeOnBack
//
//  Created by Calvin Shultz on 3/11/23.
//

import SwiftUI
import OSLog

final class PagingViewModel: ObservableObject {
    private let logger = Logger(subsystem: Logger.subsystem, category: "PagingViewModel")
    @Published var timeType: TimeType = .standard
    @Published var allControllers: [Controller] = []
    @Published var onBreak: [Controller] = []
    @Published var onPosition: [Controller] = []
    @Published var date = Date()
    
    func getControllers(withInitials initials: [String]) -> [Controller] {
        return allControllers.filter {initials.contains($0.initials) }
    }
    
    func shortPoll() async throws {
        logger.info("shortPoll()")
        let controllers = try await API().getSignedInControllers()
        DispatchQueue.main.async {
            self.onPosition = controllers.filter { $0.status == .ON_POSITION }
            self.onBreak = controllers.filter { $0.status == .PAGED_BACK }
            self.onBreak.append(contentsOf: controllers.filter { $0.status == .AVAILABLE })
            self.logger.info("onPositionn count: \(self.onPosition.count)")
            self.logger.info("onBreak count: \(self.onBreak.count)")
        }
    }
    
    let positions = [
        "DR1", "DR2", "DR3", "DR4", "AR1", "AR2", "AR3", "AR4", "FR1", "FR2", "FR3", "FR4", "SR1", "SR2", "SR4", "FDCD", "MO1", "MO2", "MO3", "CI", "GJT", "PUB", "TBD"
    
    ]
    let beBackTimes = [
        "10", "15", "30", "45"
    ]
    let positionRows = [
        GridItem(), GridItem(), GridItem(), GridItem()
    ]
    let beBackTimeRows = [
        GridItem(), GridItem()
    ]
    
    var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        switch timeType {
            case .military:
                formatter.dateFormat = "HH:mm:ss"
            case .standard:
                formatter.dateFormat = "hh:mm:ss a"
        }
        return formatter
    }
    
    var beBackTimeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    func getBeBackTime(minute: String) -> String {
        
        let calendar = Calendar.current
        let timeToAdd = Int(minute)!
        let dateToEdit = calendar.date(byAdding: .minute, value: timeToAdd, to: date)!
        let m = calendar.component(.minute, from: dateToEdit)
        
        if m % 5 != 0 {
            let r = 5 - (m % 5)
            let minuteToAdd = timeToAdd + r
            let actualDate = calendar.date(byAdding: .minute, value: minuteToAdd, to: date)!
            return beBackTimeFormat.string(from: actualDate)
        } else {
            return beBackTimeFormat.string(from: dateToEdit)
        }
        
    }
    
    func timeString(date: Date) -> String {
        let time = timeFormat.string(from: date)
        return time
    }
    
    var updateTimer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.date = Date()
        })
    }
    
    func customBeBackTimeChanged(time: Int) -> String {
        let calendar = Calendar.current
        let dateOne = calendar.date(bySetting: .minute, value: time, of: date)!
        let dateString = beBackTimeFormat.string(from: dateOne)
        return dateString
    }
    
}