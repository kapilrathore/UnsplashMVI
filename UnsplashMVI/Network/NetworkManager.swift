//
//  NetworkManager.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NetworkManager {
    
    // Singleton
    private init() {}
    static let shared = NetworkManager()
    
    // Private Declairations
    private let authKey = "Rlfmtvk2rdWd8AYV2yu_4gIhkH_P_t46lNx3p146-O8"
    private let baseUrlString = "https://api.unsplash.com"
    private let session = URLSession(configuration: .default)
    
    // Generic Request Function
    func makeRequest<T: Decodable>(
        isSecureCall: Bool = false,
        endPoint: String
    ) -> Observable<NetworkResult<T>> {
        
        let secureUrlString = isSecureCall ? "&client_id=\(authKey)" : ""
        let requestUrlString = baseUrlString + endPoint + secureUrlString
        guard let requestUrl = URL(string: requestUrlString) else { return .empty() }
        
        let request = URLRequest(url: requestUrl)
        return session.rx.data(request: request)
            .map { responseData -> NetworkResult<T> in
                guard let resposneObject = try? JSONDecoder().decode(T.self, from: responseData)
                    else { return .fetchFailed(error: "Error decoding data") }
                return .fetchSuccess(data: resposneObject)
            }
            .catchError { error -> Observable<NetworkResult<T>> in
                return .just(.fetchFailed(error: error.localizedDescription))
            }
    }
}
