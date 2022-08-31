//
//  NewBooksViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/23.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

class NewBooksViewController: UIBaseViewController {

    // MARK: - Properties

    typealias ViewModel = NewBooksViewModel

    private var newBooks: BehaviorRelay<[Book]> = BehaviorRelay<[Book]>(value: [])
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    let actionTrigger = PublishRelay<NewBooksTriggerType>()

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    let subView = NewBooksView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

        bindingViewModel()
    }

    // MARK: - Binding

    func bindingViewModel() {
        subView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        let response = viewModel.transform(req: ViewModel.Input(actionTrigger: requestTrigger))
        response.newBookRelay
            .subscribe(onNext: { [weak self] bookResponse in
            guard let `self` = self else { return }
            UIView.transition(with: self.subView.collectionView, duration: 0.5, options: .transitionCrossDissolve) {
                self.newBooks.accept(bookResponse.books ?? [])
            }
        }).disposed(by: disposeBag)

        self.newBooks.asDriver()
            .drive(subView.collectionView.rx.items(cellIdentifier: NewBooksCell.identifier, cellType: NewBooksCell.self)) { index, book, cell in
                cell.setupRequest(with: book)
        }.disposed(by: disposeBag)

        subView.collectionView.rx.modelSelected(Book.self)
            .subscribe(onNext: { [weak self] model in
                guard let `self` = self else { return }
                let controller = DetailBookViewController()
                controller.setupRequest(with: model)
                self.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: disposeBag)

        requestTrigger.accept(())
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

extension NewBooksViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 265)
    }
}
