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