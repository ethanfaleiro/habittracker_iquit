import SwiftUI

struct ContentView: View {
    @StateObject private var store = HabitStore()
    @StateObject private var chatSession = ChatSession()

    var body: some View {
        Group {
            if store.isSetup {
                MainTabView()
                    .environmentObject(store)
                    .environmentObject(chatSession)
            } else {
                SetupView()
                    .environmentObject(store)
            }
        }
        .preferredColorScheme(store.theme.colorScheme)
        // Forces status bar text (time, battery) to contrast against theme background
        .statusBarHidden(false)
    }
}

struct MainTabView: View {
    @EnvironmentObject var store: HabitStore
    @EnvironmentObject var chatSession: ChatSession
    @State private var selectedTab = 0

    var t: ThemeColors { store.theme }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(store)
                .tabItem { Label("Tracker", systemImage: "circle.grid.3x3") }
                .tag(0)

            ChatView()
                .environmentObject(store)
                .environmentObject(chatSession)
                .tabItem { Label("Check-in", systemImage: "bubble.left") }
                .tag(1)

            StatsView()
                .environmentObject(store)
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(2)

            SettingsView()
                .environmentObject(store)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(3)
        }
        .tint(t.accent)
    }
}

extension Color {
    init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
