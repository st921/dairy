//
//  ContentView.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false

    @AppStorage("isCafeMode") private var isCafeMode = false

    var accentColor: Color {
        isCafeMode ? Color(red: 0.8, green: 0.4, blue: 0.2) : Color(red: 0.2, green: 0.8, blue: 1.0)
    }
    
    var textColor: Color {
        isCafeMode ? Color(red: 0.3, green: 0.2, blue: 0.1) : .white
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if isCafeMode {
                    Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()
                } else {
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ).ignoresSafeArea()
                }

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(habits) { habit in
                            NavigationLink(destination: HabitDetailView(habit: habit, isCafeMode: isCafeMode, accentColor: accentColor, textColor: textColor)) {
                                HabitCardView(habit: habit, isCafeMode: isCafeMode, accentColor: accentColor, textColor: textColor)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                                            Button(role: .destructive) {
                                                                withAnimation {
                                                                    modelContext.delete(habit)
                                                                }
                                                            } label: {
                                                                Label("削除", systemImage: "trash")
                                                            }
                                                        }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbarColorScheme(isCafeMode ? .light : .dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(isCafeMode ? Color(red: 0.96, green: 0.94, blue: 0.90) : Color.black.opacity(0.5), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) { isCafeMode.toggle() }
                    }) {
                        Image(systemName: isCafeMode ? "cup.and.saucer.fill" : "moon.stars.fill")
                            .font(.title3)
                            .foregroundStyle(accentColor)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3).foregroundStyle(accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView(isCafeMode: isCafeMode, accentColor: accentColor)
            }
            .preferredColorScheme(isCafeMode ? .light : .dark)
            .fontDesign(isCafeMode ? .serif : .default)
        }
    }
}

// ---------------------------------------------------------
// 詳細画面
// ---------------------------------------------------------
struct HabitDetailView: View {
    var habit: Habit
    var isCafeMode: Bool
    var accentColor: Color
    var textColor: Color

    var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    var body: some View {
        ZStack {
            if isCafeMode {
                Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }

            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("現在の記録").font(.caption).foregroundColor(.gray)
                        Text("\(habit.currentStreak)日").font(.system(size: 40, weight: .bold)).foregroundColor(accentColor)
                    }
                    VStack(alignment: .leading) {
                        Text("合計達成").font(.caption).foregroundColor(.gray)
                        Text("\(habit.completedDates.count)回").font(.system(size: 40, weight: .bold)).foregroundColor(textColor)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("週間レポート").font(.headline).foregroundColor(textColor).padding(.horizontal)
                    
                    Chart {
                        ForEach(last7Days, id: \.self) { date in
                            let isDone = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                            
                            BarMark(
                                x: .value("日", date, unit: .day),
                                y: .value("達成", isDone ? 1 : 0)
                            )
                            .foregroundStyle(isDone ? accentColor : Color.gray.opacity(0.2))
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 200)
                    .padding()
                    .background(isCafeMode ? Color.white : Color.white.opacity(0.05))
                    .cornerRadius(20)
                    .chartYAxis(.hidden)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(habit.title)
        .fontDesign(isCafeMode ? .serif : .default)
    }
}

// ---------------------------------------------------------
// 習慣カードのデザイン
// ---------------------------------------------------------
struct HabitCardView: View {
    var habit: Habit
    var isCafeMode: Bool
    var accentColor: Color
    var textColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(accentColor.opacity(0.2)).frame(width: 50, height: 50)
                Text(String(habit.title.prefix(1))).font(.title2).fontWeight(.bold).foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title).font(.headline).foregroundColor(textColor)
                
                Text("連続記録: \(habit.currentStreak)日 \(isCafeMode ? "☕️" : "⚡️")")
                    .font(.caption).foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    habit.toggleCompletionForToday()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }) {
                ZStack {
                    Circle().stroke(habit.isCompletedToday ? accentColor : Color.gray.opacity(0.5), lineWidth: 2).frame(width: 32, height: 32)
                    if habit.isCompletedToday {
                        Circle().fill(accentColor).frame(width: 24, height: 24)
                            .shadow(color: isCafeMode ? .clear : accentColor.opacity(0.5), radius: 5)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(isCafeMode ? Color.white : Color.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(isCafeMode ? Color.clear : Color.white.opacity(0.1), lineWidth: 1))
        .shadow(color: Color.black.opacity(isCafeMode ? 0.05 : 0.3), radius: isCafeMode ? 5 : 10, x: 0, y: 5)
    }
}

// ---------------------------------------------------------
// 追加画面
// ---------------------------------------------------------
struct AddHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    
    var isCafeMode: Bool
    var accentColor: Color

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("習慣の詳細").foregroundStyle(.gray)) {
                    TextField("例: 毎日30分プログラミング", text: $title)
                        .padding(.vertical, 8)
                }
                .listRowBackground(isCafeMode ? Color.white : Color.white.opacity(0.1))
            }
            .scrollContentBackground(.hidden)
            .background(isCafeMode ? Color(red: 0.96, green: 0.94, blue: 0.90).ignoresSafeArea() : Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea())
            .navigationTitle("新しい習慣")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let newHabit = Habit(title: title)
                        modelContext.insert(newHabit)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundStyle(accentColor)
                }
            }
            .preferredColorScheme(isCafeMode ? .light : .dark)
            .fontDesign(isCafeMode ? .serif : .default)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
