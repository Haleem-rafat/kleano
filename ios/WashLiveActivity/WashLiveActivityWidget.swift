import ActivityKit
import SwiftUI
import WidgetKit

private let brand = Color(red: 0.329, green: 0.188, blue: 0.376)
private let brandOnDark = Color(red: 0.776, green: 0.620, blue: 0.839)

private func symbol(_ step: Int) -> String {
  switch step {
  case 0: return "scooter"
  case 1: return "mappin.circle.fill"
  case 2: return "drop.fill"
  case 3: return "checkmark.circle.fill"
  default: return "clock.fill"
  }
}

private struct StageBar: View {
  let step: Int
  let labels: [String]
  let active: Color
  let idle: Color

  var body: some View {
    VStack(spacing: 4) {
      HStack(spacing: 4) {
        ForEach(0..<4, id: \.self) { index in
          Capsule().fill(index <= step ? active : idle).frame(height: 5)
        }
      }
      if labels.count == 4 {
        HStack(spacing: 4) {
          ForEach(0..<4, id: \.self) { index in
            Text(labels[index])
              .font(.caption2)
              .fontWeight(index == step ? .semibold : .regular)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      }
    }
  }
}

@available(iOS 16.2, *)
private struct LockScreenView: View {
  let context: ActivityViewContext<WashLiveAttributes>

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 12) {
        Image(systemName: symbol(context.state.step))
          .font(.title3)
          .foregroundStyle(.white)
          .frame(width: 44, height: 44)
          .background(brand, in: Circle())
        VStack(alignment: .leading, spacing: 2) {
          Text(context.attributes.vehicle).font(.headline).lineLimit(1)
          Text(context.attributes.address)
            .font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
        }
        Spacer(minLength: 8)
        Text(context.state.stage).font(.subheadline.weight(.semibold)).lineLimit(1)
      }
      StageBar(
        step: context.state.step, labels: context.attributes.stageLabels,
        active: brand, idle: Color.secondary.opacity(0.25))
    }
    .padding(16)
    .environment(\.layoutDirection, context.attributes.rtl ? .rightToLeft : .leftToRight)
  }
}

@available(iOS 16.2, *)
struct WashLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: WashLiveAttributes.self) { context in
      LockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: symbol(context.state.step))
            .font(.title2).foregroundStyle(brandOnDark).padding(.leading, 4)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(context.state.stage)
            .font(.subheadline.weight(.semibold)).foregroundStyle(brandOnDark).lineLimit(1)
            .minimumScaleFactor(0.8).padding(.trailing, 8)
        }
        DynamicIslandExpandedRegion(.center) {
          Text(context.attributes.vehicle).font(.headline).lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 8) {
            Text(context.attributes.address)
              .font(.footnote).foregroundStyle(.secondary).lineLimit(1)
            StageBar(
              step: context.state.step, labels: context.attributes.stageLabels,
              active: brandOnDark, idle: Color.white.opacity(0.2))
          }
          .padding(.horizontal, 8)
        }
      } compactLeading: {
        Image(systemName: symbol(context.state.step)).foregroundStyle(brandOnDark)
      } compactTrailing: {
        Text(context.state.stage)
          .font(.caption2.weight(.semibold)).foregroundStyle(brandOnDark)
          .lineLimit(1).frame(maxWidth: 64)
      } minimal: {
        Image(systemName: symbol(context.state.step)).foregroundStyle(brandOnDark)
      }
    }
  }
}

@main
struct WashLiveActivityBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.2, *) { WashLiveActivityWidget() }
  }
}
