//
//  UIViewController+.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

extension UIViewController {

    /// 네비게이션바 설정 함수
    func setupNavigationBar(title: String, isLargeTitle: Bool, searchController: UISearchController? = nil) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = isLargeTitle
        self.navigationItem.searchController = searchController
    }
}
