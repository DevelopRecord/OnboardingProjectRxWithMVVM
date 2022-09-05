//
//  NewBooksViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/23.
//

import UIKit
import SafariServices

import SnapKit
import Then
import RxSwift
import RxRelay

class NewBooksViewController: UIBaseViewController {

    // MARK: - Properties

    typealias ViewModel = NewBooksViewModel

    var disposeBag: DisposeBag = DisposeBag()

    private var newBooks: BehaviorRelay<[Book]> = BehaviorRelay<[Book]>(value: [])
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    let actionTriggers = PublishRelay<NewBooksTriggerType>()

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    let subView = NewBooksView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindingViewModel()
        urlBinding()

        requestTrigger.accept(())
    }
    
    // MARK: - Binding
    
    func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoaded: requestTrigger.asObservable(),
                                                                action: actionTriggers))

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: actionTriggers)
            .setupDI(relay: actionTriggers)

//        response.detailBookRelay
//            .subscribe(onNext: { [weak self] book in
//                guard let `self` = self else { return }
//                let controller = DetailBookViewController()
//                controller.setupRequest(with: book)
//                self.navigationController?.pushViewController(controller, animated: true)
//            }).disposed(by: disposeBag)
    }

    // MARK: - Helpers

    override func setupLayout() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.NewBooksTextMessage.newBooks, isLargeTitle: true)

        view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func urlBinding() {
        actionTriggers
            .filter { $0.index == 0 }
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                switch $0 {
                case .selectedBook(let book):
                    let controller = DetailBookViewController()
                    controller.isbn13Relay.accept(book.isbn13)
                    controller.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(controller, animated: true)
                default: break
                }
            }).disposed(by: disposeBag)
        
        actionTriggers
            .filter { $0.index == 1 }
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                switch $0 {
                case .presentSafari(let urlString):
                    guard let urlString = urlString, let url = URL(string: urlString) else { return }
                    print("URL: \(url)")
                    let safariViewController = SFSafariViewController(url: url)
                    self.present(safariViewController, animated: true)
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }
}
