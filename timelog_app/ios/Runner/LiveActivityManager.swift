import ActivityKit
import Flutter
import Foundation

// Shared attributes struct - must match the identical struct in TimeLogWidgetExtension
struct TimeLogAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endAt: Date
        var isPaused: Bool
        var pausedSecondsLeft: Int?
        var isCompleted: Bool
    }
    var totalSeconds: Int
}

@available(iOS 16.2, *)
class LiveActivityManager {
    private var currentActivity: Activity<TimeLogAttributes>?
    private weak var channel: FlutterMethodChannel?

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func startLiveActivity(endAt: Date, totalSeconds: Int) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }

        let attributes = TimeLogAttributes(totalSeconds: totalSeconds)
        let state = TimeLogAttributes.ContentState(
            endAt: endAt,
            isPaused: false,
            pausedSecondsLeft: nil,
            isCompleted: false
        )
        do {
            let staleDate = endAt.addingTimeInterval(60)
            currentActivity = try Activity<TimeLogAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: staleDate),
                pushType: nil
            )
            return true
        } catch {
            print("[LiveActivity] start failed: \(error)")
            return false
        }
    }

    func updateLiveActivity(action: String) {
        guard let activity = currentActivity else { return }
        Task {
            let current = activity.content.state
            let newState: TimeLogAttributes.ContentState
            switch action {
            case "pause":
                let remaining = max(0, Int(current.endAt.timeIntervalSinceNow))
                newState = TimeLogAttributes.ContentState(
                    endAt: current.endAt,
                    isPaused: true,
                    pausedSecondsLeft: remaining,
                    isCompleted: false
                )
            case "resume":
                // endAt is passed separately via updateLiveActivityWithEndAt
                return
            case "complete":
                newState = TimeLogAttributes.ContentState(
                    endAt: current.endAt,
                    isPaused: false,
                    pausedSecondsLeft: nil,
                    isCompleted: true
                )
            default:
                return
            }
            await activity.update(.init(state: newState, staleDate: nil))
        }
    }

    func updateLiveActivityResume(newEndAt: Date) {
        guard let activity = currentActivity else { return }
        Task {
            let newState = TimeLogAttributes.ContentState(
                endAt: newEndAt,
                isPaused: false,
                pausedSecondsLeft: nil,
                isCompleted: false
            )
            await activity.update(.init(state: newState, staleDate: newEndAt.addingTimeInterval(60)))
        }
    }

    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    func areActivitiesEnabled() -> Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func sendLockScreenAction(_ action: String) {
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onLockScreenAction", arguments: ["action": action])
        }
    }
}
