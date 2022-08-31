//
//  Book.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/24.
//

import Foundation

struct BookResponse: Codable { // 이 프로젝트 경우에서는 Decodable로 해도 무방하다고 생각함.
    let error: String?
    let total: String?
    let page: String?
    var books: [Book]?
}

struct Book: Codable {
    let title: String?
    let subtitle: String?
    let isbn13: String?
    let price: String?
    let image: String?
    let url: String?

    /// 환율 변환 및 원화 셋업
    /// .을 기점으로 앞(1300원) 뒤(13원) 기준 잡고 계산
    var exchangeRateCurrencyKR: String {
        var price = self.price
        price?.removeFirst()
        let dotSplit = price?.split(separator: ".").map { Int($0) ?? 0 }
        let exchangeRate = (((dotSplit?[0] ?? 0) * 1300) + (dotSplit?[1] ?? 0 * 13))
        let formatter = NumberFormatter()

        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KR")
        var result = formatter.string(from: NSNumber(value: exchangeRate)) ?? ""
        result = result.replacingOccurrences(of: "₩", with: "₩ ")

        return result == "₩ 0" ? "무료" : result
    }

    /// Subtitle Empty 여부에 따라 변환
    var isEmptySubtitle: String {
        return subtitle?.isEmpty ?? false ? "No Subtitle.." : subtitle ?? ""
    }
}
