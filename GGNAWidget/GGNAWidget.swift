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
        SimpleEntry(date: Date(), configuration: SelectFolderAppIntent(), randomImage: nil)
    }
    
    func snapshot(for configuration: SelectFolderAppIntent, in context: Context) async -> SimpleEntry {
        let randomImage = loadRandomImage(for: configuration.selectedFolder?.folder)
        return SimpleEntry(date: Date(), configuration: configuration, randomImage: randomImage)
    }
    
    func timeline(for configuration: SelectFolderAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let updateInterval: TimeInterval = 2 * 60 * 60  // 2hour
        
        for hourOffset in 0 ..< 12 {
            let entryDate = Calendar.current.date(byAdding: .second, value: Int(Double(hourOffset) * updateInterval), to: currentDate)!
            
            let randomImage = loadRandomImage(for: configuration.selectedFolder?.folder)
            let entry = SimpleEntry(date: entryDate, configuration: configuration, randomImage: randomImage)
            entries.append(entry)
        }
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func loadRandomImage(for folderName: String?) -> UIImage? {
        // 선택된 폴더가 없으면 nil 반환
        guard let folderName = folderName else {
            return nil
        }
        
        // 공유 컨테이너 URL 가져오기
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ws.ggna.widget") else {
            print("공유 컨테이너 URL을 가져올 수 없습니다")
            return nil
        }
        
        // 해당 폴더 경로
        let folderURL = sharedContainerURL.appendingPathComponent(folderName)
        
        // 폴더가 존재하는지 확인
        guard FileManager.default.fileExists(atPath: folderURL.path) else {
            print("폴더를 찾을 수 없습니다: \(folderName)")
            return nil
        }
        
        do {
            // 폴더 내 모든 파일 가져오기
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            // jpg 파일만 필터링
            let imageURLs = fileURLs.filter { $0.pathExtension.lowercased() == "jpg" }
            
            if imageURLs.isEmpty {
                print("폴더에 이미지가 없습니다: \(folderName)")
                return nil
            }
            
            // 랜덤 이미지 선택
            let randomURL = imageURLs.randomElement()!
            
            // 이미지 로드
            return UIImage(contentsOfFile: randomURL.path)
            
        } catch {
            print("폴더 내용을 읽는 중 오류 발생: \(error)")
            return nil
        }
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: SelectFolderAppIntent
    let randomImage: UIImage?
}

struct GGNAWidgetEntryView_1 : View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            if let randomImage = entry.randomImage {
                Image(uiImage: randomImage)
                    .resizable()
                    .aspectRatio(ratio(for: family), contentMode: .fill)
            } else {
                Image(.defaultWidgetImage2)
                    .resizable()
                    .aspectRatio(ratio(for: family), contentMode: .fill)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.configuration.selectedFolder?.photos.first!.title ?? "")
                    .font(.system(size: fontSize(for: family).title, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(entry.configuration.selectedFolder?.folder ?? "")
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
        ZStack {
            if let randomImage = entry.randomImage {
                Image(uiImage: randomImage)
                    .resizable()
                    .aspectRatio(ratio(for: family), contentMode: .fill)
            } else {
                Image(.defaultWidget)
                    .resizable()
                    .aspectRatio(ratio(for: family), contentMode: .fill)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(alignment: .trailing, spacing: 0) {
                Text(entry.configuration.selectedFolder?.photos.first!.title ?? "")
                    .font(.system(size: fontSize(for: family).title, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(entry.configuration.selectedFolder?.folder ?? "")
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
