//
//  ContentView.swift
//  目標
//
//  Created by しょう on 2026/03/06.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false

    //カフェモードのオンオフを保存（trueならカフェ、falseなら近未来）
    @AppStorage("isCafeMode") private var isCafeMode = false

    //テーマ別のカラー設定（computed property）
    var accentColor: Color {
        // カフェ：テラコッタ（レンガ色）、近未来：ネオンブルー
        isCafeMode ? Color(red: 0.8, green: 0.4, blue: 0.2) : Color(red: 0.2, green: 0.8, blue: 1.0)
    }
    
    var textColor: Color {
        // カフェ：焦げ茶色、近未来：白
        isCafeMode ? Color(red: 0.3, green: 0.2, blue: 0.1) : .white
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // --- 背景の切り替え ---
                if isCafeMode {
                    Color(red: 0.96, green: 0.94, blue: 0.90) // カフェ：温かみのあるアイボリー
                        .ignoresSafeArea()
                } else {
                    LinearGradient( // 近未来：ダークグラデーション
                        colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(habits) { habit in
                            NavigationLink(destination: Text("詳細画面（グラフ）は開発中")) {
                                HabitCardView(habit: habit, isCafeMode: isCafeMode, accentColor: accentColor, textColor: textColor)
                            }
                            .buttonStyle(.plain)
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
                // --- 左上：テーマ切り替えボタン ---
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 0.5秒かけてフワッと切り替えるアニメーション
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isCafeMode.toggle()
                        }
                    }) {
                        Image(systemName: isCafeMode ? "cup.and.saucer.fill" : "moon.stars.fill")
                            .font(.title3)
                            .foregroundStyle(accentColor)
                    }
                }
                
                // --- 右上：追加ボタン ---
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(accentColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView(isCafeMode: isCafeMode, accentColor: accentColor)
            }
            // ライトモードとダークモードを強制指定
            .preferredColorScheme(isCafeMode ? .light : .dark)
            // カフェモードの時はフォントを「明朝体（セリフ体）」にしておしゃれに！
            .fontDesign(isCafeMode ? .serif : .default)
        }
    }
}

// ---------------------------------------------------------
// 習慣カードのデザイン（テーマに応じて変化）
// ---------------------------------------------------------
struct HabitCardView: View {
    var habit: Habit
    var isCafeMode: Bool
    var accentColor: Color
    var textColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(String(habit.title.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(textColor)
                
                Text("連続記録: 開発中 ☕️")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    habit.toggleCompletionForToday()
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    // シミュレーターでは鳴りませんが、実機だとブルッと震えます
                    impact.impactOccurred()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(habit.isCompletedToday ? accentColor : Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    
                    if habit.isCompletedToday {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 24, height: 24)
                            // 近未来モードの時だけ光る（シャドウ）エフェクトをつける
                            .shadow(color: isCafeMode ? .clear : accentColor.opacity(0.5), radius: 5, x: 0, y: 0)
                    }
                }
            }
        }
        .padding()
        // 背景色：カフェなら真っ白、近未来ならすりガラス風
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isCafeMode ? Color.white : Color.white.opacity(0.05))
        )
        // 枠線：近未来モードのみ表示
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isCafeMode ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
        )
        // 影：カフェはやわらかく、近未来はシャープに
        .shadow(color: Color.black.opacity(isCafeMode ? 0.05 : 0.3), radius: isCafeMode ? 5 : 10, x: 0, y: 5)
    }
}

// ---------------------------------------------------------
// 追加画面（テーマに応じて変化）
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
