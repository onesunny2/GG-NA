//
//  DatePickerManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/3/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DatePickerManager {

    static let shared = DatePickerManager()
    
    private let disposeBag = DisposeBag()
    
    // 현재 선택된 날짜
    let selectedDate = BehaviorRelay<Date>(value: Date())
    
    // 날짜 포맷팅된 결과 (yyyy.MM.dd EEEE)
    let formattedDateString = BehaviorRelay<String>(value: "")
    
    // 년, 월, 일 개별 값
    private var selectedYear: Int
    private var selectedMonth: Int
    private var selectedDay: Int
    
    // 버튼 구성
    let yearButton = UIButton(type: .system)
    let monthButton = UIButton(type: .system)
    let dayButton = UIButton(type: .system)
    
    // 스택뷰
    lazy var datePickerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [yearButton, monthButton, dayButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private init() {
        let calendar = Calendar.current
        let now = Date()
        
        selectedYear = calendar.component(.year, from: now)
        selectedMonth = calendar.component(.month, from: now)
        selectedDay = calendar.component(.day, from: now)
        
        configureButtons()
        updateButtonTitles()
        updateFormattedDate()
        bindDateChanges()
    }
    
    private func configureButtons() {
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        // 년도 버튼 설정
        configureButton(yearButton, colors: colors)
        yearButton.menu = createYearMenu()
        yearButton.showsMenuAsPrimaryAction = true
        
        // 월 버튼 설정
        configureButton(monthButton, colors: colors)
        monthButton.menu = createMonthMenu()
        monthButton.showsMenuAsPrimaryAction = true
        
        // 일 버튼 설정
        configureButton(dayButton, colors: colors)
        dayButton.menu = createDayMenu()
        dayButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureButton(_ button: UIButton, colors: ColorSet) {
        var config = UIButton.Configuration.bordered()
        config.baseForegroundColor = colors.text
        config.baseBackgroundColor = colors.main80
        config.background.cornerRadius = 5
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20)
        button.configuration = config
    }
    
    private func updateButtonTitles() {
        yearButton.configuration?.title = "\(selectedYear)년"
        monthButton.configuration?.title = "\(selectedMonth)월"
        dayButton.configuration?.title = "\(selectedDay)일"
    }
    
    private func updateFormattedDate() {
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDay
        
        if let date = Calendar.current.date(from: dateComponents) {
            selectedDate.accept(date)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd EEEE"
            formatter.locale = Locale(identifier: "ko_KR")
            let dateString = formatter.string(from: date)
            formattedDateString.accept(dateString)
        }
    }
    
    private func bindDateChanges() {
        selectedDate
            .bind(with: self, onNext: { owner, _ in
                owner.updateButtonMenus()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateButtonMenus() {
        yearButton.menu = createYearMenu()
        monthButton.menu = createMonthMenu()
        dayButton.menu = createDayMenu()
    }
    
    // MARK: - Menus
    private func createYearMenu() -> UIMenu {
        // 현재 년도부터 과거 20년까지
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = currentYear - 20
        
        var yearActions: [UIMenuElement] = []
        
        // 년도별 메뉴 아이템 생성 (내림차순: 최신순이 가장 위에)
        for year in stride(from: startYear, through: currentYear, by: +1) {
            let action = UIAction(title: "\(year)년", state: year == selectedYear ? .on : .off) { [weak self] _ in
                guard let self = self else { return }
                self.selectedYear = year
                self.updateButtonTitles()
                self.validateSelectedDate()
                self.updateFormattedDate()
            }
            yearActions.append(action)
        }
        
        return UIMenu(title: "", options: [.displayInline, .singleSelection], children: yearActions)
    }
    
    private func createMonthMenu() -> UIMenu {
         var monthActions: [UIMenuElement] = []
         
         // 12부터 1까지 내림차순 (큰 숫자가 위쪽)
         for month in stride(from: 12, through: 1, by: -1) {
             let action = UIAction(title: "\(month)월", state: month == selectedMonth ? .on : .off) { [weak self] _ in
                 guard let self = self else { return }
                 self.selectedMonth = month
                 self.updateButtonTitles()
                 self.validateSelectedDate()
                 self.updateFormattedDate()
             }
             monthActions.append(action)
         }
         
         return UIMenu(title: "", options: [.displayInline, .singleSelection], children: monthActions)
     }
    
    private func createDayMenu() -> UIMenu {
        var dayActions: [UIMenuElement] = []
        
        // 해당 월의 일수 계산
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            // 기본값으로 31-1일까지 보여주기 (내림차순: 큰 숫자가 위쪽)
            for day in stride(from: 1, through: 31, by: +1) {
                createDayAction(day: day, dayActions: &dayActions)
            }
            return UIMenu(title: "", options: [.displayInline, .singleSelection], children: dayActions)
        }
        
        // 해당 월의 실제 일수에 맞게 메뉴 생성 (내림차순: 큰 숫자가 위쪽)
        for day in stride(from: range.count, through: 1, by: -1) {
            createDayAction(day: day, dayActions: &dayActions)
        }
        
        return UIMenu(title: "", options: [.displayInline, .singleSelection], children: dayActions)
    }
    
    private func createDayAction(day: Int, dayActions: inout [UIMenuElement]) {
        let action = UIAction(title: "\(day)일", state: day == selectedDay ? .on : .off) { [weak self] _ in
            guard let self = self else { return }
            self.selectedDay = day
            self.updateButtonTitles()
            self.updateFormattedDate()
        }
        dayActions.append(action)
    }
    
    // 선택된 날짜가 유효한지 확인 및 조정
    private func validateSelectedDate() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = selectedYear
        dateComponents.month = selectedMonth
        dateComponents.day = selectedDay
        
        // 선택된 년월에 해당하는 마지막 날짜 확인
        guard let date = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: date) else {
            return
        }
        
        // 선택된 일이 해당 월의 마지막 날보다 크면 조정
        if selectedDay > range.count {
            selectedDay = range.count
            updateButtonTitles()
        }
    }
}
