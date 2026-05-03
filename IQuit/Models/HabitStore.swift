import Foundation
import SwiftUI
import Combine
import UserNotifications

struct RelapseRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
     var daysClean: Int
}

struct StatRecord: Codable, Identifiable {
    var id: UUID = UUID()
    var endDate: Date
    var streak: Int
    var habitName: String
}

class HabitStore: ObservableObject {
    @Published var habitName: String        { didSet { save() } }
    @Published var startDate: Date          { didSet { save() } }
    @Published var relapses: [RelapseRecord]{ didSet { save() } }
    @Published var isSetup: Bool            { didSet { save() } }
    @Published var stats: [StatRecord]      { didSet { save() } }
    @Published var currentTheme: AppTheme  { didSet { save() } }
    @Published var customBgHex: String      { didSet { save() } }
    @Published var customAccentHex: String  { didSet { save() } }

    var customBgColor:     Color { Color(hex: customBgHex) }
    var customAccentColor: Color { Color(hex: customAccentHex) }

    var theme: ThemeColors {
        ThemeColors.resolve(theme: currentTheme, customBg: customBgColor, customAccent: customAccentColor)
    }
    @Published var viewingYear: Int         { didSet { save() } }
    @Published var reminderEnabled: Bool     { didSet { save(); reminderEnabled ? scheduleReminder() : cancelReminder() } }
    @Published var reminderHour: Int         { didSet { save(); if reminderEnabled { scheduleReminder() } } }
    @Published var reminderMinute: Int       { didSet { save(); if reminderEnabled { scheduleReminder() } } }

    private let defaults = UserDefaults.standard

    init() {
        self.habitName    = defaults.string(forKey: "habitName") ?? ""
        self.startDate    = (defaults.object(forKey: "startDate") as? Date) ?? Date()
        self.isSetup      = defaults.bool(forKey: "isSetup")
        self.viewingYear     = defaults.integer(forKey: "viewingYear") == 0 ? 1 : defaults.integer(forKey: "viewingYear")
        self.reminderEnabled = defaults.bool(forKey: "reminderEnabled")
        self.reminderHour    = defaults.integer(forKey: "reminderHour") == 0 ? 21 : defaults.integer(forKey: "reminderHour")
        self.reminderMinute  = defaults.integer(forKey: "reminderMinute")

        if let raw = defaults.string(forKey: "currentTheme"),
           let t = AppTheme(rawValue: raw) { self.currentTheme = t }
        else { self.currentTheme = .dark }
        self.customBgHex     = defaults.string(forKey: "customBgHex")     ?? "0D0D0D"
        self.customAccentHex = defaults.string(forKey: "customAccentHex") ?? "E8E0D0"

        if let data = defaults.data(forKey: "relapses"),
           let decoded = try? JSONDecoder().decode([RelapseRecord].self, from: data) {
            self.relapses = decoded
        } else { self.relapses = [] }

        if let data = defaults.data(forKey: "stats"),
           let decoded = try? JSONDecoder().decode([StatRecord].self, from: data) {
            self.stats = decoded
        } else { self.stats = [] }
    }

    // Total days since start (ever)
    var totalDaysSinceStart: Int {
        max(0, Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0)
    }

    // Days in the currently viewed year window
    var daysSinceStart: Int { totalDaysSinceStart }

    // Which year segment are we in? (year 1 = days 1-365, year 2 = 366-730, etc.)
    var currentYear: Int {
        max(1, (totalDaysSinceStart / 365) + 1)
    }

    var maxUnlockedYear: Int { currentYear }

    // Dots for the viewed year
    // 25 cols × 15 rows = 365 dots per year
    func dotData(forYear year: Int) -> [DotDay] {
        let startDay   = (year - 1) * 365
        let cleanTotal = totalDaysSinceStart
        return (0..<365).map { i in
            let globalDay = startDay + i
            return DotDay(index: i, state: globalDay < cleanTotal ? .clean : .future)
        }
    }

    var longestStreak: Int {
        let fromStats = stats.map { $0.streak }.max() ?? 0
        return max(fromStats, totalDaysSinceStart)
    }

    var streakToBeat: Int {
        stats.map { $0.streak }.max() ?? 0
    }

    var lastRelapse: RelapseRecord? {
        relapses.sorted { $0.date > $1.date }.first
    }

    var milestoneMessage: String? {
        let current = totalDaysSinceStart

        // ── Year milestones (take priority) ──────────────────────
        switch current {
        case 365:
            return "One full year. 365 days. That's not a streak - that's a new identity. You did it."
        case 730:
            return "Two years. You've proven this isn't willpower, it's who you are now. Two years clean."
        case 1095:
            return "Three years. Most people never make it this far. You did, quietly, day by day."
        case 1460:
            return "Four years. Think about who you were when you started. Look at who you are now."
        case 1825:
            return "Five years. Half a decade. This is one of the most remarkable things a person can do for themselves."
        default:
            break
        }

        // ── Relapse-relative milestones ──────────────────────────
        guard let last = lastRelapse else { return nil }
        let daysPast = last.daysClean
        guard daysPast > 0 else { return nil }

        if current == daysPast {
            return "You just matched your last record of \(daysPast) day\(daysPast == 1 ? "" : "s"). Keep going - you're right at the edge."
        } else if current == daysPast + 1 {
            return "You just passed the point where you last relapsed (\(daysPast) day\(daysPast == 1 ? "" : "s")). This is new territory. You're stronger now."
        } else if current == daysPast * 2 {
            return "Double. \(current) days - twice as long as your last streak. You're a different person than the one who relapsed."
        } else if current == daysPast * 3 {
            return "Triple your last streak. \(current) days. Whatever you're doing, keep doing it."
        }

        return nil
    }

    func relapse() {
        // Log stat before resetting
        let record = StatRecord(endDate: Date(), streak: totalDaysSinceStart, habitName: habitName)
        stats.append(record)

        let rel = RelapseRecord(date: Date(), daysClean: totalDaysSinceStart)
        relapses.append(rel)
        startDate   = Date()
        viewingYear = 1
        save()
    }

    func addDayForTesting() {
        startDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate) ?? startDate
    }

    func addYearForTesting() {
        startDate = Calendar.current.date(byAdding: .day, value: -365, to: startDate) ?? startDate
    }

    func setStartDate(_ date: Date) {
        startDate = date
        // Reset viewing year in case date changes dramatically
        viewingYear = 1
        save()
    }

    func setup(habit: String) {
        habitName   = habit
        startDate   = Date()
        isSetup     = true
        viewingYear = 1
        relapses    = []
        save()
    }

    func resetEverything() {
        isSetup     = false
        habitName   = ""
        startDate   = Date()
        relapses    = []
        stats       = []
        viewingYear = 1
        save()
        NotificationCenter.default.post(name: .resetChat, object: nil)
    }

    func scheduleReminder() {
        cancelReminder()
        let content = UNMutableNotificationContent()
        content.title = "Hey 👋"
        content.body = "Remember to log your day!"
        content.sound = .default
        var comps = DateComponents()
        comps.hour   = reminderHour
        comps.minute = reminderMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }

    private func save() {
        defaults.set(habitName,              forKey: "habitName")
        defaults.set(startDate,              forKey: "startDate")
        defaults.set(isSetup,                forKey: "isSetup")
        defaults.set(currentTheme.rawValue,  forKey: "currentTheme")
        defaults.set(customBgHex,            forKey: "customBgHex")
        defaults.set(customAccentHex,        forKey: "customAccentHex")
        defaults.set(viewingYear,            forKey: "viewingYear")
        defaults.set(reminderEnabled,        forKey: "reminderEnabled")
        defaults.set(reminderHour,           forKey: "reminderHour")
        defaults.set(reminderMinute,         forKey: "reminderMinute")
        if let e = try? JSONEncoder().encode(relapses) { defaults.set(e, forKey: "relapses") }
        if let e = try? JSONEncoder().encode(stats)    { defaults.set(e, forKey: "stats") }
    }
}

struct DotDay: Identifiable {
    let id: Int; let index: Int; let state: DotState
    init(index: Int, state: DotState) { self.id = index; self.index = index; self.state = state }
}
enum DotState { case clean, future }

// Persistent chat session — lives as long as the app is open
class ChatSession: ObservableObject {
    @Published var messages: [ChatMessage] = []
    var hasGreeted = false
}

extension Notification.Name {
    static let resetChat = Notification.Name("resetChat")
}
