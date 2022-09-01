//
//  UIBaseViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class UIBaseViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setupLayout() {
        view.backgroundColor = .systemBackground
    }
}
