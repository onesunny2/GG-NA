# 🎞️끄나: 그 때 그 순간의 나를 기억하며
> 소중한 추억들을 포토카드에 간단한 메시지와 함께 기록 및 보관하는 서비스
<img width="882" height="479" alt="image" src="https://github.com/user-attachments/assets/3d114c2f-3d1e-4c0d-bd4d-6ce589d43c7b" />


## 앱 소개
- 개발 기간: 25.03.26 ~ 25.04.05 (유지보수 중)
- 구성 인원: 기획 & 디자인 & iOS 개발 (1인)
- 최소 버전: iOS 15.0 +
  
## 기술스택
<img width="468" height="91" alt="image" src="https://github.com/user-attachments/assets/33174ee5-4664-4817-8707-0cce760efa37" />


## 기능소개

|   포토카드 작성 및 저장 기능   |   폴더기반 관리 시스템   |    커스텀 카메라 및 이미지 필터 기능   | 폴더별 이미지 미리보기 기능   |
|  :-------------: |  :-------------: |  :-------------: |  :-------------: |
| <img width=200 src="https://github.com/user-attachments/assets/c203d01e-55bb-4b4c-8885-100dd56fc50b"> | <img width=200 src="https://github.com/user-attachments/assets/38a2dc07-fe50-4f3e-849c-07ae3fc19679"> | <img width=200 src="https://github.com/user-attachments/assets/6e27a525-c2a9-4487-b937-81a8d06e0f48"> | <img width=200 src="https://github.com/user-attachments/assets/c0261ddb-4c01-4efd-9ec1-9e1682cff832"> |

|   FaceID 기반 보안 기능   |   위젯 지원   |    다양한 색상 테마 지원   |
|  :-------------: |  :-------------: |  :-------------: |
| <img width=200 src="https://github.com/user-attachments/assets/948a1d7c-4cc5-4005-a413-a135204c57ea"> | <img width=200 src="https://github.com/user-attachments/assets/64febe7d-b920-4c10-8fac-23a77b156866"> | <img width=200 src="https://github.com/user-attachments/assets/5490a5c7-dc02-4e0f-b516-05246bebb0c8"> |

## 상세기능
### 1. AVFoundation 커스텀 카메라 구현
```
CameraManager (카메라 엔진)
├── AVCaptureSession (세션 관리)
├── AVCaptureVideoDataOutput (비디오 데이터 출력)
├── AVCaptureDeviceInput (카메라 입력)
└── RxSwift Observable (상태 관리)

CameraViewController (UI 컨트롤러)
├── UI 이벤트 바인딩
├── 카메라 상태 구독
└── 촬영 결과 처리

VideoView (렌더링 뷰)
└── CALayer 직접 렌더링
```

#### 3계층 분리 아키텍처
- CameraManager: 카메라 세션 및 데이터 처리 로직
- CameraViewController: UI 이벤트 처리 및 사용자 인터페이스
- VideoView: 실시간 렌더링 전용 커스텀 뷰

#### 데이터 플로우
<img width="671" height="161" alt="image" src="https://github.com/user-attachments/assets/d9878348-0a71-465f-8414-91787b9758e1" />

#### 성능 최적화 전략
1. RxSwift 기반 상태 관리
   </br>
  - BehaviorRelay를 활용해 카메라 위치(전후면) 상태 관리
  - Driver를 통한 메인 스레드 UI업데이트 보장
  - PublishRelay로 촬영 결과 비동기 전달 
2. 메모리 최적화
   </br>
 - UIImage 변환 과정 제거
 - 불필요한 메모리 복사 방지: CVPixelBuffer 직접 활용
 - 약한 참조 사용
    
3. 렌더링 최적화
   </br>
 - CALayer 직접 조작: layer.contents에 CGImage 직접 설정
 - 메인스레드 보장
    
4. 스레드 관리
   </br>
 - background 세션 시작
 - 비디오 처리 전용 큐 사용
- UI 업데이트 분리

### 2. 시스템 테마색상 상태관리
- 사용자가 시스템 테마를 선택했을 때, 실시간으로 앱의 모든 컬러가 이를 감지하여 업데이트 되도록 구현
- @propertyWrapper와 RxCocoa의 UserDefaults 옵저버 기능을 결합해 현재 테마 색상을 조회하거나 변경할 수 있도록 설계
- enum에 테마 컬러를 쉽게 추가할 수 있도록 유지보수성과 확장성 고려
<img width="1246" height="415" alt="image" src="https://github.com/user-attachments/assets/4777c878-5e3f-4411-9305-cc478cef1c05" />




