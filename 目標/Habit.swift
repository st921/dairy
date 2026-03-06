//
//  Habit.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//


import SwiftUI
import SwiftData

@Model
final class Habit {
    var title: String
    var creationDate: Date
    var completedDates: [Date]

    init(title: String) {
        self.title = title
        self.creationDate = Date()
        self.completedDates = []
    }

    @Transient var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains { calendar.isDateInToday($0) }
    }

    func toggleCompletionForToday() {
        let calendar = Calendar.current
        if let index = completedDates.firstIndex(where: { calendar.isDateInToday($0) }) {
            completedDates.remove(at: index)
        } else {
            completedDates.append(Date())
        }
    }
}