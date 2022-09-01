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
    let action = PublishRelay<NewBooksTriggerType>()

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    let subView = NewBooksView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindingViewModel()

        requestTrigger.accept(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        urlBinding()
    }
    
    // MARK: - Binding
    
    func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoaded: requestTrigger.asObservable(),
                                                                action: action))

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: action)
            .setupDI(relay: action)

        response.detailBookRelay
            .subscribe(onNext: { [weak self] book in
                guard let `self` = self else { return }
                let controller = DetailBookViewController()
                controller.setupRequest(with: book)
                self.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: disposeBag)
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
        action
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

// UIView.transition(with: self.subView.collectionView, duration: 0.5, options: .transitionCrossDissolve) {}
