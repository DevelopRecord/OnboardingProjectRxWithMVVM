//
//  NewBooksFlow.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/20.
//

import RxFlow

class NewBooksFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    let newBooksViewModel: NewBooksViewModel
    
    init(newBooksViewModel: NewBooksViewModel) {
        self.newBooksViewModel = newBooksViewModel
    }
    
    private let rootViewController = UINavigationController()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .newBooksAreRequired:
            print("최초 진입")
            return navigateToNewBooksScreen()
        case .bookIsPicked:
            print("책 선택")
            return .none
        case .safariViewIsRequired:
            print("사파리")
            return .none
        default:
            return .none
        }
    }
    
    private func navigateToNewBooksScreen() -> FlowContributors {
        let viewController = NewBooksViewController()
        viewController.viewModel = NewBooksViewModel()
        viewController.title = "New Books"

        viewController.navigationController?.navigationBar.prefersLargeTitles = true
        
//        self.rootViewController.setViewControllers([viewController], animated: true)
        self.rootViewController.pushViewController(viewController, animated: true)

        let nextStepper = OneStepper(withSingleStep: AppStep.newBooksAreRequired)
        
        return .one(flowContributor: .contribute(withNextPresentable: viewController,
                                                 withNextStepper: nextStepper))
    }
}
