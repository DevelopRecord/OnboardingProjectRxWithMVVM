//
//  SearchViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SafariServices

import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchViewController: UIBaseViewController {

    typealias ViewModel = SearchViewModel

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    // MARK: - Properties

    var disposeBag: DisposeBag = DisposeBag()

    /// 뷰 로드되고 온보딩 상태의 데이터 요청 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자의 액션을 담는 데이터 요청 트리거
    private var actionTriggers: PublishRelay<SearchTriggerType> = PublishRelay<SearchTriggerType>()
    

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
        let response = viewModel.transform(req: ViewModel.Input(
            viewDidLoaded: requestTrigger.asObservable(),
            action: actionTriggers))

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: actionTriggers)
            .setupDI(relay: actionTriggers)
    }

    // MARK: - View
    
    let subView = SearchView()

    override func setupLayout() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.SearchViewTextMessage.searchBooks, isLargeTitle: true, searchController: subView.searchController)

        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    /// 사파리 이동하기 위한 데이터 바인딩 메서드
    func urlBinding() {
        actionTriggers
            .filter { $0.index == 1 }
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
            .filter { $0.index == 3 }
            .subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .presentSafari(let urlString):
                guard let urlString = urlString, let url = URL(string: urlString) else { return }
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
}
