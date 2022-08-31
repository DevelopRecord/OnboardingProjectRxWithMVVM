//
//  DetailBookViewModel.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DetailBookViewModel: ViewModelType {
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = DetailBookViewModel
    
    struct Input {
    }
    
    struct Output {
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        return Output()
    }
}
