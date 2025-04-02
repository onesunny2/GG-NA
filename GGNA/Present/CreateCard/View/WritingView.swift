//
//  WritingView.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/31/25.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class WritingView: BaseView {
    
    private let disposeBag = DisposeBag()
    
    private let cardView = UIView()
    private let appTitle: BaseUILabel
    private let titleTextField = UITextField()
    private let titleUnderline = UIView()
    private let detailTextView = UITextView()
    private let recordDate: BaseUILabel
    private let setMainCardButton: UIButton
    private let selectFolderTitle: BaseUILabel
    private let selectFolderButton: SelectedAnswerButton
    private let selectDateTitle: BaseUILabel
    private let selectDateButton: SelectedAnswerButton
    
    override init(frame: CGRect) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let buttonContainer = AttributeContainer().font(FontLiterals.subContent)
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 8)
        
        appTitle = BaseUILabel(
            text: writingViewLiterals.카드타이틀.text,
            color: colors.main,
            alignment: .center,
            font: FontLiterals.writngTitle
        )
        recordDate = BaseUILabel(
            text: "2025.03.26 수요일(test)",
            color: colors.background,
            alignment: .left,
            font: FontLiterals.subContent
        )
        setMainCardButton  = {
            let button = UIButton()
            var config = UIButton.Configuration.filled()
            config.attributedTitle = AttributedString(writingViewLiterals.메인카드설정.text, attributes: buttonContainer)
            config.image = ImageLiterals.square?.withConfiguration(buttonConfig)
            config.baseBackgroundColor = .clear
            config.baseForegroundColor = colors.text
            config.imagePlacement = .leading
            config.imagePadding = 2
            config.contentInsets = NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
            
            button.configuration = config
            return button
        }()
        selectFolderTitle = BaseUILabel(
            text: writingViewLiterals.폴더_선택.text,
            color: colors.text,
            font: FontLiterals.subTitle
        )
        selectFolderButton = SelectedAnswerButton(
            title: "선택",
            bgColor: colors.gray
        )
        selectDateTitle = BaseUILabel(
            text: writingViewLiterals.날짜_선택.text,
            color: colors.text,
            font: FontLiterals.subTitle
        )
        selectDateButton = SelectedAnswerButton(
            title: "2025년 03월 26일 수요일(test)",
            bgColor: colors.main
        )
        
        super.init(frame: frame)
        
        configureBind()
    }
    
    private func configureBind() {
        
        detailTextView.rx.didBeginEditing
            .bind(with: self) { owner, _ in
                
                guard owner.detailTextView.text != writingViewLiterals.내용_플레이스_홀더.text else {
                    owner.detailTextView.text = ""
                    return
                }
                
            }
            .disposed(by: disposeBag)
        
        detailTextView.rx.didEndEditing
            .bind(with: self) { owner, _ in
                
                guard owner.detailTextView.text != "" else {
                    owner.detailTextView.text = writingViewLiterals.내용_플레이스_홀더.text
                    return
                }
            }
            .disposed(by: disposeBag)
        
        setMainCardButton.rx.tap
            .bind(with: self) { owner, _ in
                print("tappedMainCardButton")
            }
            .disposed(by: disposeBag)
    }
    
    override func configureView() {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        let placeholder: [NSAttributedString.Key: Any] = [.font: FontLiterals.subContent, .foregroundColor: colors.gray]
        
        cardView.backgroundColor = colors.text
        cardView.cornerRadius15()
        
        titleTextField.textColor = colors.background
        titleTextField.attributedPlaceholder = NSAttributedString(string: writingViewLiterals.타이틀_플레이스_홀더.text, attributes: placeholder)
        
        titleUnderline.backgroundColor = colors.gray
        
        detailTextView.attributedText = NSAttributedString(string: writingViewLiterals.내용_플레이스_홀더.text, attributes: placeholder)
        detailTextView.backgroundColor = .clear
    }
    
    override func configureHierarchy() {
        addSubviews(cardView, appTitle, titleTextField, titleUnderline, detailTextView, recordDate, setMainCardButton, selectFolderTitle, selectFolderButton, selectDateTitle, selectDateButton)
    }
    
    override func configureLayout() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first  else { return }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(window.bounds.height / 2)
        }
        
        appTitle.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.top).offset(32)
            $0.horizontalEdges.equalTo(cardView).inset(32)
        }
        
        titleTextField.snp.makeConstraints {
            $0.horizontalEdges.equalTo(cardView).inset(20)
            $0.top.equalTo(appTitle.snp.bottom).offset(20)
        }
        
        titleUnderline.snp.makeConstraints {
            $0.horizontalEdges.equalTo(cardView).inset(20)
            $0.height.equalTo(0.5)
            $0.bottom.equalTo(titleTextField.snp.bottom).offset(4)
        }
        
        recordDate.snp.makeConstraints {
            $0.trailing.equalTo(cardView.snp.trailing).inset(20)
            $0.bottom.equalTo(cardView.snp.bottom).offset(-15)
        }
        
        detailTextView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(cardView).inset(15)
            $0.top.equalTo(titleUnderline.snp.bottom).offset(10)
            $0.bottom.equalTo(recordDate.snp.top).offset(-20)
        }
        
        setMainCardButton.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(6)
            $0.trailing.equalTo(cardView.snp.trailing)
        }
        
        selectFolderTitle.snp.makeConstraints {
            $0.top.equalTo(cardView.snp.bottom).offset(30)
            $0.leading.equalTo(cardView.snp.leading)
        }
        
        selectFolderButton.snp.makeConstraints {
            $0.top.equalTo(selectFolderTitle.snp.bottom).offset(8)
            $0.leading.equalTo(selectFolderTitle.snp.leading)
            $0.trailing.equalTo(selectFolderTitle.snp.trailing)
            $0.height.equalTo(35)
        }
        
        selectDateTitle.snp.makeConstraints {
            $0.top.equalTo(selectFolderButton.snp.bottom).offset(20)
            $0.leading.equalTo(cardView.snp.leading)
        }
        
        selectDateButton.snp.makeConstraints {
            $0.top.equalTo(selectDateTitle.snp.bottom).offset(8)
            $0.leading.equalTo(selectDateTitle.snp.leading)
            $0.height.equalTo(35)
        }
    }
}

extension WritingView {
    enum writingViewLiterals {
        case 카드타이틀
        case 타이틀_플레이스_홀더
        case 내용_플레이스_홀더
        case 페이스_ID
        case 메인카드설정
        case 폴더_선택
        case 날짜_선택
        
        var text: String {
            switch self {
            case .카드타이틀: return "GG.NA"
            case .타이틀_플레이스_홀더: return "(최대 6자) 사진의 타이틀을 정해주세요 :>"
            case .내용_플레이스_홀더: return "(선택) 선택한 사진에 남기고 싶은 추억을 적어보아요"
            case .페이스_ID: return "Face ID로 잠금 설정"
            case .메인카드설정: return "폴더의 메인카드로 설정"
            case .폴더_선택: return "저장 폴더 선택"
            case .날짜_선택: return "날짜 선택하기"
            }
        }
    }
}
