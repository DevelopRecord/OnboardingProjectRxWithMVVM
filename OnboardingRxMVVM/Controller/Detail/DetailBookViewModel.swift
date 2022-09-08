import UIKit
import RxCocoa
import RxSwift

enum DetailTriggerType {
    /// 텍스트뷰의 text
    case saveText(String?)
    /// 텍스트뷰의 모드
    case textViewMode(Bool)
    /// 뷰 진입
    case refresh
}

class DetailBookViewModel: ViewModelType {
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = DetailBookViewModel
    
    private var disposeBag: DisposeBag = DisposeBag()

    /// collectionView에 뿌려줄 데이터 리스트
    private var booksRelay: BehaviorRelay<Book> = BehaviorRelay<Book>(value: Book(title: "", subtitle: "", isbn13: "", price: "", image: "", url: ""))
    /// VC로부터 받아온 고유번호(isbn13)
    var isbn13: String!
    /// UserDefaults 싱글톤
    private let userDefaults = UserDefaults.standard
    /// 저장될 text
    private var userDefaultsText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

     init(isbn13: String) {
        self.isbn13 = isbn13
    }
    
    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<DetailTriggerType>
    }
    
    struct Output {
        let booksRelay: Observable<Book>
        let savedText: BehaviorRelay<String?>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoaded
            .subscribe(onNext: fetchDetailBook)
            .disposed(by: disposeBag)
        
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(booksRelay: booksRelay.asObservable(),
                      savedText: userDefaultsText)
    }
    
    func actionTriggerRequest(type: DetailTriggerType) {
        switch type {
        case .saveText(let text):
            userDefaultsText.accept(text)
        case .textViewMode(let bool):
            if bool {
                /// 텍스트뷰 수정 시작했을 떄
//                userDefaultsText.accept(userDefaults.string(forKey: isbn13))
            } else {
                /// 텍스트뷰 수정 끝냈을때
                userDefaults.set(userDefaultsText.value, forKey: isbn13)
            }
        case .refresh:
            userDefaultsText.accept(userDefaults.string(forKey: isbn13))
        }
    }
}

extension DetailBookViewModel {
    private func fetchDetailBook() {
        let result: Single<Book> = APIService.shared.fetchDetailBook(isbn13: isbn13)

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                self.booksRelay.accept(response)
            case .failure(_):
                Toast.shared.showToast(R.DetailBookTextMessage.failDetailMessage)
            }
        }.disposed(by: disposeBag)
    }
}
