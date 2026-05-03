import SwiftUI

enum ChatMode: String {
    case none, talk, distraction, vent
}

struct ChatView: View {
    @EnvironmentObject var store: HabitStore
    @EnvironmentObject var session: ChatSession
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var showSplash = false
    @State private var chatMode: ChatMode = .none
    @State private var sessionEnded = false
    @FocusState private var focused: Bool

    var t: ThemeColors { store.theme }

    private var bot: ChatBot {
        ChatBot(habit: store.habitName, days: store.daysSinceStart,
                relapses: store.relapses, longestStreak: store.longestStreak)
    }

    var promptText: String {
        if sessionEnded { return "Tap ↺ to start a new conversation" }
        switch chatMode {
        case .none:        return "Type: Someone to talk, Distraction, or Vent"
        case .talk:        return "Tell me what's on your mind…"
        case .distraction: return "Tell me something that happened today…"
        case .vent:        return "Let it out. I'm listening…"
        }
    }

    var body: some View {
        ZStack {
            t.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Check-in")
                        .font(.custom("Georgia-BoldItalic", size: 24))
                        .foregroundColor(t.primary)
                    Spacer()
                    Text("TRIAL")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(t.background)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(t.secondary)
                        .cornerRadius(4)

                    Button(action: { showSplash = true }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(t.secondary)
                    }
                    .padding(.leading, 6)

                    Button(action: resetConversation) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(t.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(t.border)

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            ForEach(session.messages) { msg in
                                MsgBubble(msg: msg, theme: t).id(msg.id)
                            }
                            if isTyping {
                                BotTyping(theme: t).id("typing")
                            }
                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .onAppear {
                        if !session.hasGreeted {
                            session.hasGreeted = true
                            session.messages.append(ChatMessage(text: bot.greeting(), isBot: true))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                session.messages.append(ChatMessage(
                                    text: "What do you need today? Type one of these:\n\n• Someone to talk\n• Distraction\n• Vent",
                                    isBot: true
                                ))
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                    .onChange(of: session.messages.count) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                        }
                    }
                    .onChange(of: isTyping) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                        }
                    }
                }

                Divider().background(t.border)

                // Input — disabled when session ended
                HStack(spacing: 10) {
                    TextField("", text: $inputText,
                        prompt: Text(promptText)
                            .foregroundColor(t.secondary.opacity(0.5))
                            .font(.custom("Georgia-Italic", size: 14)))
                        .font(.custom("Georgia", size: 15))
                        .foregroundColor(sessionEnded ? t.secondary : t.primary)
                        .focused($focused)
                        .disabled(sessionEnded)
                        .onSubmit { if !sessionEnded { send() } }

                    Button(action: { if !sessionEnded { send() } }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(t.background)
                            .frame(width: 30, height: 30)
                            .background(inputText.isEmpty || sessionEnded ? t.border : t.accent)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty || sessionEnded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            if showSplash {
                SplashOverlay(theme: t, onDismiss: { showSplash = false })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showSplash)
        .onReceive(NotificationCenter.default.publisher(for: .resetChat)) { _ in
            session.messages = []
            session.hasGreeted = false
            chatMode = .none
            sessionEnded = false
        }
    }

    private func resetConversation() {
        session.messages = []
        session.hasGreeted = false
        chatMode = .none
        sessionEnded = false
        inputText = ""
        session.hasGreeted = true
        session.messages.append(ChatMessage(text: bot.greeting(), isBot: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            session.messages.append(ChatMessage(
                text: "What do you need today? Type one of these:\n\n• Someone to talk\n• Distraction\n• Vent",
                isBot: true
            ))
        }
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !sessionEnded else { return }
        inputText = ""
        session.messages.append(ChatMessage(text: text, isBot: false))

        // Detect mode on first message
        if chatMode == .none {
            let lower = text.lowercased()
            if lower.contains("talk") || lower.contains("someone") || lower.contains("listen") {
                chatMode = .talk
            } else if lower.contains("distract") || lower.contains("funny") || lower.contains("bored") {
                chatMode = .distraction
            } else if lower.contains("vent") || lower.contains("angry") || lower.contains("frustrated") {
                chatMode = .vent
            }
        }

        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.8...1.6)) {
            isTyping = false
            let reply = generateReply(for: text)
            session.messages.append(ChatMessage(text: reply, isBot: true))

            // If the reply is a closing message, end session and show splash
            let closingMessages = [
                "Thank you for talking to me :)",
                "I hope I made you feel a bit better today :)",
                "I hope that you feel a bit better. Thank you for telling me about your feelings :)"
            ]
            if closingMessages.contains(reply) {
                sessionEnded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showSplash = true
                }
            }
        }
    }

    private func generateReply(for text: String) -> String {
        let lower = text.lowercased()
        let userMsgCount = session.messages.filter { !$0.isBot }.count

        if userMsgCount == 1 {
            if lower.contains("talk") || lower.contains("someone") || lower.contains("listen") {
                chatMode = .talk
                return "I'm here. You don't have to figure out what to say - just say whatever comes to mind. I'm listening, and nothing you share here is too small or too much."
            } else if lower.contains("distract") || lower.contains("distraction") {
                chatMode = .distraction
                return "Let's take your mind somewhere else for a bit. Tell me - what's the weirdest or funniest thing that's happened to you recently? Even something small counts."
            } else if lower.contains("vent") {
                chatMode = .vent
                return "Go ahead. Say it all. Don't filter yourself - whatever's building up, let it out here. I'm not going anywhere."
            } else {
                return "I hear you. Want to talk about it, get distracted, or just vent? There's no wrong answer."
            }
        }

        switch chatMode {
        case .talk:        return "Thank you for talking to me :)"
        case .distraction: return "I hope I made you feel a bit better today :)"
        case .vent:        return "I hope that you feel a bit better. Thank you for telling me about your feelings :)"
        case .none:        return "I hear you. Want to talk about it, get distracted, or just vent?"
        }
    }
}

// MARK: - Splash
struct SplashOverlay: View {
    let theme: ThemeColors
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(theme.accent)

                Text("Check-in")
                    .font(.custom("Georgia-BoldItalic", size: 26))
                    .foregroundColor(theme.primary)

                Text("available shortly")
                    .font(.custom("Georgia-Italic", size: 16))
                    .foregroundColor(theme.secondary)

                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                Text("A fully conversational AI check-in requires a large language model, which needs a network connection and falls outside the guidelines for the Apple Swift Student Challenge.\n\nFor now, the trial mode is available — choose to talk, get distracted, or vent, and I'll be here.")
                    .font(.custom("Georgia", size: 14))
                    .foregroundColor(theme.primary)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Button(action: onDismiss) {
                    Text("Got it")
                        .font(.custom("Georgia", size: 15))
                        .foregroundColor(theme.background)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(theme.primary)
                        .cornerRadius(8)
                }
            }
            .padding(28)
            .background(theme.background)
            .cornerRadius(20)
            .padding(.horizontal, 32)
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }
}

// MARK: - Bubbles
struct MsgBubble: View {
    let msg: ChatMessage
    let theme: ThemeColors
    var body: some View {
        HStack(alignment: .top) {
            if !msg.isBot { Spacer(minLength: 40) }
            Text(msg.text)
                .font(.custom("Georgia", size: 15))
                .foregroundColor(msg.isBot ? theme.primary : theme.background)
                .padding(.horizontal, 14)
                .padding(.vertical, msg.isBot ? 2 : 10)
                .background(msg.isBot ? Color.clear : theme.accent)
                .cornerRadius(14)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            if msg.isBot { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: msg.isBot ? .leading : .trailing)
    }
}

struct BotTyping: View {
    let theme: ThemeColors
    @State private var phase = 0
    let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(theme.secondary)
                    .frame(width: 5, height: 5)
                    .scaleEffect(phase == i ? 1.4 : 0.9)
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }
        }
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}
