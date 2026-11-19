import Flutter
import UIKit
import UserNotifications

/// Scene delegate named in Info.plist; Flutter's base class does the work.
class SceneDelegate: FlutterSceneDelegate {}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    private var liveActivityManager: AnyObject?
    private var methodChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Ensure this AppDelegate receives notification delegate callbacks
        // (willPresent for foreground display, didReceive for tap handling).
        UNUserNotificationCenter.current().delegate = self

        observeWidgetActions()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Flutter engine (UIScene lifecycle)

    /// With the UIScene lifecycle there is no window yet in
    /// `didFinishLaunchingWithOptions`, so plugins and platform channels are set
    /// up here, once the implicit Flutter engine exists.
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let messenger = engineBridge.applicationRegistrar.messenger()
        setupLiveActivityChannel(messenger: messenger)
        setupNotificationChannel(messenger: messenger)
        handlePendingWidgetAction()
    }

    // MARK: - Notifications

    private func setupNotificationChannel(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.jablecnik.timelog/notifications",
            binaryMessenger: messenger
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
        content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm.caf"))
        content.interruptionLevel = .timeSensitive
        // Store a numeric notification ID in userInfo so that
        // flutter_local_notifications' pendingNotificationRequests() can
        // parse it without crashing (it reads userInfo["NotificationId"]).
        content.userInfo = ["NotificationId": 1000]

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

    private func setupLiveActivityChannel(messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.jablecnik.timelog/live_activity",
            binaryMessenger: messenger
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
                        if action == "resume", let endAtMs = (args["endAt"] as? NSNumber)?.int64Value {
                            let endAt = Date(timeIntervalSince1970: Double(endAtMs) / 1000.0)
                            manager.updateLiveActivityResume(newEndAt: endAt)
                        } else {
                            manager.updateLiveActivity(action: action)
                        }
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

        // For resume, pass the new endAt that was calculated by the intent
        var arguments: [String: Any] = ["action": action]
        if action == "resume" {
            let resumedEndAt = defaults.double(forKey: "resumedEndAt")
            if resumedEndAt > 0 {
                arguments["endAtMs"] = Int64(resumedEndAt * 1000)
                defaults.removeObject(forKey: "resumedEndAt")
            }
        }

        defaults.synchronize()
        // Forward to Flutter
        methodChannel?.invokeMethod("onLockScreenAction", arguments: arguments)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        handlePendingWidgetAction()
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Show notifications even when app is in foreground.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Forward notification taps to flutter_local_notifications plugin.
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
