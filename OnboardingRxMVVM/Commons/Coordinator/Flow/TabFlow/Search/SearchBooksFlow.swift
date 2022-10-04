//
//  SearchBooksFlow.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/20.
//

import RxFlow

class SearchBooksFlow: Flow {
    var root: Presentable {
        return UINavigationController()
    }
    
//    let searchViewModel: SearchViewModel
//
//    init(searchViewModel: SearchViewModel) {
//        self.searchViewModel = searchViewModel
//    }
    
    func navigate(to step: Step) -> FlowContributors {
        return .none
    }
    
    
}
