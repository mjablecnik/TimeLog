import Flutter
import UIKit

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
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
}
