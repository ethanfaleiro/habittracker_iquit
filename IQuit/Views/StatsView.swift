import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: HabitStore
    var t: ThemeColors { store.theme }

    var body: some View {
        ZStack {
            t.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    Text("Stats")
                        .font(.custom("Georgia-BoldItalic", size: 32))
                        .foregroundColor(t.primary)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 28)

                    // Current streak card
                    statCard(label: "Current streak", value: "\(store.daysSinceStart)", unit: "days")

                    // Longest streak card
                    statCard(label: "Longest streak", value: "\(store.longestStreak)", unit: "days")

                    // Total attempts
                    statCard(label: "Attempts", value: "\(store.relapses.count + 1)", unit: "total")

                    // Streak to beat
                    if store.streakToBeat > 0 {
                        HStack(spacing: 10) {
                            Image(systemName: "trophy")
                                .font(.system(size: 14))
                                .foregroundColor(t.accent)
                            Text("Streak to beat: \(store.streakToBeat) day\(store.streakToBeat == 1 ? "" : "s")")
                                .font(.custom("Georgia-BoldItalic", size: 16))
                                .foregroundColor(t.accent)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(t.surface)
                        .padding(.horizontal, 24)
                        .cornerRadius(8)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 24)
                    }

                    // Past streaks
                    if !store.stats.isEmpty {
                        Text("Past streaks")
                            .font(.custom("Georgia", size: 12))
                            .foregroundColor(t.secondary)
                            .tracking(1.5)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 12)

                        ForEach(store.stats.sorted { $0.endDate > $1.endDate }) { s in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(s.streak) day\(s.streak == 1 ? "" : "s")")
                                        .font(.custom("Georgia-Bold", size: 18))
                                        .foregroundColor(t.primary)
                                    Text("ended \(s.endDate, style: .date)")
                                        .font(.custom("Georgia-Italic", size: 12))
                                        .foregroundColor(t.secondary)
                                }
                                Spacer()
                                // Medal for longest
                                if s.streak == store.stats.map({ $0.streak }).max() {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(t.accent)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)

                            Divider().background(t.border).padding(.horizontal, 24)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text("No streaks recorded yet.")
                                .font(.custom("Georgia-Italic", size: 16))
                                .foregroundColor(t.secondary)
                            Text("Stats will appear here only if you reset.")
                                .font(.custom("Georgia", size: 13))
                                .foregroundColor(t.secondary.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }

    @ViewBuilder
    private func statCard(label: String, value: String, unit: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Georgia", size: 12))
                    .foregroundColor(t.secondary)
                    .tracking(0.8)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.custom("Georgia-Bold", size: 42))
                        .foregroundColor(t.primary)
                    Text(unit)
                        .font(.custom("Georgia-Italic", size: 16))
                        .foregroundColor(t.secondary)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)

        Divider().background(t.border).padding(.horizontal, 24)
    }
}
