//
//  AppFlow.swift
//  OnboardingRxMVVM
//
//  Created by LeeJaeHyeok on 2022/09/18.
//

import RxFlow

class AppFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController().then {
        $0.navigationBar.barTintColor = .systemRed
        $0.setNavigationBarHidden(true, animated: false)
    }
//    let window: UIWindow!
//  
//    init(window: UIWindow) {
//        self.window = window
//    }
//
//    var root: Presentable {
//        return self.window
//    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .dashboardIsRequired:
            print("dashboard")
            return navigationToDashboardScreen()
        default:
            return .none
        }
    }
    
    private func navigationToDashboardScreen() -> FlowContributors {
        let dashboardFlow = MainTabBarFlow()
        
        Flows.use(dashboardFlow, when: .created) { [unowned self] root in
            self.rootViewController.setViewControllers([root], animated: false)
//            self.window.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: dashboardFlow,
                                                 withNextStepper: OneStepper(withSingleStep: AppStep.dashboardIsRequired)))
    }
    
}
