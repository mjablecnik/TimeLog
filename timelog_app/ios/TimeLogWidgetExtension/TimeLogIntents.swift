import AppIntents
import Foundation

struct PauseTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause Timer"
    static var description: IntentDescription = "Pauses the running timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
        defaults?.set("pause", forKey: "pendingAction")
        defaults?.set(Date().timeIntervalSince1970, forKey: "pendingActionTimestamp")
        defaults?.synchronize()

        // Post Darwin notification to wake the app process
        let name = "com.jablecnik.timelog.action" as CFString
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(name),
            nil, nil, true
        )
        return .result()
    }
}

struct ResumeTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Resume Timer"
    static var description: IntentDescription = "Resumes the paused timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
        defaults?.set("resume", forKey: "pendingAction")
        defaults?.set(Date().timeIntervalSince1970, forKey: "pendingActionTimestamp")
        defaults?.synchronize()

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.jablecnik.timelog.action" as CFString),
            nil, nil, true
        )
        return .result()
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    static var description: IntentDescription = "Stops the timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp")
        defaults?.set("stop", forKey: "pendingAction")
        defaults?.set(Date().timeIntervalSince1970, forKey: "pendingActionTimestamp")
        defaults?.synchronize()

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.jablecnik.timelog.action" as CFString),
            nil, nil, true
        )
        return .result()
    }
}
