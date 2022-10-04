//
//  SceneDelegate.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/23.
//

import UIKit
import RxFlow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
//    let coordinator = FlowCoordinator()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = MainTabbarController()
        window?.makeKeyAndVisible()
        
//        let appFlow = AppFlow()
//        guard let window = window else { return }
//        let appFlow = AppFlow(window: window!)
//        let appStepper = OneStepper(withSingleStep: AppStep.dashboardIsRequired)

//        self.coordinator.coordinate(flow: appFlow, with: AppStepper())
//        Flows.use(appFlow, when: .created) { root in
//            self.window?.rootViewController = root
//            self.window?.makeKeyAndVisible()
//        }
    }
}

