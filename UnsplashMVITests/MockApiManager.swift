//
//  MockApiManager.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift
@testable import UnsplashMVI

class MockApiManager: UnsplashApiManagerType {
    
    var fetchRandomPhotosResponse: Observable<NetworkResult<[ImageDetails]>>!
    func fetchRandomPhotos(page: Int) -> Observable<NetworkResult<[ImageDetails]>> {
        return Observable.concat(.just(.fetching), fetchRandomPhotosResponse)
    }
    
    var fetchSearchedPhotosResponse: Observable<NetworkResult<SearchedImageDetails>>!
    func fetchSearchedPhotos(page: Int, keyword: String) -> Observable<NetworkResult<SearchedImageDetails>> {
        return Observable.concat(.just(.fetching), fetchSearchedPhotosResponse)
    }
}

struct MockData {
    static var imagesData: [ImageDetails] {
        [
            ImageDetails(id: "101", description: nil, altDescription: nil, imageUrl: nil),
            ImageDetails(id: "102", description: nil, altDescription: nil, imageUrl: nil),
            ImageDetails(id: "103", description: nil, altDescription: nil, imageUrl: nil)
        ]
    }
    
    static var searchedData: SearchedImageDetails {
        SearchedImageDetails(results: MockData.imagesData)
    }
}
