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
    private let datePickerManager = DatePickerManager.shared
    
    let inputTitleText = PublishRelay<String>()
    let inputDetailText = PublishRelay<String>()
    let isMainImage = BehaviorRelay(value: false)
    let keyboardDismissed = PublishRelay<Void>() // 키보드 내림 이벤트
    
    private let cardView = UIView()
    private let appTitle: BaseUILabel
    private let titleTextField = UITextField()
    private let titleUnderline = UIView()
    private let detailTextView = UITextView()
    private let recordDate: BaseUILabel
    private let setMainCardButton = SelectedButton(title: .메인카드설정)
    private let setSecretModeButton = SelectedButton(title: .열람잠금설정)
    private let selectFolderTitle: BaseUILabel
    let selectFolderButton: SelectedFolderButton
    private let selectDateTitle: BaseUILabel
    private let keyboardToolbar = UIToolbar() // 키보드 툴바 추가
    
    override init(frame: CGRect) {
        
        let theme = CurrentTheme.currentTheme.theme
        let color = CurrentTheme.currentTheme.color
        let colors = color.setColor(for: theme)
        
        appTitle = BaseUILabel(
            text: writingViewLiterals.카드타이틀.text,
            color: colors.main,
            alignment: .center,
            font: FontLiterals.writngTitle
        )
        recordDate = BaseUILabel(
            text: "",
            color: colors.background,
            alignment: .left,
            font: FontLiterals.subContent
        )
        selectFolderTitle = BaseUILabel(
            text: writingViewLiterals.폴더_선택.text,
            color: colors.text,
            font: FontLiterals.subTitle
        )
        selectFolderButton = SelectedFolderButton(bgColor: colors.gray)
        selectDateTitle = BaseUILabel(
            text: writingViewLiterals.날짜_선택.text,
            color: colors.text,
            font: FontLiterals.subTitle
        )
        
        super.init(frame: frame)
        
        configureBind()
        setupKeyboardToolbar()
    }
    
    private func setupKeyboardToolbar() {
        keyboardToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: nil)
        
        doneButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.detailTextView.resignFirstResponder()
                owner.keyboardDismissed.accept(())
            }
            .disposed(by: disposeBag)
            
        keyboardToolbar.items = [flexSpace, doneButton]
        detailTextView.inputAccessoryView = keyboardToolbar
        
        // 자동완성 바 제거
        detailTextView.autocorrectionType = .no
        detailTextView.spellCheckingType = .no
    }
    
    private func configureBind() {
        
        setMainCardButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.isMainImage.accept(owner.setMainCardButton.isSelected)
            }
            .disposed(by: disposeBag)
 
        Observable.merge(
            titleTextField.rx.controlEvent(.editingDidEndOnExit).withLatestFrom(titleTextField.rx.text.orEmpty),
            titleTextField.rx.controlEvent(.editingChanged).withLatestFrom(titleTextField.rx.text.orEmpty)
        )
        .map { return $0.trimmingCharacters(in: .whitespaces) }
        .bind(with: self) { owner, text in
            
            guard text.count > 7 else {
                print(text)
                owner.titleTextField.text = text
                owner.inputTitleText.accept(text)
                return
            }
            
            let prefixed = String(text.prefix(7))
            owner.titleTextField.text = prefixed
            owner.inputTitleText.accept(prefixed)
            
            owner.endEditing(true)
        }
        .disposed(by: disposeBag)
        
        detailTextView.rx.didBeginEditing
            .withLatestFrom(detailTextView.rx.text.orEmpty)
            .map { return $0.trimmingCharacters(in: .whitespaces) }
            .bind(with: self) { owner, text in
                
                guard text != writingViewLiterals.내용_플레이스_홀더.text else {
                    owner.detailTextView.text = ""
                    return
                }
            }
            .disposed(by: disposeBag)
        
        detailTextView.rx.didChange
            .withLatestFrom(detailTextView.rx.text.orEmpty)
            .map { return $0.trimmingCharacters(in: .whitespaces) }
            .bind(with: self) { owner, text in
                
                guard text != "" else { return }
                owner.inputDetailText.accept(text)
            }
            .disposed(by: disposeBag)
        
        detailTextView.rx.didEndEditing
            .withLatestFrom(detailTextView.rx.text.orEmpty)
            .map { return $0.trimmingCharacters(in: .whitespaces) }
            .bind(with: self) { owner, text in
                
                guard text != "" else {
                    owner.detailTextView.text = writingViewLiterals.내용_플레이스_홀더.text
                    return
                }
                owner.inputDetailText.accept(text)
            }
            .disposed(by: disposeBag)
        
        datePickerManager.formattedDateString
            .bind(to: recordDate.rx.text)
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
        addSubviews(cardView, appTitle, titleTextField, titleUnderline, detailTextView, recordDate, setMainCardButton, setSecretModeButton,  selectFolderTitle, selectFolderButton, selectDateTitle, datePickerManager.datePickerStackView)
    }
    
    override func configureLayout() {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first  else { return }
        
        cardView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(window.bounds.height / 2)
            $0.bottom.lessThanOrEqualTo(keyboardLayoutGuide.snp.top).offset(50)
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
            $0.top.equalTo(cardView.snp.bottom).offset(10)
            $0.trailing.equalTo(cardView.snp.trailing).offset(-10)
        }
        
        setSecretModeButton.snp.makeConstraints {
            $0.top.equalTo(setMainCardButton.snp.bottom).offset(6)
            $0.trailing.equalTo(setMainCardButton.snp.trailing)
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
        
        datePickerManager.datePickerStackView.snp.makeConstraints {
             $0.top.equalTo(selectDateTitle.snp.bottom).offset(8)
             $0.leading.equalTo(selectDateTitle.snp.leading)
             $0.trailing.lessThanOrEqualTo(cardView.snp.trailing)
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
        case 폴더_선택
        case 날짜_선택
        
        var text: String {
            switch self {
            case .카드타이틀: return "GG.NA"
            case .타이틀_플레이스_홀더: return "(최대 7자) 사진의 타이틀을 정해주세요 :>"
            case .내용_플레이스_홀더: return "(선택) 선택한 사진에 남기고 싶은 추억을 적어보아요"
            case .페이스_ID: return "Face ID로 잠금 설정"
            case .폴더_선택: return "저장 폴더 선택"
            case .날짜_선택: return "날짜 선택하기"
            }
        }
    }
}
