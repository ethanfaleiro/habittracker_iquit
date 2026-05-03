import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showRelapseAlert = false

    var t: ThemeColors { store.theme }

    var daysText: String {
        let d = store.daysSinceStart
        return d == 1 ? "1 day" : "\(d) days"
    }

    var yearRangeText: String {
        let start = (store.viewingYear - 1) * 364 + 1
        let end   = store.viewingYear * 365
        return "days \(start)–\(end)"
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                t.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    statementSection
                    if store.milestoneMessage != nil { milestoneSection }
                    yearNavSection
                    legendSection
                    dotSection(totalHeight: geo.size.height)
                    Spacer(minLength: 0)
                    if store.streakToBeat > 0 { streakToBeatSection }
                    relapseButton
                }
            }
        }
        .alert("Log a relapse?", isPresented: $showRelapseAlert) {
            Button("Yes, reset", role: .destructive) { store.relapse() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your streak (\(store.daysSinceStart) days) will be saved to Stats. This isn't failure — it's data.")
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            Text("I Quit.")
                .font(.custom("Georgia-BoldItalic", size: 26))
                .foregroundColor(t.primary)
            Spacer()

        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var statementSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("I haven't")
                .font(.custom("Georgia-Italic", size: 16))
                .foregroundColor(t.secondary)
            Text(store.habitName)
                .font(.custom("Georgia-Bold", size: 32))
                .foregroundColor(t.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("for ")
                    .font(.custom("Georgia-Italic", size: 16))
                    .foregroundColor(t.secondary)
                Text(daysText)
                    .font(.custom("Georgia-BoldItalic", size: 32))
                    .foregroundColor(t.accent)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private var milestoneSection: some View {
        Group {
            if let msg = store.milestoneMessage {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10))
                        .foregroundColor(t.accent)
                    Text(msg)
                        .font(.custom("Georgia-Italic", size: 12))
                        .foregroundColor(t.accent)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(t.surface)
                .cornerRadius(6)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            }
        }
    }

    private var yearNavSection: some View {
        HStack {
            Button(action: {
                if store.viewingYear > 1 { store.viewingYear -= 1 }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(store.viewingYear > 1 ? t.primary : t.border)
                    .frame(width: 36, height: 28)
            }
            .disabled(store.viewingYear <= 1)

            Spacer()

            VStack(spacing: 1) {
                Text("Year \(store.viewingYear)")
                    .font(.custom("Georgia-Bold", size: 13))
                    .foregroundColor(t.primary)
                Text(yearRangeText)
                    .font(.custom("Georgia", size: 10))
                    .foregroundColor(t.secondary)
            }

            Spacer()

            let canForward = store.viewingYear < store.maxUnlockedYear
            Button(action: {
                if canForward { store.viewingYear += 1 }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(canForward ? t.primary : t.border)
                    .frame(width: 36, height: 28)
            }
            .disabled(!canForward)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    private var legendSection: some View {
        HStack {
            HStack(spacing: 4) {
                Circle().fill(t.dotClean).frame(width: 5, height: 5)
                Text("clean")
                    .font(.custom("Georgia", size: 10))
                    .foregroundColor(t.secondary)
            }
            Text("·").foregroundColor(t.border).padding(.horizontal, 3)
            HStack(spacing: 4) {
                Circle().fill(t.dotFuture.opacity(0.7)).frame(width: 5, height: 5)
                Text("ahead")
                    .font(.custom("Georgia", size: 10))
                    .foregroundColor(t.secondary)
            }
            Spacer()
            Text("365 days")
                .font(.custom("Georgia", size: 10))
                .foregroundColor(t.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
    }

    private func dotSection(totalHeight: CGFloat) -> some View {
        // Fixed heights of everything else so dots fill the rest
        let fixedH: CGFloat = 16 + 40 + 14  // top + header + pad
            + 16 + 32 + 32 + 8              // statement
            + 36 + 20                        // year nav + legend
            + (store.streakToBeat > 0 ? 30 : 0)
            + 50 + 16                        // relapse btn + bottom pad
            + 83                             // tab bar approx
        let dotH = max(150, totalHeight - fixedH)

        return DotGridView(
            dots: store.dotData(forYear: store.viewingYear),
            theme: t,
            availableHeight: dotH
        )
        .frame(height: dotH)
    }

    private var streakToBeatSection: some View {
        HStack(spacing: 6) {
            Image(systemName: "trophy")
                .font(.system(size: 11))
                .foregroundColor(t.secondary)
            Text("Streak to beat: \(store.streakToBeat) day\(store.streakToBeat == 1 ? "" : "s")")
                .font(.custom("Georgia-Italic", size: 13))
                .foregroundColor(t.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private var relapseButton: some View {
        Button(action: { showRelapseAlert = true }) {
            Text("I relapsed")
                .font(.custom("Georgia", size: 15))
                .foregroundColor(t.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(t.border, lineWidth: 1))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
