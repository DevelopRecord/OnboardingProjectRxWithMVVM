//
//  DetailBookViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class DetailBookViewController: UIBaseViewController {
    typealias ViewModel = DetailBookViewModel

    // MARK: - ViewModelProtocol
    var viewModel: ViewModel!

    // MARK: - Properties

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupSubview()
        dismissKeyboardWhenTappedAround()
    }

    // MARK: - Binding
    func bindingViewModel() {
        _ = viewModel.transform(req: ViewModel.Input())
    }
    
    /// 데이터 셋업 메서드
    func setupRequest(with book: Book) {
        let url = URL(string: book.image ?? "")
        subView.isbn13 = book.isbn13 ?? ""

        subView.imageView.kf.setImage(with: url)
        subView.titleLabel.text = book.title
        subView.subtitleLabel.text = book.isEmptySubtitle
        subView.isbn13Label.text = book.isbn13
        subView.priceLabel.text = book.exchangeRateCurrencyKR
        subView.urlLabel.text = book.url
    }

    // MARK: - View
    let subView = DetailBookView()

    // MARK: - Methods
    
    override func setupLayout() {
        setupNavigationBar(title: R.DetailBookTextMessage.detailBooks, isLargeTitle: true)

        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupSubview() {
        subView.scrollView.delegate = self
        subView.textView.delegate = self
        
        let notification = NotificationCenter.default // 싱글톤 패턴. 사용 시점에 초기화해서 메모리 관리

        notification.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        navigationController?.navigationBar.prefersLargeTitles = false

        /// Keyboard의 사이즈
        guard var keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        keyboardSize = view.convert(keyboardSize, from: nil)

        if UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.safeAreaInsets.bottom ?? 0 > 0 {
            keyboardSize.size.height = keyboardSize.size.height / 2
        }

        /// contentInset은 안전영역 안에서 표시된다. 즉, 뷰들이 safeArea 영역 내에서 표시됨
        var contentInset: UIEdgeInsets = subView.scrollView.contentInset

        contentInset.bottom = keyboardSize.size.height
        subView.scrollView.contentInset = contentInset
        subView.scrollView.scrollIndicatorInsets = contentInset

        subView.scrollView.setContentOffset(CGPoint(x: 0, y: subView.scrollView.contentSize.height - subView.scrollView.bounds.size.height + subView.scrollView.contentInset.bottom), animated: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        navigationController?.navigationBar.prefersLargeTitles = true

        // TODO: scrollView의 setContentOffset을 아래처럼 잡지 말고, scrollIndicatorInsets를 .zero로 잡아야 키보드가 dismiss 됐을 때, 스크롤바가 정상적으로 표시됨.
        // TODO: setContentOffset을 아래와 같이 주면 오른쪽 스크롤바가 정상적으로 표시되지 않는 문제 있음.

        subView.scrollView.contentInset = .zero
        subView.scrollView.scrollIndicatorInsets = .zero
    }
}

extension DetailBookViewController: UITextViewDelegate {
    
}
