import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var liveActivityManager: AnyObject?
    private var methodChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        setupLiveActivityChannel()
        setupNotificationChannel()
        observeWidgetActions()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Notifications

    private func setupNotificationChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        let channel = FlutterMethodChannel(
            name: "com.jablecnik.timelog/notifications",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "requestPermission":
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { granted, _ in
                    DispatchQueue.main.async { result(granted) }
                }

            case "scheduleNotification":
                guard let args = call.arguments as? [String: Any],
                      let endAtMs = args["endAtMs"] as? Int64 else {
                    result(nil)
                    return
                }
                let endAt = Date(timeIntervalSince1970: Double(endAtMs) / 1000.0)
                self.scheduleTimerNotification(at: endAt)
                result(nil)

            case "cancelNotification":
                UNUserNotificationCenter.current().removePendingNotificationRequests(
                    withIdentifiers: ["timelog_timer_alarm"]
                )
                UNUserNotificationCenter.current().removeDeliveredNotifications(
                    withIdentifiers: ["timelog_timer_alarm"]
                )
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func scheduleTimerNotification(at date: Date) {
        let center = UNUserNotificationCenter.current()

        // Remove any existing scheduled notification
        center.removePendingNotificationRequests(withIdentifiers: ["timelog_timer_alarm"])

        let content = UNMutableNotificationContent()
        content.title = "TimeLog"
        content.body = "Timer complete!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm.mp3"))
        content.interruptionLevel = .timeSensitive

        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "timelog_timer_alarm",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("[Notification] Failed to schedule: \(error)")
            }
        }
    }

    private func setupLiveActivityChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }

        let channel = FlutterMethodChannel(
            name: "com.jablecnik.timelog/live_activity",
            binaryMessenger: controller.binaryMessenger
        )
        self.methodChannel = channel

        if #available(iOS 16.2, *) {
            let manager = LiveActivityManager(channel: channel)
            self.liveActivityManager = manager

            channel.setMethodCallHandler { [weak manager] call, result in
                guard let manager = manager else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                switch call.method {
                case "startLiveActivity":
                    guard let args = call.arguments as? [String: Any] else {
                        result(false)
                        return
                    }
                    let endAtMs = (args["endAt"] as? NSNumber)?.int64Value ?? 0
                    let endAt = Date(timeIntervalSince1970: Double(endAtMs) / 1000.0)
                    let totalSeconds = (args["totalSeconds"] as? Int) ?? 1200
                    result(manager.startLiveActivity(endAt: endAt, totalSeconds: totalSeconds))

                case "updateLiveActivity":
                    if let args = call.arguments as? [String: Any],
                       let action = args["action"] as? String {
                        manager.updateLiveActivity(action: action)
                    }
                    result(nil)

                case "endLiveActivity":
                    manager.endLiveActivity()
                    result(nil)

                case "areActivitiesEnabled":
                    result(manager.areActivitiesEnabled())

                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        } else {
            channel.setMethodCallHandler { call, result in
                if call.method == "areActivitiesEnabled" {
                    result(false)
                } else {
                    result(nil)
                }
            }
        }
    }

    // Receive URLs from Widget Extension lock-screen controls (e.g. timelogapp://action/pause)
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        guard url.scheme == "timelogapp", url.host == "action" else {
            return super.application(app, open: url, options: options)
        }
        let action = String(url.path.dropFirst()) // strip leading "/"
        guard !action.isEmpty else { return true }
        methodChannel?.invokeMethod("onLockScreenAction", arguments: ["action": action])
        return true
    }

    // MARK: - Widget Intent Actions (App Group + Darwin Notification)

    private func observeWidgetActions() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            center,
            observer,
            { _, observer, _, _, _ in
                guard let observer = observer else { return }
                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    appDelegate.handlePendingWidgetAction()
                }
            },
            "com.jablecnik.timelog.action" as CFString,
            nil,
            .deliverImmediately
        )
        // Also check on app resume in case notification was missed
        handlePendingWidgetAction()
    }

    func handlePendingWidgetAction() {
        guard let defaults = UserDefaults(suiteName: "group.com.jablecnik.timelogApp"),
              let action = defaults.string(forKey: "pendingAction"),
              !action.isEmpty else { return }
        // Clear the pending action
        defaults.removeObject(forKey: "pendingAction")
        defaults.synchronize()
        // Forward to Flutter
        methodChannel?.invokeMethod("onLockScreenAction", arguments: ["action": action])
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        handlePendingWidgetAction()
    }
}
