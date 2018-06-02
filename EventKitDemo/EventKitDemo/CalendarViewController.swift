//
//  CalendarViewController.swift
//  EventKitDemo
//
//  Created by Rob Timpone on 6/2/18.
//  Copyright © 2018 Rob Timpone. All rights reserved.
//

import EventKit
import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    let store = EKEventStore()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForPermission()
    }
}

private extension CalendarViewController {
    
    func checkForPermission() {
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            requestPermission()
        case .authorized:
            loadCalendarData()
        case .denied, .restricted:
            showPermissionDeniedAlert()
        }
    }
    
    func requestPermission() {
        
        store.requestAccess(to: .event) { permissionGranted, error in
            DispatchQueue.main.async {
                if permissionGranted {
                    self.loadCalendarData()
                }
                else {
                    self.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    func loadCalendarData() {
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        let events = store.events(matching: predicate)
        
        for event in events {
            
            guard let title = event.title, let startTime = event.startDate else {
                return
            }
            
            let df = DateFormatter()
            df.dateFormat = "h:mm a"
            let localStartTimeString = df.string(from: startTime)
            
            printToTextView("\(title) \(localStartTimeString)")
        }
    }
    
    func showPermissionDeniedAlert() {
        //show an alert directing the user to Settings
    }
    
    func printSelectedDateToTextView() {
        
    }
    
    func printToTextView(_ text: String) {
        let currentText = textView.text!
        textView.text = currentText + text + "\n"
    }
    
    func defaultDate() -> Date {
        let now = Date()
        return Calendar.current.startOfDay(for: now)
    }
    
    func nextDate(after date: Date) -> Date {
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else {
            fatalError("Unable to create date one day after \(date)")
        }
        return nextDate
    }
    
    func prevoiusDate(before date: Date) -> Date {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else {
            fatalError("Unable to create date one day before \(date)")
        }
        return previousDate
    }
}
