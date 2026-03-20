import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            SleepLogView()
                .tabItem {
                    Label("Sleep Log", systemImage: "bed.double.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}
