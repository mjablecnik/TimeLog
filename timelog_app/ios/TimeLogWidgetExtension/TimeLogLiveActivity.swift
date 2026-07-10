import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - Lock screen view

struct TimeLogLockScreenView: View {
    let context: ActivityViewContext<TimeLogAttributes>

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TimeLog")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#EEE6DC").opacity(0.5))
                timerLabel
            }
            Spacer()
            controlButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#1A1310"))
    }

    @ViewBuilder
    private var timerLabel: some View {
        if context.state.isCompleted {
            Text("Timer complete!")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "#E88A66"))
        } else if context.state.isPaused, let secs = context.state.pausedSecondsLeft {
            let mins = secs / 60
            let s = secs % 60
            Text(String(format: "%02d:%02d  paused", mins, s))
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#EEE6DC"))
        } else {
            Text(timerInterval: Date.now...context.state.endAt, countsDown: true)
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#EEE6DC"))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        if context.state.isCompleted {
            Link(destination: URL(string: "timelogapp://action/stop")!) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 38))
                    .foregroundColor(Color(hex: "#E88A66"))
            }
            .frame(minWidth: 60, minHeight: 60)
        } else if context.state.isPaused {
            HStack(spacing: 4) {
                Link(destination: URL(string: "timelogapp://action/resume")!) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#E88A66"))
                }
                .frame(minWidth: 60, minHeight: 60)
                Link(destination: URL(string: "timelogapp://action/stop")!) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#EEE6DC").opacity(0.4))
                }
                .frame(minWidth: 60, minHeight: 60)
            }
        } else {
            HStack(spacing: 4) {
                Link(destination: URL(string: "timelogapp://action/pause")!) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#E88A66"))
                }
                .frame(minWidth: 60, minHeight: 60)
                Link(destination: URL(string: "timelogapp://action/stop")!) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(hex: "#EEE6DC").opacity(0.4))
                }
                .frame(minWidth: 60, minHeight: 60)
            }
        }
    }
}

// MARK: - Widget

struct TimeLogLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeLogAttributes.self) { context in
            TimeLogLockScreenView(context: context)
                .activityBackgroundTint(Color(hex: "#1A1310"))
                .activitySystemActionForegroundColor(Color(hex: "#E88A66"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("TimeLog")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .foregroundColor(Color(hex: "#E88A66"))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if context.state.isPaused {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(Color(hex: "#E88A66"))
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    expandedCountdown(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    expandedControls(context: context)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "#E88A66"))
            } compactTrailing: {
                compactTrailing(context: context)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "#E88A66"))
            }
            .keylineTint(Color(hex: "#E88A66"))
        }
    }

    @ViewBuilder
    private func expandedCountdown(context: ActivityViewContext<TimeLogAttributes>) -> some View {
        if context.state.isCompleted {
            Text("Done!")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "#E88A66"))
        } else if context.state.isPaused, let secs = context.state.pausedSecondsLeft {
            let mins = secs / 60
            let s = secs % 60
            Text(String(format: "%02d:%02d", mins, s))
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#EEE6DC"))
        } else {
            Text(timerInterval: Date.now...context.state.endAt, countsDown: true)
                .font(.system(.title3, design: .monospaced).weight(.light))
                .foregroundColor(Color(hex: "#EEE6DC"))
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func expandedControls(context: ActivityViewContext<TimeLogAttributes>) -> some View {
        HStack(spacing: 24) {
            if context.state.isCompleted {
                Link(destination: URL(string: "timelogapp://action/stop")!) {
                    Label("Dismiss", systemImage: "xmark.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#E88A66"))
                }
            } else if context.state.isPaused {
                Link(destination: URL(string: "timelogapp://action/resume")!) {
                    Label("Resume", systemImage: "play.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#E88A66"))
                }
                Link(destination: URL(string: "timelogapp://action/stop")!) {
                    Label("Stop", systemImage: "stop.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#EEE6DC").opacity(0.5))
                }
            } else {
                Link(destination: URL(string: "timelogapp://action/pause")!) {
                    Label("Pause", systemImage: "pause.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#E88A66"))
                }
                Link(destination: URL(string: "timelogapp://action/stop")!) {
                    Label("Stop", systemImage: "stop.circle")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#EEE6DC").opacity(0.5))
                }
            }
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func compactTrailing(context: ActivityViewContext<TimeLogAttributes>) -> some View {
        if context.state.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        } else if context.state.isPaused {
            Image(systemName: "pause.circle")
                .foregroundColor(Color(hex: "#E88A66"))
        } else {
            Text(timerInterval: Date.now...context.state.endAt, countsDown: true)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(Color(hex: "#E88A66"))
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 48)
                .minimumScaleFactor(0.7)
        }
    }
}

// MARK: - Color hex extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1.0
        )
    }
}
