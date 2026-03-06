import SwiftUI
import Charts

struct HabitDetailView: View {
    var habit: Habit
    
    // 過去7日間の日付データを生成する計算プロパティ
    var last7Days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("過去7日間の記録")
                .font(.headline)
                .padding(.horizontal)

            // Swift Chartsによるグラフ描画
            Chart {
                ForEach(last7Days, id: \.self) { date in
                    let isCompleted = habit.completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    
                    BarMark(
                        x: .value("日付", date, unit: .day),
                        y: .value("達成", isCompleted ? 1 : 0) // 達成していれば1、していなければ0
                    )
                    .foregroundStyle(isCompleted ? Color.green : Color.gray.opacity(0.3))
                }
            }
            .chartYAxis(.hidden) // Y軸の数字を隠す
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated)) // 曜日を表示
                }
            }
            .frame(height: 200)
            .padding()
            
            Spacer()
        }
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}