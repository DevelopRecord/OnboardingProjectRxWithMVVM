//
//  AppStepper.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/19.
//

import RxCocoa
import RxFlow

class AppStepper: Stepper {
    let steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.dashboardIsRequired
    }
}
