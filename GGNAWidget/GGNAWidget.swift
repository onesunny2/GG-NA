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
    var entry: Provider.Entry
    
    var body: some View {
        Image(.zzamong)
            .resizable()
            .aspectRatio(1.0, contentMode: .fill)
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(entry.configuration.selectedFolder?.photos.first!.title ?? "하아아품")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.configuration.selectedFolder?.folder ?? "포오오올더")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .shadow(radius: 1)
                .padding([.trailing, .bottom], 8)
            }
            .background(Color.gray)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(alignment: .topLeading) {
                Image(.darkIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding([.top, .leading], 10)
            }
    }
}

struct GGNAWidgetEntryView_2 : View {
    var entry: Provider.Entry
    
    var body: some View {
        Image(.zzamong)
            .resizable()
            .aspectRatio(1.0, contentMode: .fill)
            .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(entry.configuration.selectedFolder?.photos.first!.title ?? "하아아품")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(entry.configuration.selectedFolder?.folder ?? "포오오올더")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .shadow(radius: 1)
                .padding([.trailing, .bottom], 8)
            }
            .background(Color.gray)
            .clipShape(.rect(cornerRadius: 15))
            .padding(8)
            .overlay(alignment: .topLeading, content: {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.darkPink)
                    .padding(.leading, 15)
                    .padding(.bottom, 10)
            })
    }
}

struct GGNAWidget_1: Widget {
    let kind: String = WidgetInfo.firstWidgetKind.text

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectFolderAppIntent.self, provider: Provider()) { entry in
            GGNAWidgetEntryView_1(entry: entry)
                .containerBackground(.gnWhite, for: .widget)
        }
        .supportedFamilies([.systemSmall])
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
        .supportedFamilies([.systemSmall])
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
