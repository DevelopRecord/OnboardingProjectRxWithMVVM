# <div align="center">SearchBookAPI</div>
<div align="center">Book Search Apps Using the ITBook API<br></div>
   
<div align="center"><br>
   <img src="https://img.shields.io/badge/Xcode-147EFB?style=flat-square&logo=xcode&logoColor=white"/>
   <img src="https://img.shields.io/badge/iOS-000000?style=flat-square&logo=iOS&logoColor=white"/>
   <img src="https://img.shields.io/badge/Swift-E34F26?style=flat-square&logo=swift&logoColor=white"/>
   <img src="https://img.shields.io/badge/ReactiveX-B7178C?style=flat-square&logo=ReactiveX&logoColor=white"/>
   <img src="https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=GitHub&logoColor=white"/>
</div>
   
## Chapter

[1. Library](#Library)   
[2. Framework](#Framework)   
[3. Preview](#Preview)   
[4. Main](#Main)   
[5. Search](#Search)   
[6. Detail](#Detail)   
[7. Trouble Shooting](#Trouble Shooting)   

## Library   
|이름|목적|버전|
|:------:|:---:|:---:|
|Alamofire|http 통신|5.5.0|
|RxSwift|비동기 프로그래밍|5.0.0|
|RxCocoa|비동기 UI 처리|5.0.0|
|Then|직관적이고 깔끔한 인스턴스 생성|2.2.0|
|SnapKit|Auto Layout|5.0.1|
|Kingfisher|URL 이미지 주소를 가진 이미지 불러오기|7.2.0|

## Framework
 - UIKit
   
## Preview


## Main
앱 실행 시 가장 먼저 보이는 화면입니다. API에서 가져온 20개의 책 리스트들을 컬렉션뷰에 담아 보여줍니다.  
API가 뿌려주는 데이터들 중 화면에 보여줄 데이터로 타이틀, 서브타이틀, 책 고유번호, 가격, 이미지, url 정보를 활용하였습니다.  

<img width="269" alt="스크린샷 2022-11-20 19 00 56" src="https://user-images.githubusercontent.com/76255765/202896002-df4661fd-9e7e-4011-8d83-102cd3adbbb5.png">

## Search
검색화면입니다. 가장 먼저 보여지는 책 리스트들은 기본적으로 메인화면의 책 리스트와 같습니다. 저기서 검색 버튼을 누르면 책 리스트가 비워지고, 사용자가 입력한 책 리스트들로 업데이트합니다.  
검색결과에 맞게 책 리스트들을 보여주며, 화면을 최하단으로 스크롤 시 다시 10개의 책 리스트들을 가져와 줍니다. 계속 스크롤하다 더이상 업데이트할 책 리스트가 없으면 사용자에게 토스트 메시지로 알려줍니다.  
각 셀의 오른쪽 상단에 위치하는 사파리 버튼을 누르면 선택한 책 정보가 나와있는 URL로 이동합니다. 앱을 벗어나지 않게 보여주기 위하여 SFSafariService를 사용하여 구현하였습니다.
  
## Detail
세부화면으로 이동할 때는 모든 데이터를 프로퍼티에 담아 사용하는 방식이 아닌, 책들을 선택할 때마다 isbn값만 사용하여 API를 호출하여 받아옵니다.  
사용자가 세부화면으로 이동하지 않을 수도 있기에 효율성 측면에서 고려하여 구현하였습니다.  
세부화면은 책에 대한 모든 정보가 나와있고 하단에 사용자가 메모를 입력할 수 있는 TextView를 만들었습니다. 데이터는 UserDefault를 사용하여 구현하였습니다.  
또한 TextView를 터치하면 키보드가 뷰를 가려버리는 현상이 발생하여 키보드가 올라올 때 키보드의 높이값을 계산하여 ScrollView를 키보드 높이값 만큼 올려 스크롤이 가능하게 구현하였습니다.  
  
## Trouble Shooting
매번 앱을 만들어 볼 때마다 MVC를 활용하여 만들었습니다. 개인 프로젝트에서는 간단하기에 MVC 패턴으로 만들어도 오히려 MVVM 패턴보다 좋다고 생각합니다. 다만, 회사 프로젝트에 MVC 패턴을 사용하면,
Controller에 코드가 몰려 관리가 사실상 불가능합니다. 그렇기에 비록 온보딩 프로젝트이지만 본 프로젝트 투입 전 RxSwift + MVVM 패턴을 활용하여 앱을 개발하였습니다.  
비동기와 MVVM 이라는 디자인 패턴을 배우기에 저에게 더할 나위 없이 좋은 경험이었고 실제로 본 프로젝트를 파악하는데 매우 큰 도움이 되었다고 자신있게 말할 수 있습니다.  
하지만 RxSwift + MVVM + Transform 을 사용하여 이렇게 사용해 본 것은 처음이라 역시 쉽지만은 않았습니다. 하지만 잘 안된 부분은 회사에서 혹은 퇴근하고 집에서 계속 파악하며 될 때까지 몰두하여  
온보딩에서 요구하는 조건들을 모두 만족시켰습니다. 문제 해결을 할 떄 디버깅(콘솔로그, 브레이크포인트, 라이프사이클)을 잘 하는 것도 매우 중요한 요소입니다.  
  
물론 아직도 배울 내용은 많습니다. 하지만 하나를 하더라도 확실히 파악하는게 중요하단 걸 새삼 느꼈습니다!  
오토레이아웃에 대해 깊이 있게 이해하는 능력도 매우 중요합니다. 오토레이아웃은 가장 기본이 되지만, 파고들면 상당히 머리가 아픈 부분인 것도 깨달았습니다.  
여기까지 읽어주셔서 감사합니다!









