//
//  ContentView.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // データベースからHabitのリストを取得（作成日順）
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false

    let themeColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        HStack {
                            Text(habit.title)
                                .font(.headline)
                            Spacer()
                            // チェックボタン
                            Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompletedToday ? .green : .gray)
                                .font(.title2)
                                .onTapGesture {
                                    // タップで完了状態を切り替え
                                    habit.toggleCompletionForToday()
                                }
                        }
                    }
                }
                .onDelete(perform: deleteHabits)
            }
            .navigationTitle("習慣トラッカー")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView()
            }
        }
    }

    private func deleteHabits(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(habits[index])
        }
    }
}

//習慣を追加するサブ画面
struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("習慣のタイトル (例: 毎日30分読書)", text: $title)
            }
            .navigationTitle("新しい習慣")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let newHabit = Habit(title: title)
                        modelContext.insert(newHabit)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview{
    ContentView()
        .modelContainer(for:Habit.self,inMemory:true)
}
