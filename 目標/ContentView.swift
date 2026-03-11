//
//  ContentView.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    //データベースからHabitのリストを取得（作成日順）
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false

    let themeColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    
    var body: some View {
            NavigationStack {
                ZStack {
                    // 背景：ダークなグラデーション
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(habits) { habit in
                                NavigationLink(destination: HabitDetailView(habit: habit)) {
                                    HabitCardView(habit: habit, themeColor: themeColor)
                                }
                                .buttonStyle(.plain) // リンク特有のタップ時の色変化を消す
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Habit Tracker")
                // タイトル文字を白に
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.black.opacity(0.5), for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(themeColor)
                        }
                    }
                }
                .sheet(isPresented: $showingAddSheet) {
                    AddHabitView()
                }
                //常にダークモードで表示（お好みで外してください）
                .preferredColorScheme(.dark)
            }
        }
    }

    // --------------------------------------------------------
    // 習慣を1つ表示する「カード」のデザイン（Glassmorphism風）
    // --------------------------------------------------------
    struct HabitCardView: View {
        var habit: Habit
        var themeColor: Color
        @Environment(\.modelContext) private var modelContext

        var body: some View {
            HStack(spacing: 16) {
                // 左側のアイコン（文字の頭文字）
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Text(String(habit.title.prefix(1))) // タイトルの1文字目
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(themeColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("連続記録: 開発中 🔥") // 今後実装する機能のプレースホルダー
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // スタイリッシュなチェックボタン
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        habit.toggleCompletionForToday()
                        // 触覚フィードバック（ブルッと震わせる）
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                }) {
                    ZStack {
                        Circle()
                            .stroke(habit.isCompletedToday ? themeColor : Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 32, height: 32)
                        
                        if habit.isCompletedToday {
                            Circle()
                                .fill(themeColor)
                                .frame(width: 24, height: 24)
                                .shadow(color: themeColor.opacity(0.5), radius: 5, x: 0, y: 0) // ネオン風の光沢
                        }
                    }
                }
            }
            .padding()
            // すりガラス風の背景（Glassmorphism）
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
            // カードの枠線
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            // カードの影
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    struct AddHabitView: View {
        @Environment(\.modelContext) private var modelContext
        @Environment(\.dismiss) private var dismiss
        @State private var title = ""

        var body: some View {
            NavigationStack {
                Form {
                    Section(header: Text("習慣の詳細").foregroundStyle(.gray)) {
                        TextField("例: 毎日30分プログラミング", text: $title)
                            .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.white.opacity(0.1))
                }
                .scrollContentBackground(.hidden) // フォームの標準背景を消す
                .background(Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea())
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
                        .foregroundStyle(Color(red: 0.2, green: 0.8, blue: 1.0))
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }

#Preview{
    ContentView()
        .modelContainer(for:Habit.self,inMemory:true)
}
