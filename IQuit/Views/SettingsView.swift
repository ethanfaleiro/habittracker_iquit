import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showResetAlert = false
    @State private var showReason = false
    @State private var showDatePicker = false
    @State private var pickedDate: Date = Date()

    var t: ThemeColors { store.theme }

    var body: some View {
        ZStack {
            t.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Centered logo
                    Text("I Quit.")
                        .font(.custom("Georgia-BoldItalic", size: 32))
                        .foregroundColor(t.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 24)
                        .padding(.bottom, 28)

                    // ── Habit info ────────────────────────────
                    sectionLabel("Habit")

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 0) {
                            Text("I haven't ")
                                .font(.custom("Georgia-Italic", size: 18))
                                .foregroundColor(t.secondary)
                            Text(store.habitName)
                                .font(.custom("Georgia-Bold", size: 18))
                                .foregroundColor(t.primary)
                        }
                        HStack(spacing: 0) {
                            Text("since ")
                                .font(.custom("Georgia-Italic", size: 14))
                                .foregroundColor(t.secondary)
                            Text(store.startDate, style: .date)
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(t.secondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    // Set start date button
                    Button(action: {
                        pickedDate = store.startDate
                        showDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                                .foregroundColor(t.secondary)
                            Text("Set start date")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(t.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11))
                                .foregroundColor(t.border)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)
                    }

                    divider

                    // ── Theme ─────────────────────────────────
                    sectionLabel("Theme")

                    HStack(spacing: 12) {
                        themeButton(.dark, label: "Dark")
                        themeButton(.light, label: "Light")
                        themeButton(.custom, label: "Custom")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                    // Custom color pickers
                    if store.currentTheme == .custom {
                        VStack(spacing: 20) {
                            ColorPickerRow(
                                label: "Background",
                                hex: $store.customBgHex,
                                otherHex: store.customAccentHex,
                                theme: t
                            )
                            ColorPickerRow(
                                label: "Accent",
                                hex: $store.customAccentHex,
                                otherHex: store.customBgHex,
                                theme: t
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }

                    divider

                    // ── Notifications ─────────────────────────
                    sectionLabel("Reminders")

                    NotificationSection()
                        .environmentObject(store)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                    divider

                    // ── Reset ─────────────────────────────────
                    Button(action: { showResetAlert = true }) {
                        Text("Reset everything")
                            .font(.custom("Georgia", size: 15))
                            .foregroundColor(.red.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)

                    Text("Clears your habit, all streaks, and all history.")
                        .font(.custom("Georgia-Italic", size: 12))
                        .foregroundColor(t.secondary.opacity(0.6))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .padding(.bottom, 32)

                    // ── Footer ────────────────────────────────
                    Rectangle()
                        .fill(t.border)
                        .frame(height: 1)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)

                    VStack(alignment: .center, spacing: 12) {
                        Text("Created by Ethan")
                            .font(.custom("Georgia-Italic", size: 14))
                            .foregroundColor(t.secondary)

                        Button(action: { showReason = true }) {
                            Text("The Reason")
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(t.primary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(t.border, lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                selectedDate: $pickedDate,
                theme: t,
                onConfirm: {
                    store.setStartDate(pickedDate)
                    showDatePicker = false
                },
                onCancel: { showDatePicker = false }
            )
        }
        .alert("Reset everything?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { store.resetEverything() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently clears your habit, all streaks, and all history.")
        }
        .sheet(isPresented: $showReason) {
            ReasonView(theme: t)
        }
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle()
            .fill(t.border)
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.custom("Georgia", size: 10))
            .foregroundColor(t.secondary)
            .tracking(2)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
    }

    private func themeButton(_ theme: AppTheme, label: String) -> some View {
        let selected = store.currentTheme == theme
        return Button(action: { store.currentTheme = theme }) {
            Text(label)
                .font(selected ? .custom("Georgia-Bold", size: 14) : .custom("Georgia", size: 14))
                .foregroundColor(selected ? t.background : t.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? t.primary : Color.clear)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(t.border, lineWidth: 1))
        }
    }
}

// MARK: - Color Picker Row

struct ColorPickerRow: View {
    let label: String
    @Binding var hex: String
    let otherHex: String          // the other picker's hex — prevent matching
    let theme: ThemeColors
    @State private var showPicker = false

    var currentColor: Color { Color(hex: hex) }

    // Off-whites added, hot pinks removed, better spread
    let palette: [String] = [
        // Darks
        "0D0D0D", "1A1A1A", "2A2A2A", "1A0010", "0A1020", "0D1A0A",
        // Almost-whites + off-whites
        "FAFAF8", "F5F0EB", "F5F0F3", "EEF2F7", "FDF6E3", "EDE8E0",
        // Olive greens
        "6B7C3A", "4A5C2A",
        // Warm accents
        "E8453C", "FF6B1A", "D4A017", "C2547A", "F7A8C4", "8B4513",
        // Cool accents
        "1A4FD4", "4A90D9", "2ECC71", "1ABC9C", "8E44AD", "7B68EE",
        // Muted
        "A8C5DA", "C9AEA6", "9B8EA6", "6B8F71", "E8E0D0", "B5D5C5"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Label + current swatch inline
            HStack(spacing: 10) {
                Text(label)
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(theme.primary)
                Spacer()
                // Swatch tap to toggle picker
                HStack(spacing: 8) {
                    Text("#\(hex.uppercased())")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(theme.secondary)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(currentColor)
                        .frame(width: 32, height: 32)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(theme.border, lineWidth: 1))
                        .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { showPicker.toggle() } }
                }
            }

            if showPicker {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                    ForEach(palette, id: \.self) { colorHex in
                        let isSameAsOther = colorHex.uppercased() == otherHex.uppercased()
                            || (isNearWhite(colorHex) && isNearWhite(otherHex))
                            || (isNearBlack(colorHex) && isNearBlack(otherHex))
                        let isSelected = hex.uppercased() == colorHex.uppercased()

                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: colorHex))
                                .frame(height: 36)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? theme.primary : Color.clear, lineWidth: 2)
                                )
                            if isSameAsOther {
                                // Show an X to indicate this is blocked
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .opacity(isSameAsOther ? 0.35 : 1)
                        .onTapGesture {
                            guard !isSameAsOther else { return }
                            hex = colorHex
                            withAnimation { showPicker = false }
                        }
                    }
                }
                .padding(10)
                .background(theme.surface)
                .cornerRadius(10)
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
    }

    // Calculate perceived brightness 0.0 (black) to 1.0 (white)
    private func luminance(_ hex: String) -> Double {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 6 else { return 0.5 }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8)  & 0xFF) / 255.0
        let b = Double(rgb & 0xFF)          / 255.0
        // Perceived luminance formula
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    private func isNearWhite(_ hex: String) -> Bool { luminance(hex) > 0.75 }
    private func isNearBlack(_ hex: String) -> Bool { luminance(hex) < 0.12 }
}

// MARK: - Reason View

struct ReasonView: View {
    let theme: ThemeColors
    @Environment(\.dismiss) var dismiss

    private let reasonText = "I created this app on a random day where I was searching for a habit tracker and thinking about whether I should code it. I then thought about the bad habits that everyone has, including myself, and whether I could help in any way other than just speaking to them about it.\n\nI hope that my app can help at least one person change their life and if that happens, it will make me the happiest person in the world. Soon I will add a link for people to share their stories on whether this app helped them to overcome their bad habits.\n\nA special thank you to Claude AI that helped me with every step when coding this app. I made this app for the Apple Swift Student Challenge."

    var body: some View {
        ZStack {
            theme.background
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(theme.border)
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // Header
                HStack {
                    Text("The Reason")
                        .font(.custom("Georgia-BoldItalic", size: 24))
                        .foregroundColor(theme.primary)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.secondary)
                            .frame(width: 30, height: 30)
                            .background(theme.surface)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Scrollable body — fills all available space
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(reasonText)
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(theme.primary)
                            .lineSpacing(7)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\n— Ethan")
                            .font(.custom("Georgia-BoldItalic", size: 16))
                            .foregroundColor(theme.accent)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .background(theme.background)
            .cornerRadius(20)
            .padding(.horizontal, 0)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(theme.background)
        .presentationCornerRadius(20)
    }
}

// MARK: - Notification Section

struct NotificationSection: View {
    @EnvironmentObject var store: HabitStore
    var t: ThemeColors { store.theme }

    // Picker binding as Date for the time wheel
    var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: store.reminderHour,
                                      minute: store.reminderMinute, second: 0, of: Date()) ?? Date()
            },
            set: { newDate in
                store.reminderHour   = Calendar.current.component(.hour,   from: newDate)
                store.reminderMinute = Calendar.current.component(.minute, from: newDate)
            }
        )
    }

    var formattedTime: String {
        let h = store.reminderHour
        let m = store.reminderMinute
        let suffix = h >= 12 ? "PM" : "AM"
        let hour12 = h == 0 ? 12 : h > 12 ? h - 12 : h
        return String(format: "%d:%02d %@", hour12, m, suffix)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toggle row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily log reminder")
                        .font(.custom("Georgia", size: 15))
                        .foregroundColor(t.primary)
                    Text("Reminds you to open the app each day")
                        .font(.custom("Georgia-Italic", size: 12))
                        .foregroundColor(t.secondary)
                }
                Spacer()
                Toggle("", isOn: $store.reminderEnabled)
                    .tint(t.accent)
                    .labelsHidden()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(t.surface)
            .cornerRadius(store.reminderEnabled ? 10 : 10)

            // Time picker — slides in when enabled
            if store.reminderEnabled {
                VStack(spacing: 0) {
                    Divider().background(t.border)

                    HStack {
                        Text("Remind me at")
                            .font(.custom("Georgia", size: 14))
                            .foregroundColor(t.secondary)
                        Spacer()
                        DatePicker("", selection: reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(t.colorScheme)
                            .tint(t.accent)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(t.surface)

                    Divider().background(t.border)

                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 11))
                            .foregroundColor(t.accent)
                        Text("You'll get a notification every day at \(formattedTime)")
                            .font(.custom("Georgia-Italic", size: 12))
                            .foregroundColor(t.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(t.surface)
                }
                .cornerRadius(10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.reminderEnabled)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(t.border, lineWidth: 1))
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let theme: ThemeColors
    let onConfirm: () -> Void
    let onCancel: () -> Void

    @State private var displayMonth: Date = Date()
    @State private var showMonthYearPicker = false

    private let cal = Calendar.current

    var days: Int {
        max(0, cal.dateComponents([.day], from: selectedDate, to: Date()).day ?? 0)
    }

    var body: some View {
        theme.background.ignoresSafeArea()
            .overlay(
                VStack(spacing: 0) {
                    Capsule()
                        .fill(theme.border)
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 14)

                    ZStack {
                        Text("Start date")
                            .font(.custom("Georgia-BoldItalic", size: 20))
                            .foregroundColor(theme.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        HStack {
                            Button(action: onCancel) {
                                Text("Cancel")
                                    .font(.custom("Georgia", size: 16))
                                    .foregroundColor(theme.secondary)
                            }
                            Spacer()
                            Button(action: onConfirm) {
                                Text("Set")
                                    .font(.custom("Georgia-Bold", size: 16))
                                    .foregroundColor(theme.accent)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)

                    Text("Already been clean for a while? Pick your actual start date.")
                        .font(.custom("Georgia-Italic", size: 13))
                        .foregroundColor(theme.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)

                    CustomCalendar(
                        selectedDate: $selectedDate,
                        displayMonth: $displayMonth,
                        showMonthYearPicker: $showMonthYearPicker,
                        theme: theme
                    )
                    .padding(.horizontal, 16)

                    Text("That's \(days) day\(days == 1 ? "" : "s") clean.")
                        .font(.custom("Georgia-BoldItalic", size: 22))
                        .foregroundColor(theme.accent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(theme.background)
        .presentationCornerRadius(20)
        .onAppear {
            displayMonth = cal.startOfMonth(for: selectedDate)
        }
    }
}

// MARK: - Custom Calendar

struct CustomCalendar: View {
    @Binding var selectedDate: Date
    @Binding var displayMonth: Date
    @Binding var showMonthYearPicker: Bool
    let theme: ThemeColors

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let dayHeaders = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayMonth)
    }

    var daysInGrid: [Date?] {
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: displayMonth)),
              let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        let weekday = cal.component(.weekday, from: monthStart) - 1
        var grid: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let d = cal.date(byAdding: .day, value: day - 1, to: monthStart) {
                grid.append(d)
            }
        }
        while grid.count % 7 != 0 { grid.append(nil) }
        return grid
    }

    var canGoNext: Bool {
        let next = cal.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
        return cal.startOfMonth(for: next) <= cal.startOfMonth(for: Date())
    }

    var body: some View {
        VStack(spacing: 12) {
            // Month/year header — tap to open scroll picker
            HStack {
                Button(action: { withAnimation(.spring()) { showMonthYearPicker.toggle() } }) {
                    HStack(spacing: 6) {
                        Text(monthTitle)
                            .font(.custom("Georgia-Bold", size: 16))
                            .foregroundColor(theme.primary)
                        Image(systemName: showMonthYearPicker ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.accent)
                    }
                }
                Spacer()
                if !showMonthYearPicker {
                    HStack(spacing: 0) {
                        Button(action: prevMonth) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.accent)
                                .frame(width: 36, height: 36)
                        }
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(canGoNext ? theme.accent : theme.border)
                                .frame(width: 36, height: 36)
                        }
                        .disabled(!canGoNext)
                    }
                }
            }
            .padding(.horizontal, 4)

            if showMonthYearPicker {
                // Scroll wheel picker for month + year
                MonthYearPicker(displayMonth: $displayMonth, theme: theme)
                    .frame(height: 160)
                    .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            } else {
                // Day headers
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(dayHeaders, id: \.self) { h in
                        Text(h)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.secondary)
                            .frame(height: 28)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Day grid
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(Array(daysInGrid.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            let selected = cal.isDate(date, inSameDayAs: selectedDate)
                            let future = date > Date()
                            let today = cal.isDateInToday(date)

                            Button(action: { if !future { selectedDate = date } }) {
                                ZStack {
                                    if selected {
                                        Circle().fill(theme.accent).frame(width: 36, height: 36)
                                    } else if today {
                                        Circle().stroke(theme.accent, lineWidth: 1.5).frame(width: 36, height: 36)
                                    }
                                    Text("\(cal.component(.day, from: date))")
                                        .font(.custom(selected ? "Georgia-Bold" : "Georgia", size: 15))
                                        .foregroundColor(
                                            future ? theme.secondary.opacity(0.3) :
                                            selected ? theme.background :
                                            theme.primary
                                        )
                                }
                                .frame(height: 40).frame(maxWidth: .infinity)
                            }
                            .disabled(future)
                        } else {
                            Color.clear.frame(height: 40)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showMonthYearPicker)
    }

    func prevMonth() {
        displayMonth = cal.date(byAdding: .month, value: -1, to: displayMonth) ?? displayMonth
    }
    func nextMonth() {
        guard canGoNext else { return }
        displayMonth = cal.date(byAdding: .month, value: 1, to: displayMonth) ?? displayMonth
    }
}

// MARK: - Month Year Picker (scroll wheels)

struct MonthYearPicker: View {
    @Binding var displayMonth: Date
    let theme: ThemeColors

    private let cal = Calendar.current
    private let months = ["January","February","March","April","May","June",
                          "July","August","September","October","November","December"]

    // years from 1970 to current
    private var years: [Int] {
        let cur = cal.component(.year, from: Date())
        return Array(1970...cur)
    }

    @State private var selectedMonthIdx: Int = 0
    @State private var selectedYearIdx: Int = 0

    var body: some View {
        HStack(spacing: 0) {
            // Month wheel
            Picker("", selection: $selectedMonthIdx) {
                ForEach(0..<12, id: \.self) { i in
                    Text(months[i])
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(theme.primary)
                        .tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()

            // Year wheel
            Picker("", selection: $selectedYearIdx) {
                ForEach(0..<years.count, id: \.self) { i in
                    Text(String(years[i]))
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(theme.primary)
                        .tag(i)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .colorScheme(theme.colorScheme)
        .onAppear {
            let m = cal.component(.month, from: displayMonth) - 1
            let y = cal.component(.year, from: displayMonth)
            selectedMonthIdx = max(0, min(11, m))
            selectedYearIdx = years.firstIndex(of: y) ?? years.count - 1
        }
        .onChange(of: selectedMonthIdx) { updateDisplayMonth() }
        .onChange(of: selectedYearIdx) { updateDisplayMonth() }
    }

    func updateDisplayMonth() {
        let year = years[selectedYearIdx]
        let month = selectedMonthIdx + 1
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        if let d = cal.date(from: comps) {
            // Don't allow future months
            let now = cal.startOfMonth(for: Date())
            displayMonth = d > now ? now : d
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}
