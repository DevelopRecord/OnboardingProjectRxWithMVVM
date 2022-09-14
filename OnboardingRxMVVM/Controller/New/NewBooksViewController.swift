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

    /// 뷰 로드 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자 액션 트리거
    let actionTriggers = PublishRelay<NewBooksTriggerType>()

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
    
    // MARK: - Binding
    
    func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(viewDidLoaded: requestTrigger.asObservable(),
                                                                action: actionTriggers))

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: actionTriggers)

        response.pushSelectedBook
            .bind(onNext: { [weak self] isbn13 in
                guard let `self` = self else { return }
                guard let isbn13 = isbn13 else { return }

                let controller = DetailBookViewController()
                controller.viewModel = DetailBookViewModel(isbn13: isbn13)
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: disposeBag)
        
        response.presentSafari
            .bind(onNext: { [weak self] url in
                guard let `self` = self else { return }
                let safariController = SFSafariViewController(url: url)
                self.present(safariController, animated: true)
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
}
