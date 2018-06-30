//
//  EventViewModel.swift
//  EventKitDemo
//
//  Created by Rob Timpone on 6/6/18.
//  Copyright © 2018 Rob Timpone. All rights reserved.
//

import EventKit
import Foundation

struct EventViewModel {
    
    var title: String
    var location: String? = nil
    var startTime: String
    var endTime: String
    var isAllDay: Bool
    var calendar: String
    
    init(event: EKEvent) {
        
        title = event.title
        
        if let location = event.location, !location.isEmpty {
            self.location = location
        }
        
        startTime = EventViewModel.timeString(from: event.startDate)
        endTime = EventViewModel.timeString(from: event.endDate)
        
        isAllDay = event.isAllDay
        calendar = event.calendar.title
    }
    
    var consoleOutput: String {
        
        var output = "\(title)\n"
        
        if isAllDay {
            output += "All Day\n"
        }
        else {
            output += "\(startTime) - \(endTime)\n"
        }
        
        if let location = location {
            output += "\(location)\n"
        }
        
        output += "\(calendar)\n"
        
        return output
    }
}

private extension EventViewModel {
    
    private static var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }
    
    private static func timeString(from date: Date) -> String {
        return EventViewModel.dateFormatter.string(from: date)
    }
}
