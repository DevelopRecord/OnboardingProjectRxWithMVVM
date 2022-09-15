//
//  APIService.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import Foundation

import Alamofire
import RxSwift

/// 앱과 서버간의 통신을 하며 마주칠 수 있는 다양한 에러
enum NetworkError: Error {
    /// 잘못된 URL
    case badUrl
    /// 데이터 없음
    case noData(message: String)
    /// 알수없는 에러
    case unknownErr(message: String)
    /// 404 에러
    case error404
    /// 데이터와 에러 반환
    case errorData
    /// 디코딩 에러
    case decodeError(message: String)
    /// 에러코드
    case errorCode(code: Int)
}

/// 각 기능에 대한 URL 주소
enum URLAddress: String {
    /// 기본이 되는 URL
    case baseUrl = "https://api.itbook.store/1.0/"
    /// 모든 책 URL
    case newUrl = "new"
    /// /// 검색 URL
    case searchUrl = "search/"
    /// 책 세부정보 URL
    case detailUrl = "books/"
}

protocol FetchRequestProtocol {
    /// 모든 책의 정보
    func fetchNewBooks() -> Single<BookResponse>
    /// 검색된 책의 정보
    func fetchSearchBooks(query: String, page: Int) -> Single<BookResponse>
    /// 선택한 책의 정보
    func fetchDetailBook(isbn13: String) -> Single<Book>
}

class APIService: UIAnimatable, FetchRequestProtocol {

    /// APIService 싱글톤
    static let shared = APIService()

    func fetchNewBooks() -> Single<BookResponse> {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.newUrl.rawValue
        guard let url = URL(string: urlString) else {
            return Observable.error(NSError(domain: "Non URL ..", code: 404, userInfo: nil)).asSingle()
        }
        
        return self.fetchRequest(url: url)
    }

    func fetchSearchBooks(query: String, page: Int) -> Single<BookResponse> {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.searchUrl.rawValue + "\(query)/" + "\(page)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrlString) else {
            return Observable.error(NSError(domain: "Non URL ..", code: 404, userInfo: nil)).asSingle()
        }
        
        return self.fetchRequest(url: url)
    }

    func fetchDetailBook(isbn13: String) -> Single<Book> {
        let urlString = URLAddress.baseUrl.rawValue + URLAddress.detailUrl.rawValue + isbn13
        guard let url = URL(string: urlString) else {
            return Observable.error(NSError(domain: "Non URL ..", code: 404, userInfo: nil)).asSingle()
        }
        
        return self.fetchRequest(url: url)
    }

    /// 같은 로직의 네트워킹 코드 리팩토링 함수
    private func fetchRequest<T: Decodable>(url: URL) -> Single<T> {
        showLoadingAnimation()
        return Single<T>.create { [weak self] single in
            let headers: HTTPHeaders = ["Content-Type": "application/json"]
            let request = AF.request(url, method: .get, encoding: JSONEncoding.prettyPrinted, headers: headers).responseData { [weak self] response in
                guard let `self` = self else { return }
                switch response.result {
                case .success(let jsonData):
                    /// jsonData가 잘 넘어올 수도 있겠으나 디코딩 과정에서 에러 발생 가능성이 존재하여 do-catch로 에러대응
                    do {
                        let bookDatas = try JSONDecoder().decode(T.self, from: jsonData)
                        single(.success(bookDatas))
                    } catch let error {
                        single(.failure(NetworkError.decodeError(message: "\(error)")))
                    }
                case .failure(let error):
                    single(.failure(NetworkError.noData(message: "\(error)")))
                }
                self.hideLoadingAnimation()
            }

            return Disposables.create() {
                /// Disposables로 객체 해제하고 AF 요청작업 캔슬
                request.cancel()
            }
        }
        .timeout(.seconds(3), scheduler: MainScheduler.instance)
        .do(onError: { error in
            if case.timeout = error as? RxError {
                Toast.shared.showToast("요청시간이 초과하였습니다.")
                print(error)
            }
        })
    }
}
