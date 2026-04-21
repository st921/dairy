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

    // 今日のタスクが完了しているか判定
    @Transient var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains { calendar.isDateInToday($0) }
    }

    // 連続記録（ストリーク）を計算する機能
    @Transient var currentStreak: Int {
        let calendar = Calendar.current
        
        let uniqueDays = Set(completedDates.map { calendar.startOfDay(for: $0) })
        let sortedDays = uniqueDays.sorted(by: >)
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        if !sortedDays.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            if !sortedDays.contains(checkDate) {
                return 0
            }
        }
        
        while sortedDays.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
    }

    // 今日の完了状態を切り替える関数
    func toggleCompletionForToday() {
        let calendar = Calendar.current
        if let index = completedDates.firstIndex(where: { calendar.isDateInToday($0) }) {
            completedDates.remove(at: index)
        } else {
            completedDates.append(Date())
        }
    }
}
