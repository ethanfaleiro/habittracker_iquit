import SwiftUI

struct SetupView: View {
    @EnvironmentObject var store: HabitStore
    @State private var habitText = ""
    @FocusState private var focused: Bool

    var t: ThemeColors { store.theme }

    var body: some View {
        ZStack {
            t.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("I Quit.")
                            .font(.custom("Georgia-BoldItalic", size: 52))
                            .foregroundColor(t.primary)
                        Text("It starts today.")
                            .font(.custom("Georgia-Italic", size: 20))
                            .foregroundColor(t.secondary)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What are you quitting?")
                            .font(.custom("Georgia", size: 15))
                            .foregroundColor(t.secondary)

                        // Shows user how their habit will read in the app
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("I haven't ")
                                .font(.custom("Georgia-Italic", size: 18))
                                .foregroundColor(t.secondary)
                                .padding(.bottom, 17)
                            TextField("", text: $habitText,
                                prompt: Text("eaten junk food…")
                                    .foregroundColor(t.secondary.opacity(0.4))
                                    .font(.custom("Georgia-Italic", size: 18)))
                                .font(.custom("Georgia", size: 18))
                                .foregroundColor(t.primary)
                                .focused($focused)
                                .autocorrectionDisabled()
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                #endif
                                .padding(.vertical, 16)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .fill(habitText.isEmpty ? t.border : t.accent)
                                        .frame(height: 1)
                                }
                        }
                    }
                    // Live preview
                    if !habitText.trimmingCharacters(in: .whitespaces).isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("This will show as:")
                                .font(.custom("Georgia", size: 11))
                                .foregroundColor(t.secondary.opacity(0.6))
                                .tracking(0.5)
                            Text("I haven't \(habitText.trimmingCharacters(in: .whitespaces)) for 0 days")
                                .font(.custom("Georgia-Italic", size: 15))
                                .foregroundColor(t.secondary)
                                .lineLimit(2)
                        }
                        .padding(.top, 4)
                        .transition(.opacity)
                    }

                    Button(action: {
                        let trimmed = habitText.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        store.setup(habit: trimmed)
                    }) {
                        HStack(spacing: 8) {
                            Text("Begin")
                                .font(.custom("Georgia", size: 18))
                                .foregroundColor(t.background)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(t.background)
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(t.primary)
                        .cornerRadius(4)
                    }
                    .opacity(habitText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
                    .disabled(habitText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 36)
                Spacer()
            }
        }
        .onAppear { focused = true }
    }
}
