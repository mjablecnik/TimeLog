import ActivityKit
import AppIntents
import Foundation

// MARK: - Shared helper

private func currentActivity() -> Activity<TimeLogAttributes>? {
    Activity<TimeLogAttributes>.activities.first
}

private func savePendingAction(_ action: String) {
    let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
    defaults?.set(action, forKey: "pendingAction")
    defaults?.set(Date().timeIntervalSince1970, forKey: "pendingActionTimestamp")
    defaults?.synchronize()
}

// MARK: - Intents

struct PauseTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause Timer"
    static var description: IntentDescription = "Pauses the running timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // Update Live Activity immediately for responsive UI
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

            // Save remaining seconds so resume can calculate new endAt
            let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
            defaults?.set(remaining, forKey: "pausedSecondsLeft")
            defaults?.synchronize()
        }

        savePendingAction("pause")
        return .result()
    }
}

struct ResumeTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume Timer"
    static var description: IntentDescription = "Resumes the paused timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        if let activity = currentActivity() {
            let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
            let remaining = defaults?.integer(forKey: "pausedSecondsLeft") ?? 0

            if remaining > 0 {
                let newEndAt = Date().addingTimeInterval(TimeInterval(remaining))
                let newState = TimeLogAttributes.ContentState(
                    endAt: newEndAt,
                    isPaused: false,
                    pausedSecondsLeft: nil,
                    isCompleted: false
                )
                await activity.update(.init(state: newState, staleDate: newEndAt.addingTimeInterval(60)))

                // Save new endAt for the app to sync
                defaults?.set(newEndAt.timeIntervalSince1970, forKey: "resumedEndAt")
                defaults?.synchronize()
            }
        }

        savePendingAction("resume")
        return .result()
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    static var description: IntentDescription = "Stops the timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        // End the Live Activity immediately
        if let activity = currentActivity() {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        savePendingAction("stop")
        return .result()
    }
}
