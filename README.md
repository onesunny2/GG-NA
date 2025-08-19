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

</br>

### 2. 채팅 및 PushNotification
- 서버에서 받은 채팅은 Realm을 활용해 로컬DB에 저장합니다.
- SwiftUI에서 사용할 수 있도록 제공되는 Realm의 @ObservedResults 프로퍼티 래퍼를 통해 데이터의 변경사항을 자동으로 감지하여 UI를 구현합니다.
- 상대방과의 채팅방에 진입할 시 로컬에 저장된 가장 최근 메시지 타임스탬프를 기준으로 서버통신하여 새로운 메시지를 받아 realm에 업데이트합니다.
- 소켓통신의 경우, 상대방과의 메시지 누락을 방지하기 위해 서버통신이 이루어지기 전 소켓 연결을 먼저 진행합니다.
- 만약 상대방과의 채팅방에 있는 경우, 해당 상대의 채팅 메시지는 notification이 오지 않도록 합니다. </br>
  ㄴ 다만 상대방과의 채팅방에 있는 상태에서 background로 전환될 시 다시 notification이 수신되도록 분기처리를 진행했습니다.

### 3. 커뮤니티 내 이미지 갯수에 따른 동적 View 구성
<img width="474" height="312" alt="image" src="https://github.com/user-attachments/assets/9b88c547-a056-4a8d-9fd9-73a4f416c538" />
</br></br>

- 커뮤니티 게시글 포스팅 시 최소 0개부터 최대 5개까지의 이미지를 서버에 업로드 할 수 있습니다.</br>
- 이에 따라 커뮤니티 게시글 조회 시, 게시글마다 이미지의 갯수가 달라 UI적으로 분기처리가 불가피했습니다.</br>
- 기본적으로 이미지 1개에 대한 범용적인 UI 컴포넌트를 구성하였으며 나머지는 아래와 같이 구성했습니다.</br>
  ㄴ 1~2개: frame의 height를 고정하고 width는 각 화면의 여백에 따라 크기가 결정되도록 동적 구성</br>
  ㄴ 3개 이상: 별도의 MultiImageCell을 구성하여 디자인 의도에 따라 고정 이미지의 frame을 설정한 후 나머지는 여백에 동적 배치되도록 구성
