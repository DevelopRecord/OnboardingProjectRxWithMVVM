//
//  AppStep.swift
//  OnboardingRxMVVM
//
//  Created by LeeJaeHyeok on 2022/09/18.
//

import RxFlow

enum AppStep: Step {
    /// 최초 진입 대시보드
    case dashboardIsRequired
    /// 최초 진입 뷰
    case newBooksAreRequired
    /// 책 선택
    case bookIsPicked
    /// 사파리 진입
    case safariViewIsRequired
    /// 세부화면 진입 에러
    case errorIsOccured
}
