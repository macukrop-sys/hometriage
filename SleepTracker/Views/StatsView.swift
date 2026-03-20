import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \SleepEntry.bedtime, order: .reverse) private var entries: [SleepEntry]

    private var last7Days: [SleepEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.bedtime >= cutoff }.reversed()
    }

    private var averageDuration: TimeInterval? {
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0.0) { $0 + $1.duration }
        return total / Double(entries.count)
    }

    private var averageBedtime: Date? {
        guard !entries.isEmpty else { return nil }
        let calendar = Calendar.current
        let totalMinutes = entries.reduce(0) { sum, entry in
            let comps = calendar.dateComponents([.hour, .minute], from: entry.bedtime)
            var mins = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
            // Adjust for after-midnight bedtimes
            if mins < 720 { mins += 1440 }
            return sum + mins
        }
        var avgMinutes = totalMinutes / entries.count
        if avgMinutes >= 1440 { avgMinutes -= 1440 }
        return calendar.date(bySettingHour: avgMinutes / 60, minute: avgMinutes % 60, second: 0, of: Date())
    }

    private var averageWakeTime: Date? {
        guard !entries.isEmpty else { return nil }
        let calendar = Calendar.current
        let totalMinutes = entries.reduce(0) { sum, entry in
            let comps = calendar.dateComponents([.hour, .minute], from: entry.wakeTime)
            return sum + (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        }
        let avgMinutes = totalMinutes / entries.count
        return calendar.date(bySettingHour: avgMinutes / 60, minute: avgMinutes % 60, second: 0, of: Date())
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.bar",
                        description: Text("Log some sleep to see your stats.")
                    )
                } else {
                    List {
                        Section("Averages") {
                            if let avg = averageDuration {
                                StatRow(
                                    icon: "clock.fill",
                                    color: .blue,
                                    label: "Avg Duration",
                                    value: formatDuration(avg)
                                )
                            }
                            if let bed = averageBedtime {
                                StatRow(
                                    icon: "moon.fill",
                                    color: .indigo,
                                    label: "Avg Bedtime",
                                    value: formatTime(bed)
                                )
                            }
                            if let wake = averageWakeTime {
                                StatRow(
                                    icon: "sun.max.fill",
                                    color: .orange,
                                    label: "Avg Wake Time",
                                    value: formatTime(wake)
                                )
                            }
                            StatRow(
                                icon: "number",
                                color: .green,
                                label: "Total Entries",
                                value: "\(entries.count)"
                            )
                        }

                        if !last7Days.isEmpty {
                            Section("Last 7 Days") {
                                Chart(last7Days) { entry in
                                    BarMark(
                                        x: .value("Date", entry.bedtime, unit: .day),
                                        y: .value("Hours", entry.duration / 3600)
                                    )
                                    .foregroundStyle(.indigo.gradient)
                                    .cornerRadius(4)
                                }
                                .chartYAxis {
                                    AxisMarks(values: .stride(by: 2)) { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let hours = value.as(Double.self) {
                                                Text("\(Int(hours))h")
                                            }
                                        }
                                    }
                                }
                                .frame(height: 200)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct StatRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}
