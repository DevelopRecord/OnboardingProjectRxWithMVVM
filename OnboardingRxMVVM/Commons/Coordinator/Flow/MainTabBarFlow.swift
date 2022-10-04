//
//  MainTabBarFlow.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/19.
//

import RxFlow

class MainTabBarFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UITabBarController()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .dashboardIsRequired:
            return navigateToMainTabBar()
        default: return .none
        }
    }
    
    private func navigateToMainTabBar() -> FlowContributors {
        let newBooksFlow = NewBooksFlow(newBooksViewModel: NewBooksViewModel())
//        let newBooksFlow = NewBooksFlow()
//        let searchBooksFlow = SearchBooksFlow(searchViewModel: SearchViewModel())
        let searchBooksFlow = SearchBooksFlow()

        Flows.use(newBooksFlow, searchBooksFlow, when: .created) { [weak self] (newBooks, searchBooks) in
            guard let self = self else { return }
            
            let newBooksItem = UITabBarItem(title: "New", image: UIImage(systemName: "book"), selectedImage: nil)
            newBooks.tabBarItem = newBooksItem
//            newBooks.viewModel = NewBooksViewModel()
            let searchBooksItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), selectedImage: nil)
            searchBooks.tabBarItem = searchBooksItem
//            searchBooks.viewModel = SearchViewModel()
            
            self.rootViewController.setViewControllers([newBooks, searchBooks], animated: false)
        }
        
        let nextStepper = OneStepper(withSingleStep: AppStep.dashboardIsRequired)
        
        
        return .multiple(flowContributors: [.contribute(withNextPresentable: newBooksFlow,
                                                        withNextStepper: nextStepper),
                                            .contribute(withNextPresentable: searchBooksFlow,
                                                        withNextStepper: nextStepper)])
    }
    
}
