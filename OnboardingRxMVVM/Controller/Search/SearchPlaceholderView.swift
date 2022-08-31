//
//  SearchPlaceholderView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

class SearchPlaceholderView: UIBaseView {

    // MARK: - Properties

    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "magnifyingglass")?.withTintColor(.systemBlue)
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel = UILabel().then {
        $0.text = "관심있는 책 제목을 검색해 보세요."
        $0.textColor = .systemBlue
        $0.font = UIFont.boldSystemFont(ofSize: 15)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [imageView, titleLabel]).then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setupLayout() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
            $0.height.equalTo(88)
            $0.center.equalToSuperview()
        }
    }
}
