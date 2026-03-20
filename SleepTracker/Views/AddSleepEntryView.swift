import SwiftUI
import SwiftData

struct AddSleepEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var bedtime = defaultBedtime
    @State private var wakeTime = defaultWakeTime
    @State private var notes = ""

    private static var defaultBedtime: Date {
        Calendar.current.date(
            bySettingHour: 22, minute: 30, second: 0, of: Date()
        ) ?? Date()
    }

    private static var defaultWakeTime: Date {
        Calendar.current.date(
            bySettingHour: 7, minute: 0, second: 0, of: Date()
        ) ?? Date()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Bedtime", selection: $bedtime)
                        .datePickerStyle(.compact)
                    DatePicker("Wake Time", selection: $wakeTime)
                        .datePickerStyle(.compact)
                } header: {
                    Text("Sleep Times")
                }

                Section {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3)
                } header: {
                    Text("Notes")
                }

                if wakeTime > bedtime {
                    Section {
                        let duration = wakeTime.timeIntervalSince(bedtime)
                        let hours = Int(duration) / 3600
                        let minutes = (Int(duration) % 3600) / 60
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(hours)h \(minutes)m")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Log Sleep")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = SleepEntry(
                            bedtime: bedtime,
                            wakeTime: wakeTime,
                            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        modelContext.insert(entry)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddSleepEntryView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}
