// HomeViewController.swift
import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class HomeViewController: BaseViewController {
    
    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()
    
    private let viewWillAppear = PublishRelay<Void>()
    
    private let shuffleButton = CustomBarButton(ImageLiterals.shuffle)
    private let palleteButton = CustomBarButton(ImageLiterals.paintpalette)
    private let rightStackView = UIStackView()
    
    private let theme1BgCardView = UIView()
    private let theme1FirstCardView = FirstThemeCardView()
    private let theme1SecondCardView = FirstThemeCardView() // 두 번째 카드뷰 추가
    
    // 카드 스와이프를 위한 변수들
    private var cardViews: [FirstThemeCardView] = []
    private var currentCardIndex = 0
    private var currentPhotos: [HomePhotoCardEntity] = []
    
    // 스와이프 방향 열거형 정의 (이제는 방향이 중요하지 않지만 코드 호환성을 위해 유지)
    private enum SwipeDirection {
        case left
        case right
    }
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init()
        
        // TODO: 2차에 테마 업데이트 할 때 hidden 제거
        shuffleButton.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwipeGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppear.accept(())
    }
    
    // 스와이프 제스처 설정
    private func setupSwipeGestures() {
        cardViews = [theme1FirstCardView, theme1SecondCardView]
        
        // 각 카드에 스와이프 제스처 추가
        for cardView in cardViews {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            cardView.addGestureRecognizer(panGesture)
            cardView.isUserInteractionEnabled = true
        }
    }
    
    // 카드뷰 초기화
    private func setupCardViews(with photos: [HomePhotoCardEntity]) {
        currentPhotos = photos
        currentCardIndex = 0
        
        // 모든 카드를 초기 상태로 리셋
        theme1FirstCardView.transform = CGAffineTransform.identity
        theme1SecondCardView.transform = CGAffineTransform.identity
        
        // 뒤에 있는 카드는 약간 작게 보이도록 설정
        theme1SecondCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
        theme1SecondCardView.alpha = 1.0
        
        // 첫 번째 카드 설정
        if photos.count > 0 {
            theme1FirstCardView.setImage(photos[0])
            theme1FirstCardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
            theme1FirstCardView.alpha = 1.0
        }
        
        // 두 번째 카드 설정
        if photos.count > 1 {
            theme1SecondCardView.setImage(photos[1])
            theme1SecondCardView.isHidden = false
        } else {
            theme1SecondCardView.isHidden = true
        }
        
        // 첫 번째 카드가 앞에 오도록 설정
        bringCardToFront(cardView: theme1FirstCardView)
    }
    
    // 특정 카드를 앞으로 가져오기
    private func bringCardToFront(cardView: UIView) {
        view.bringSubviewToFront(cardView)
    }
    
    // 스와이프 제스처 처리
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let card = gesture.view as? FirstThemeCardView else { return }
        
        // 맨 앞의 카드만 스와이프 가능하도록
        if card != cardViews[0] { return }
        
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x
        
        switch gesture.state {
        case .began:
            break
            
        case .changed:
            // 카드 이동 및 회전 처리
            let rotationAngle = xFromCenter / view.bounds.width * 0.4
            card.transform = CGAffineTransform(translationX: xFromCenter, y: translation.y)
                .rotated(by: rotationAngle)
            
            // 스와이프 방향에 따라 배경색 변경 효과 추가 가능
            
        case .ended:
            // 일정 거리 이상 스와이프 되었는지 확인
            if abs(xFromCenter) > 100 {
                // 스와이프 완료 애니메이션
                let screenWidth = view.bounds.width
                let directionMultiplier: CGFloat = xFromCenter > 0 ? 1 : -1
                let swipeDirection: SwipeDirection = xFromCenter > 0 ? .right : .left
                
                UIView.animate(withDuration: 0.3, animations: {
                    card.transform = CGAffineTransform(translationX: directionMultiplier * screenWidth * 1.5, y: 0)
                }) { _ in
                    // 스와이프 후 카드 완전 초기화
                    card.transform = CGAffineTransform.identity
                    self.showNextCard(direction: swipeDirection)
                }
            } else {
                // 제자리로 돌아가는 애니메이션 - 기본 회전값 유지
                UIView.animate(withDuration: 0.2) {
                    // 원래 회전값으로 복귀 (-CGFloat.pi / 60)
                    card.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                }
            }
            
        default:
            break
        }
    }
    
    // 다음 카드 표시
    private func showNextCard(direction: SwipeDirection = .right) {
        // 방향에 상관없이 항상 다음 사진으로 이동
        currentCardIndex += 1
        
        // 인덱스가 배열 범위를 벗어나면 처음으로 돌아가기
        if currentCardIndex >= currentPhotos.count {
            currentCardIndex = 0
        }
        
        // 모든 카드를 재설정
        for (index, cardView) in cardViews.enumerated() {
            // 먼저, 모든 변형을 초기화
            cardView.transform = CGAffineTransform.identity
            
            // 이미지 설정
            let photoIndex = (currentCardIndex + index) % max(currentPhotos.count, 1)
            
            if photoIndex < currentPhotos.count {
                cardView.isHidden = false
                cardView.setImage(currentPhotos[photoIndex])
                
                // 카드 위치별 스타일 설정
                if index == 0 {
                    // 첫 번째 카드 - 기본 회전만 적용
                    cardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                    cardView.alpha = 1.0
                } else {
                    // 두 번째 카드 - 회전 및 축소 적용
                    cardView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 60)
                    cardView.alpha = 1.0
                }
                
                // 첫 번째 카드가 앞에 오도록 설정
                if index == 0 {
                    bringCardToFront(cardView: cardView)
                }
            } else {
                cardView.isHidden = true
            }
        }
    }
    
    override func configureBind() {
        
        let input = HomeViewModel.Input(
            viewWillAppear: viewWillAppear.asObservable()
        )
        let output = viewModel.transform(from: input)
        
        output.currentPhotos
            .drive(with: self) { owner, photos in
                owner.setupCardViews(with: photos)
            }
            .disposed(by: disposeBag)
        
        palleteButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentColorThemeSheet()
            }
            .disposed(by: disposeBag)
        
        CurrentTheme.$currentTheme
            .bind(with: self) { owner, value in
                
                let theme = value.theme
                let color = value.color
                let colors = color.setColor(for: theme)
                
                let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: colors.text]
                
                owner.navigationController?.navigationBar.largeTitleTextAttributes = attribute
                owner.navigationController?.navigationBar.tintColor = colors.text
                owner.theme1BgCardView.backgroundColor = colors.main
                owner.view.backgroundColor = colors.background
            }
            .disposed(by: disposeBag)
    }
    
    private func presentColorThemeSheet() {
        
        let modalVC = ThemeColorModalView()
        
        if let sheet = modalVC.sheetPresentationController {
            
            if #available(iOS 16.0, *) {
                let customDetent = UISheetPresentationController.Detent.custom { context in
                    // 화면 높이의 1/3 반환
                    return context.maximumDetentValue / 3
                }
                sheet.detents = [customDetent]
            } else {
                sheet.detents = [.medium()]
            }
            
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(modalVC, animated: true)
    }
    
    override func configureNavigation() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.홈.title
        
        let rightStackBarButtonItem = UIBarButtonItem(customView: rightStackView)
        navigationItem.rightBarButtonItem = rightStackBarButtonItem
    }

    override func configureView() {
        rightStackView.distribution = .equalSpacing
        rightStackView.axis = .horizontal
        rightStackView.alignment = .center
        rightStackView.spacing = 15
        
        theme1BgCardView.cornerRadius30()
        theme1BgCardView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 60)
    }
    
    override func configureHierarchy() {
        rightStackView.addArrangedSubviews(shuffleButton, palleteButton)
        view.addSubviews(theme1BgCardView, theme1SecondCardView, theme1FirstCardView)
    }
    
    override func configureLayout() {
        theme1BgCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
        
        theme1SecondCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
        
        theme1FirstCardView.snp.makeConstraints {
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.width.equalTo(view.snp.width).multipliedBy(0.8)
            $0.height.equalTo(view.snp.height).multipliedBy(0.6)
        }
    }
}
