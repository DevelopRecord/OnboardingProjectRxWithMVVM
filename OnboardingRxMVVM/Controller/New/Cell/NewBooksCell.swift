//
//  NewBooksCell.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit
import RxSwift
import RxCocoa

class NewBooksCell: UIBaseCollectionViewCell {

    // MARK: - Properties
    
    static let identifier = "NewBooksCell"
    
    private var actionTriggers = PublishRelay<NewBooksTriggerType>()
    var bookData: Book?

    var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var infoImageView = UIView().then {
        $0.backgroundColor = .systemGray5
    }

    let infoTitleView = UIView().then {
        $0.backgroundColor = .systemGray4
    }

    private lazy var linkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "safari"), for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        
        let tap = $0.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let bookData = owner.bookData else { return }
                owner.actionTriggers.accept(.presentSafari(bookData.url))
            })
    }

    private lazy var imageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.textAlignment = .center
    }

    let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }

    private let isbn13Label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }

    private let priceLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Dependency Injection

    func setupDI(action: PublishRelay<NewBooksTriggerType>) {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Helpers
    
    func setupRequest(with newBooks: Book) {
        bookData = newBooks
        guard let bookData = bookData else { return }

        imageView.kf.setImage(with: URL(string: bookData.image ?? ""))
        titleLabel.text = newBooks.title
        subtitleLabel.text = newBooks.isEmptySubtitle
        priceLabel.text = newBooks.exchangeRateCurrencyKR
        isbn13Label.text = newBooks.isbn13
    }

    override func setupLayout() {
        contentView.backgroundColor = .clear
        
        infoImageView.layer.cornerRadius = 10
        infoImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoImageView.layer.masksToBounds = true

        infoTitleView.layer.cornerRadius = 10
        infoTitleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        infoTitleView.layer.masksToBounds = true
        
        contentView.addSubviews(views: [infoImageView, infoTitleView])
        infoImageView.addSubviews(views: [imageView, linkButton])

        infoImageView.snp.makeConstraints {
            $0.height.equalTo(150)
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.35)
            $0.top.bottom.equalToSuperview().inset(22)
        }

        linkButton.snp.makeConstraints {
            $0.width.height.equalTo(32)
            $0.top.trailing.equalToSuperview().inset(10)
        }

        infoTitleView.snp.makeConstraints {
            $0.top.equalTo(infoImageView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-10)
        }

        infoTitleView.addSubviews(views: [titleLabel, subtitleLabel, isbn13Label, priceLabel])
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        isbn13Label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        priceLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(isbn13Label.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
