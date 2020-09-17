//
//  UnsplashApiManager.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift

protocol UnsplashApiManagerType {
    func fetchRandomPhotos(page: Int) -> Observable<NetworkResult<[ImageDetails]>>
    func fetchSearchedPhotos(page: Int, keyword: String) -> Observable<NetworkResult<SearchedImageDetails>>
}

class UnsplashApiManager: UnsplashApiManagerType {
    private let networkManager: NetworkManager
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchRandomPhotos(page: Int) -> Observable<NetworkResult<[ImageDetails]>> {
        let fetchingStream = Observable.just(NetworkResult<[ImageDetails]>.fetching)
        let responseStream: Observable<NetworkResult<[ImageDetails]>> = networkManager.makeRequest(
            isSecureCall: true,
            endPoint: "/photos?page=\(page)"
        )
        return Observable
            .concat(fetchingStream, responseStream)
            .subscribeOn(TaskScheduler.backgroundScheduler)
            .observeOn(TaskScheduler.mainScheduler)
    }
    
    func fetchSearchedPhotos(page: Int, keyword: String) -> Observable<NetworkResult<SearchedImageDetails>> {
        let fetchingStream = Observable.just(NetworkResult<SearchedImageDetails>.fetching)
        let responseStream: Observable<NetworkResult<SearchedImageDetails>> = networkManager.makeRequest(
            isSecureCall: true,
            endPoint: "/search/photos?page=\(page)&query=\(keyword)"
        )
        return Observable
            .concat(fetchingStream, responseStream)
            .subscribeOn(TaskScheduler.backgroundScheduler)
            .observeOn(TaskScheduler.mainScheduler)
    }
}
