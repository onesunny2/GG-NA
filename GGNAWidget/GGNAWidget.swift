//
//  GGNAWidget.swift
//  GGNAWidget
//
//  Created by Lee Wonsun on 4/23/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: SelectFolderAppIntent())
    }

    func snapshot(for configuration: SelectFolderAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: SelectFolderAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SelectFolderAppIntent
}

struct GGNAWidgetEntryView_1 : View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry
    
    var body: some View {
        Image(.zzamong)
            .resizable()
            .aspectRatio(ratio(for: family), contentMode: .fill)
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(entry.configuration.selectedFolder?.photos.first!.title ?? "하아아품")
                        .font(.system(size: fontSize(for: family).title, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.configuration.selectedFolder?.folder ?? "포오오올더")
                        .font(.system(size: fontSize(for: family).subtitle, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .shadow(radius: 1)
                .padding([.trailing, .bottom], padding(for: family))
            }
            .background(Color.gray)
            .clipShape(.rect(cornerRadius: cornerRadius(for: family)))
            .overlay(alignment: .topLeading) {
                Image(.darkIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize(for: family), height: iconSize(for: family))
                    .clipShape(.rect(cornerRadius: 10))
                    .padding([.top, .leading], iconPadding(for: family))
            }
    }
    
    func ratio(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 1.0
        case .systemLarge: return 0.94
        default: return 1.0
        }
    }
    
    func padding(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 10
        case .systemLarge: return 12
        default: return 8
        }
    }
    
    func cornerRadius(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 15
        case .systemLarge: return 20
        default: return 15
        }
    }
    
    func fontSize(for family: WidgetFamily) -> (title: CGFloat, subtitle: CGFloat) {
        switch family {
        case .systemSmall: return (20, 16)
        case .systemLarge: return (30, 24)
        default: return (20, 16)
        }
    }
    
    func iconSize(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 40
        case .systemLarge: return 60
        default: return 30
        }
    }
    
    func iconPadding(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 10
        case .systemLarge: return 20
        default: return 10
        }
    }
}

struct GGNAWidgetEntryView_2 : View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry
    
    var body: some View {
        Image(.zzamong)
            .resizable()
            .aspectRatio(ratio(for: family), contentMode: .fill)
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(entry.configuration.selectedFolder?.photos.first!.title ?? "하아아품")
                        .font(.system(size: fontSize(for: family).title, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.configuration.selectedFolder?.folder ?? "포오오올더")
                        .font(.system(size: fontSize(for: family).subtitle, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .shadow(radius: 1)
                .padding([.trailing, .bottom], padding(for: family))
            }
            .background(Color.gray)
            .clipShape(.rect(cornerRadius: cornerRadius(for: family)))
            .padding(padding(for: family))
            .overlay(alignment: .topLeading, content: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: iconSize(for: family)))
                    .foregroundStyle(.darkPink)
                    .padding(.leading, iconPadding(for: family).leading)
                    .padding(.top, iconPadding(for: family).top)
            })
    }
    
    func ratio(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 1.0
        case .systemLarge: return 0.94
        default: return 1.0
        }
    }
    
    func padding(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 8
        case .systemLarge: return 12
        default: return 8
        }
    }
    
    func cornerRadius(for family: WidgetFamily) -> CGFloat {
        return 15
    }
    
    func fontSize(for family: WidgetFamily) -> (title: CGFloat, subtitle: CGFloat) {
        switch family {
        case .systemSmall: return (20, 16)
        case .systemLarge: return (30, 24)
        default: return (20, 16)
        }
    }
    
    func iconSize(for family: WidgetFamily) -> CGFloat {
        switch family {
        case .systemSmall: return 30
        case .systemLarge: return 42
        default: return 30
        }
    }
    
    func iconPadding(for family: WidgetFamily) -> (leading: CGFloat, top: CGFloat) {
        switch family {
        case .systemSmall: return (15, 1)
        case .systemLarge: return (20, 1)
        default: return (15, 2)
        }
    }
}

struct GGNAWidget_1: Widget {
    let kind: String = WidgetInfo.firstWidgetKind.text
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectFolderAppIntent.self, provider: Provider()) { entry in
            GGNAWidgetEntryView_1(entry: entry)
                .containerBackground(.gnWhite, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemLarge])
        .contentMarginsDisabled()
        .configurationDisplayName(WidgetInfo.firstDisplayName.text)
        .description(WidgetInfo.widgetDescription.text)
    }
}

struct GGNAWidget_2: Widget {
    let kind: String = WidgetInfo.secondWidgetKind.text
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectFolderAppIntent.self, provider: Provider()) { entry in
            GGNAWidgetEntryView_2(entry: entry)
                .containerBackground(.gnWhite, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemLarge])
        .contentMarginsDisabled()
        .configurationDisplayName(WidgetInfo.secondDisplayName.text)
        .description(WidgetInfo.widgetDescription.text)
    }
}

//extension SelectFolderAppIntent {
//    fileprivate static var 기본: SelectFolderAppIntent {
//        let intent = SelectFolderAppIntent()
//        intent.selectedFolder =
//        return intent
//    }
//
//    fileprivate static var 인생: SelectFolderAppIntent {
//        let intent = SelectFolderAppIntent()
//        intent.selectedFolder = .인생
//        return intent
//    }
//}

//#Preview(as: .systemSmall) {
//    GGNAWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: SelectFolderAppIntent())
//}
