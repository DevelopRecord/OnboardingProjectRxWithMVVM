//
//  DetailBookView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class DetailBookView: UIBaseView {

    // MARK: - Model type implemente

    typealias Model = Void

    // MARK: - Properties

    var disposeBag = DisposeBag()

    lazy var scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }

    private lazy var infoImageView = UIView().then {
        $0.backgroundColor = .secondarySystemBackground
    }

    let imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, isbn13Label, priceLabel, urlView]).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .leading
    }

    let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }

    let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    let isbn13Label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
    }

    private lazy var urlView = UIView().then {
        $0.backgroundColor = .clear
        $0.setHeight(50)
    }

    let urlLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .systemBlue
    }

    private let divideView = UIView().then {
        $0.backgroundColor = .systemGray
    }

    lazy var textView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.isScrollEnabled = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray2.cgColor
    }

    // MARK: - Dependency Injection
    @discardableResult
    func setupDI(book: Observable<Book>) -> Self {
        book
            .withUnretained(self)
            .bind(onNext: { owner, book in
                guard let image = book.image, let url = URL(string: image) else { return }

                owner.imageView.kf.setImage(with: url)
                owner.titleLabel.text = book.title
                owner.subtitleLabel.text = book.isEmptySubtitle
                owner.isbn13Label.text = book.isbn13
                owner.priceLabel.text = book.exchangeRateCurrencyKR
                owner.urlLabel.text = book.url
        }).disposed(by: disposeBag)

        return self
    }

    @discardableResult
    /// UITextView 사용자 액션
    func textSetupDI(action: PublishRelay<DetailTriggerType>) -> Self {
        // 서치바 텍스트 변경
        textView.rx.text
            .orEmpty
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { .saveText($0) }
            .bind(to: action)
            .disposed(by: disposeBag)

        // 텍스트뷰 편집 시작
        textView.rx.didBeginEditing
            .map { .textViewMode(true) }
            .bind(to: action)
            .disposed(by: disposeBag)

        // 텍스트뷰 편집 끝
        textView.rx.didEndEditing
            .map { .textViewMode(false) }
            .bind(to: action)
            .disposed(by: disposeBag)

        return self
    }

    @discardableResult
    func viewSetupDI(action: PublishRelay<DetailTriggerType>, savedText: BehaviorRelay<String?>) -> Self {
        savedText
            .withUnretained(self)
            .bind(onNext: { owner, text in
                guard let text = text else { return }
                owner.textView.text = text
        }).disposed(by: disposeBag)

        return self
    }

    // MARK: - Methods

    override func setupLayout() {
        backgroundColor = .systemBackground

        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubviews(views: [infoImageView, stackView, divideView, textView])
        urlView.addSubview(urlLabel)

        infoImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(160)
            $0.top.leading.trailing.equalToSuperview()
        }

        infoImageView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(140)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(infoImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        urlLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }

        divideView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(urlView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        textView.snp.makeConstraints {
            $0.height.equalTo(200)
            $0.top.equalTo(divideView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        containerView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            /// contentView의 높이값을 스크롤뷰보다 1더 크게해야 스크롤가능하기 때문에 우선순위를 high로 잡는다.
            /// contentView가 우선순위에 밀려 작아져버려 스크롤이 불가능한 상황이 발생할지는 모르겠으나 안전하게 하기 위함.
            $0.height.greaterThanOrEqualTo(scrollView.snp.height).offset(1).priority(.high)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
