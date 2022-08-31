//
//  ViewModelType.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/26.
//

import Foundation

protocol ViewModelType {
    /// View에서 발생할 Input 이벤트(Stream)들
    associatedtype Input
    /// View에 반영시킬 Output Stream들
    associatedtype Output
    /// 뷰의 Input을 받아 Output으로 변형하는 메서드
    func transform(req: Input) -> Output
}
