//
//  HabitTrackerApp.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//


import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Habitモデルのデータを保存・管理するための設定
        .modelContainer(for: Habit.self)
    }
}