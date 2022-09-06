//
//  R.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

struct R {
    /// New Books 에러 메시지
    struct NewBooksTextMessage { }
    /// Search View 에러 메시지
    struct SearchViewTextMessage { }
    /// Detail Book 에러 메시지
    struct DetailBookTextMessage { }
    /// APIService 에러 메시지
    struct APIServiceTextMessage { }
    /// 커스텀 텍스트 컬러
    struct TextColor { }

}

// MARK: - NewBooksController

extension R.NewBooksTextMessage {

    /// New Books
    static let newBooks: String = "New Books"

    /// 책 목록을 불러올 수 없습니다.
    static let failListMessage: String = "책 목록을 불러올 수 없습니다."

    /// 세부 정보를 가져올 수 없습니다.
    static let failDetailMessage: String = "세부 정보를 가져올 수 없습니다."

    /// 끌어서 새로고침
    static let refreshMessage: String = "끌어서 새로고침"
}

// MARK: - SearchViewController

extension R.SearchViewTextMessage {

    /// Search Books
    static let searchBooks: String = "Search Books"

    /// 책 목록을 불러올 수 없습니다.
    static let failListMessage: String = "책 목록을 불러올 수 없습니다."

    /// 세부 정보를 가져올 수 없습니다.
    static let failDetailMessage: String = "세부 정보를 가져올 수 없습니다."

    /// 검색 결과가 없습니다.
    static let noSearchRequestMessage: String = "검색 결과가 없습니다."

    /// 검색어를 입력해보세요.
    static let enterSearchQuery: String = "검색어를 입력해보세요."
    
    /// 마지막 페이지입니다.
    static let finalPage: String = "마지막 페이지입니다."
}

// MARK: - DetailBookController

extension R.DetailBookTextMessage {

    /// Detail Book
    static let detailBooks: String = "Detail Book"

    /// 세부 정보를 가져올 수 없습니다.
    static let failDetailMessage: String = "세부 정보를 가져올 수 없습니다."

    /// 메모를 입력해보세요.
    static let enterMemo: String = "메모를 입력해보세요."
}

// MARK: - APIService

extension R.APIServiceTextMessage {

    /// URL 주소 형식이 맞지 않습니다.
    static let badUrl: String = "URL 주소 형식이 맞지 않습니다."
    
    /// 네트워크 요청 실패
    static let error404: String = "결과가 없습니다.(404)"
    
    /// 데이터를 디코딩 중 에러가 발생했습니다.
    static let decodeError: String = "데이터를 디코딩 중 에러가 발생했습니다."

    /// 책 목록을 불러올 수 없습니다.
    static let failListMessage: String = "책 목록을 불러올 수 없습니다."

    /// 검색 결과가 없습니다.
    static let noSearchRequestMessage: String = "검색 결과가 없습니다."

    /// 세부 정보를 가져올 수 없습니다.
    static let failDetailMessage: String = "세부 정보를 가져올 수 없습니다."

    /// 데이터를 가져 오던 중 에러가 발생했습니다.
    static let errorDataMessage: String = "데이터를 가져 오던 중 에러가 발생했습니다."

}

extension R.TextColor {

    /// black 밝기 50%
    static let blackOpacity50: UIColor = #colorLiteral(red: 0.2368482351, green: 0.2510848343, blue: 0.2683829367, alpha: 0.5)
}
