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
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    let store = EKEventStore()
    var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        changeDate(to: defaultDate())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForPermission()
    }
    
    @IBAction func previousDayAction(_ sender: UIButton) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let date = previousDate(before: selectedDate)
        changeDate(to: date)
    }
    
    @IBAction func nextDayAction(_ sender: UIButton) {
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let date = nextDate(after: selectedDate)
        changeDate(to: date)
    }
}

private extension CalendarViewController {
    
    func loadCalendarData(for date: Date) {
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let calendars = store.calendars(for: .event)
        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        let events = store.events(matching: predicate)
        
        for event in events {
            let eventViewModel = EventViewModel(event: event)
            let output = eventViewModel.consoleOutput
            printToTextView(output)
        }
    }
    
    func showPermissionDeniedAlert() {
        //show an alert directing the user to Settings
    }
    
    func updateDateLabel(for date: Date) {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        selectedDateLabel.text = df.string(from: date)
    }
    
    func changeDate(to date: Date) {
        selectedDate = date
        updateDateLabel(for: date)
        clearTextView()
        loadCalendarData(for: date)
    }
    
    // MARK: - Permissions
    
    func checkForPermission() {
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            requestPermission()
        case .authorized:
            loadCalendarData(for: selectedDate)
        case .denied, .restricted:
            showPermissionDeniedAlert()
        }
    }
    
    func requestPermission() {
        
        store.requestAccess(to: .event) { permissionGranted, error in
            DispatchQueue.main.async {
                if permissionGranted {
                    self.loadCalendarData(for: self.selectedDate)
                }
                else {
                    self.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    // MARK: - Text View
    
    func clearTextView() {
        textView.text = ""
    }
    
    func printToTextView(_ text: String) {
        let currentText = textView.text!
        textView.text = currentText + text + "\n"
    }
    
    func printBlankLineToTextView() {
        let currentText = textView.text!
        textView.text = currentText + "\n"
    }
    
    // MARK: - Date Management
    
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
    
    func previousDate(before date: Date) -> Date {
        guard let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: date) else {
            fatalError("Unable to create date one day before \(date)")
        }
        return previousDate
    }
}
