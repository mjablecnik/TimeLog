import ActivityKit
import AppIntents
import Foundation

// MARK: - Shared helpers

private func currentActivity() -> Activity<TimeLogAttributes>? {
    Activity<TimeLogAttributes>.activities.first
}

private func sharedDefaults() -> UserDefaults? {
    UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
}

// MARK: - Intents

struct PauseTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause Timer"
    static var openAppWhenRun: Bool { false }

    func perform() async throws -> some IntentResult {
        if let activity = currentActivity() {
            let current = activity.content.state
            let remaining = max(0, Int(current.endAt.timeIntervalSinceNow))
            let newState = TimeLogAttributes.ContentState(
                endAt: current.endAt,
                isPaused: true,
                pausedSecondsLeft: remaining,
                isCompleted: false
            )
            await activity.update(.init(state: newState, staleDate: nil))

            let defaults = sharedDefaults()
            defaults?.set(remaining, forKey: "pausedSecondsLeft")
            defaults?.set("pause", forKey: "pendingAction")
            defaults?.synchronize()
        }
        return .result()
    }
}

struct ResumeTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume Timer"
    static var openAppWhenRun: Bool { false }

    func perform() async throws -> some IntentResult {
        let defaults = sharedDefaults()
        let remaining = defaults?.integer(forKey: "pausedSecondsLeft") ?? 0

        if let activity = currentActivity(), remaining > 0 {
            let newEndAt = Date().addingTimeInterval(TimeInterval(remaining))
            let newState = TimeLogAttributes.ContentState(
                endAt: newEndAt,
                isPaused: false,
                pausedSecondsLeft: nil,
                isCompleted: false
            )
            await activity.update(.init(state: newState, staleDate: newEndAt.addingTimeInterval(60)))

            defaults?.set(newEndAt.timeIntervalSince1970, forKey: "resumedEndAt")
        }

        defaults?.set("resume", forKey: "pendingAction")
        defaults?.synchronize()
        return .result()
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    static var openAppWhenRun: Bool { false }

    func perform() async throws -> some IntentResult {
        if let activity = currentActivity() {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        let defaults = sharedDefaults()
        defaults?.set("stop", forKey: "pendingAction")
        defaults?.synchronize()
        return .result()
    }
}
