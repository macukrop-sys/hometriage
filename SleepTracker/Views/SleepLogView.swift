import SwiftUI
import SwiftData

struct SleepLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SleepEntry.bedtime, order: .reverse) private var entries: [SleepEntry]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Sleep Data",
                        systemImage: "moon.zzz",
                        description: Text("Tap + to log your first night of sleep.")
                    )
                } else {
                    List {
                        ForEach(entries) { entry in
                            SleepEntryRow(entry: entry)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                }
            }
            .navigationTitle("Sleep Log")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSleepEntryView()
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

struct SleepEntryRow: View {
    let entry: SleepEntry

    private var dayFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.bedtime, formatter: dayFormatter)
                .font(.headline)

            HStack(spacing: 16) {
                Label(timeFormatter.string(from: entry.bedtime), systemImage: "moon.fill")
                    .foregroundStyle(.indigo)
                Label(timeFormatter.string(from: entry.wakeTime), systemImage: "sun.max.fill")
                    .foregroundStyle(.orange)
            }
            .font(.subheadline)

            Text(entry.durationFormatted)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SleepLogView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}
