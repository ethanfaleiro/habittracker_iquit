import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isBot: Bool
}

class ChatBot {
    private let habit: String
    private let days: Int
    private let relapses: [RelapseRecord]
    private let longestStreak: Int

    init(habit: String, days: Int, relapses: [RelapseRecord], longestStreak: Int) {
        self.habit = habit
        self.days = days
        self.relapses = relapses
        self.longestStreak = longestStreak
    }

    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())

        // Day one gets the same message regardless of time
        if days == 0 {
            let timeGreet: String
            switch hour {
            case 5..<12:  timeGreet = "Good morning!"
            case 12..<17: timeGreet = "Good afternoon!"
            case 17..<21: timeGreet = "Good evening!"
            default:      timeGreet = "Hey, up late?"
            }
            return "\(timeGreet) Day one, the most important day. Let's talk, I'm here."
        }

        let d = days == 1 ? "1 day" : "\(days) days"
        switch hour {
        case 5..<12:
            return "Good morning! \(d) without having \(habit)."
        case 12..<17:
            return "Good afternoon! \(d) without having \(habit)."
        case 17..<21:
            return "Good evening! \(d) without having \(habit)."
        default:
            return "Hey, up late? \(d) without having \(habit)."
        }
    }

    func respond(to input: String) -> String {
        let q = input.lowercased()

        if has(q, ["hello","hi","hey","sup","what's up","whats up"]) { return greeting() }
        if has(q, ["nothing","idk","i don't know","dunno","not sure","no reason","just","blank","empty","numb","don't know"]) { return nothingness() }
        if has(q, ["craving","urge","tempt","want to","gonna do it","about to"]) { return craving() }
        if has(q, ["relapsed","slipped","gave in","failed","did it again","i caved"]) { return relapsed() }
        if has(q, ["why bother","what's the point","whats the point","pointless","doesn't matter","dont care"]) { return whyBother() }
        if has(q, ["hard","difficult","struggling","tough","can't do this","cant do this","impossible"]) { return hardDay() }
        if has(q, ["proud","did it","made it","milestone","feeling good","great day","amazing"]) { return celebrate() }
        if has(q, ["tip","advice","trick","strategy","how do i","what should i","help me stop"]) { return tip() }
        if has(q, ["lonely","alone","no one","nobody","isolated","by myself"]) { return lonely() }
        if has(q, ["bored","boredom","nothing to do","so bored","killing time"]) { return bored() }
        if has(q, ["stress","stressed","anxious","anxiety","overwhelmed","panic","pressure"]) { return stress() }
        if has(q, ["sleep","tired","exhausted","can't sleep","insomnia","restless"]) { return sleep() }
        if has(q, ["angry","mad","furious","pissed","frustrated","rage"]) { return angry() }
        if has(q, ["sad","depressed","down","low","empty","hopeless","worthless"]) { return sad() }
        if has(q, ["proud of me","doing well","how am i doing","how's my progress"]) { return progress() }
        if has(q, ["thank","thanks","appreciate","you're great","you're helpful"]) { return thanks() }
        if has(q, ["how long","how many days","my streak","days clean"]) { return streakInfo() }
        if has(q, ["best streak","longest","record","personal best"]) { return bestStreak() }
        if has(q, ["withdraw","withdrawal","symptoms","sweating","shaking","sick"]) { return withdrawal() }
        if has(q, ["trigger","what triggers","avoid","situations"]) { return triggers() }
        if has(q, ["money","cash","savings","cost","spent"]) { return money() }
        if has(q, ["family","friend","people","tell someone","support"]) { return support() }

        return generic()
    }

    private func has(_ text: String, _ words: [String]) -> Bool {
        words.contains(where: { text.contains($0) })
    }

    private func craving() -> String {
        let r = [
            "Ride it out. Cravings peak around 15–20 minutes then drop. Don't white-knuckle it - move your body. Walk to another room. Drink a glass of cold water. The urge will pass.",
            "You've had \(days) days of practice saying no. This craving is just one more moment. Name it out loud: 'I'm having a craving.' Then let it pass like a cloud.",
            "Your brain is asking for \(habit) because that's what it's done before. But you've been rewriting that pattern for \(days) day\(days == 1 ? "" : "s"). Don't let one moment erase that.",
            "Try the 5-4-3-2-1 method right now: name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste. It sounds weird but it works - pulls you out of your head.",
            "Cravings feel permanent but they're not. They're a wave. You don't have to stop the wave, just don't get on it. Wait 20 minutes. Do something with your hands.",
        ]
        return r.randomElement()!
    }

    private func relapsed() -> String {
        if relapses.count == 0 {
            return "That's really hard to say, and it matters that you're saying it. You're not back at zero - you're back with more information than before. What happened? And what do you want to do right now?"
        }
        let best = relapses.map { $0.daysClean }.max() ?? days
        return "You've done \(best) days before. That's still real - it happened, it counts. Relapse is part of recovery for a lot of people. The question isn't whether you fell, it's what you do next. Reset the counter if you want. Or just talk to me first."
    }

    private func whyBother() -> String {
        let r = [
            "That question usually shows up when you're tired or struggling, not when you're thinking clearly. What made you start in the first place? That reason is still there.",
            "The point is the person you're becoming every day you don't \(habit). It doesn't always feel meaningful in the moment. But \(days) days of small choices add up to something real.",
            "If it didn't matter, you wouldn't be fighting this hard. The fact that you're asking means part of you still cares. That part is right.",
        ]
        return r.randomElement()!
    }

    private func hardDay() -> String {
        let r = [
            "Hard days are where the real work happens. Not the easy ones. You've survived every hard day so far - \(days) of them. This one is just next in line.",
            "You don't need to feel strong right now. You just need to not act on it. That's all. Hold on for the next hour. Then the next.",
            "Tell me what's making it hard today. Sometimes saying it out loud takes some of the weight off.",
        ]
        return r.randomElement()!
    }

    private func celebrate() -> String {
        let r = [
            "\(days) day\(days == 1 ? "" : "s"). Earned, not given. Take a real moment to feel that - you don't do it enough.",
            "That's not small. A lot of people never make it this far. You did.",
            "Yes. This is what it looks like. Keep stacking.",
        ]
        return r.randomElement()!
    }

    private func tip() -> String {
        let tips = [
            "The most effective tool: delay. Don't say 'I'll never do this again.' Say 'I'll wait 20 minutes.' Almost every craving dies in that window.",
            "Identify your top 3 triggers - the specific times, places, or emotions that make you most likely to slip. Then make a plan for each one before you're in the moment.",
            "Replace the ritual, not just the habit. If \(habit) was tied to a specific time or feeling, build a new ritual for exactly those moments.",
            "Tell one person. One. Accountability doesn't require a group - just one person who knows changes everything.",
            "When you feel an urge, write it down instead of acting on it. Just: what time, where you were, what triggered it. You'll start to see patterns.",
            "The urge to have \(habit) is a thought, not a command. You can watch it without obeying it.",
        ]
        return tips.randomElement()!
    }

    private func lonely() -> String {
        return "Loneliness is one of the most powerful relapse triggers - it makes everything harder. Is there one person you've been putting off reaching out to? Text them right now. Not because it'll fix everything, just because connection helps."
    }

    private func bored() -> String {
        return "Boredom is dangerous because it feels like nothing, but it's actually a hunger for stimulation — and \(habit) used to fill that. You need something that genuinely engages you. Physical works best: cook something, build something, go somewhere. Passive stuff (scrolling, TV) usually makes it worse."
    }

    private func stress() -> String {
        return "Stress is the number one reason people go back. Before anything else: slow exhale. Longer out than in — 4 counts in, 6 counts out. Do it 4 times. It literally slows your heart rate. Then tell me what's going on - the specific thing, not just 'everything.'"
    }

    private func sleep() -> String {
        return "Sleep disruption is extremely common in early recovery. Your brain chemistry is actually recalibrating. A few things that genuinely help: consistent sleep/wake time even on weekends, no screens 30 minutes before bed, and keeping your room cold. It gets better - usually within a few weeks."
    }

    private func angry() -> String {
        return "Anger is high-risk because it bypasses your rational brain. Don't make any decisions right now, including about \(habit). Move your body - fast walk, cold water on your face, something physical. Once the physiological response calms down (usually 20–30 minutes), the decision will be easier."
    }

    private func sad() -> String {
        return "I hear you. That kind of low feeling is real and it's hard. You don't have to fix it right now. Is there one small thing - genuinely small, like going outside for 5 minutes, or eating something - that might make the next hour slightly less heavy?"
    }

    private func progress() -> String {
        if days == 0 { return "Day zero. The first step is deciding. You've done that. Tomorrow starts the count." }
        if days < 7 { return "\(days) day\(days == 1 ? "" : "s"). That's real. The first week is statistically the hardest. You're in it." }
        if days < 30 { return "\(days) days. The acute withdrawal phase is mostly behind you. Your brain is starting to heal." }
        if days < 90 { return "\(days) days. You're building new patterns now. The neural pathways for \(habit) are starting to weaken." }
        return "\(days) days. That's not a streak anymore - that's a new identity. You're someone who doesn't \(habit)."
    }

    private func thanks() -> String {
        return "You're doing the actual work. I'm just here. Keep going."
    }

    private func streakInfo() -> String {
        let d = days == 1 ? "1 day" : "\(days) days"
        return "You're at \(d) without having \(habit). \(days >= longestStreak && longestStreak > 0 ? "That ties your personal best." : longestStreak > 0 ? "Your longest streak is \(longestStreak) days — you're \(longestStreak - days) away from beating it." : "Keep going.")"
    }

    private func bestStreak() -> String {
        if longestStreak == 0 { return "This is your first run. Make it count." }
        return "Your longest streak so far is \(longestStreak) day\(longestStreak == 1 ? "" : "s"). You're currently at \(days). \(days >= longestStreak ? "You're at your record right now. This is the moment." : "\(longestStreak - days) more days to beat it.")"
    }

    private func withdrawal() -> String {
        return "Withdrawal symptoms are real and they vary a lot by what you're quitting. The general timeline: acute symptoms usually peak in the first 72 hours and ease significantly within 2 weeks. What you're feeling right now is temporary - it's your body recalibrating. If symptoms feel severe or medical, please see a doctor. What are you experiencing?"
    }

    private func triggers() -> String {
        return "Knowing your triggers is half the battle. Common ones: stress, boredom, social situations where \(habit) was normal, specific times of day, certain places, or emotional states like loneliness or anger. Which of those feels most dangerous for you?"
    }

    private func money() -> String {
        let saved = days * 10 // rough estimate
        return "Depending on what you were spending, you might have saved somewhere in the range of $\(saved)+ over \(days) days. That's real money that stayed in your pocket instead of going toward \(habit). What would you want to do with it?"
    }

    private func support() -> String {
        return "Having even one person who knows what you're doing changes the odds significantly. You don't need a support group - just one person. Have you told anyone you're quitting \(habit)?"
    }

    private func nothingness() -> String {
        let r = [
            "That's okay. Feeling nothing is still feeling something. Numbness is usually the mind protecting itself from too much at once. You don't have to dig into it right now - just being here is enough.",
            "Nothing is a valid answer. Sometimes there's no specific thing, just a low hum of something being off. That's real. You don't have to name it to acknowledge it.",
            "Emptiness is one of the harder things to sit with, because there's nothing to push against. But you opened this app, which means something in you reached out. That matters, even if you don't know why.",
            "Feeling blank is more common in recovery than people talk about. Your brain is recalibrating - sometimes it goes quiet in a way that feels like nothing. It usually passes. How long have you been feeling this way?",
        ]
        return r.randomElement()!
    }

    private func generic() -> String {
        let r = [
            "Tell me more. What's going on today specifically?",
            "I'm listening. What's on your mind?",
            "\(days) day\(days == 1 ? "" : "s") in. What does today feel like?",
            "What do you need right now - someone to talk through something, a distraction, or just to vent?",
            "What triggered you to open this? Something happen, or just checking in?",
        ]
        return r.randomElement()!
    }
}
