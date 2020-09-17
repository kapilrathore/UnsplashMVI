//
//  State.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation

struct State: Equatable {
    let images: [ImageDetails]
    let page: Int
    let keyword: String
    let isFetching: Bool
    let errorMessage: String
}

extension State {
    static var initial: State {
        .init(
            images: [],
            page: 1,
            keyword: "",
            isFetching: false,
            errorMessage: ""
        )
    }
    
    func copy(
        page: Int? = nil,
        keyword: String? = nil,
        randomImageResult: NetworkResult<[ImageDetails]>? = nil,
        searchedImageResult: NetworkResult<SearchedImageDetails>? = nil
    ) -> State {
        
        let newKeyword = keyword ?? self.keyword
        var newImages = self.images
        var newPage = page ?? self.page
        var newIsFetching = self.isFetching
        var newErrorMessage = self.errorMessage
        
        if let someKeyword = keyword {
            let userAddedKeyword = self.keyword.isEmpty && !someKeyword.isEmpty
            let userRemovedKeyword = !self.keyword.isEmpty && someKeyword.isEmpty
            let userChangedKeyword = !self.keyword.isEmpty && !someKeyword.isEmpty && someKeyword != self.keyword
            
            if userAddedKeyword || userChangedKeyword || userRemovedKeyword {
                newPage = 1
                newImages.removeAll()
            }
        }
        
        if let networkResult = randomImageResult {
            switch networkResult {
                case .fetching:
                    newIsFetching = true
                case .fetchFailed(let error):
                    newIsFetching = false
                    newErrorMessage = error
                case .fetchSuccess(let data):
                    newIsFetching = false
                    newImages.append(contentsOf: data)
            }
        }
        
        if let networkResult = searchedImageResult {
            switch networkResult {
                case .fetching:
                    newIsFetching = true
                case .fetchFailed(let error):
                    newIsFetching = false
                    newErrorMessage = error
                case .fetchSuccess(let data):
                    newIsFetching = false
                    newImages.append(contentsOf: data.results)
            }
        }
        
        return State(
            images: newImages,
            page: newPage,
            keyword: newKeyword,
            isFetching: newIsFetching,
            errorMessage: newErrorMessage
        )
    }
}
