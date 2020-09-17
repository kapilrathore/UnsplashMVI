//
//  Model.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift

class Model {
    typealias StatesStream = Observable<State>
    
    func bind(
        intentions: Intentions,
        states: StatesStream,
        apiManager: UnsplashApiManagerType
    ) -> StatesStream {
        
        let screenLaodStates = screenLaodUsecae(intentions, states, apiManager)
        let imageSearchStates = imageSearchUsecase(intentions, states, apiManager)
        let loadMoreStates = loadMoreUsecase(intentions, states, apiManager)
        
        return Observable.merge(
            screenLaodStates,
            imageSearchStates,
            loadMoreStates
        )
    }
    
    private func screenLaodUsecae(
        _ intentions: Intentions,
        _ states: StatesStream,
        _ apiManager: UnsplashApiManagerType
    ) -> StatesStream {
        intentions.screenLaod
            .flatMapLatest { _ -> StatesStream in
                apiManager.fetchRandomPhotos(page: 1)
                    .map({ State.initial.copy(randomImageResult: $0) })
            }
    }
    
    private func imageSearchUsecase(
        _ intentions: Intentions,
        _ states: StatesStream,
        _ apiManager: UnsplashApiManagerType
    ) -> StatesStream {
        intentions.imageSearch
            .withLatestFrom(states) { ($0, $1) }
            .flatMap({ (keyword, state) -> StatesStream in
                
                if keyword.isEmpty {
                    return apiManager.fetchRandomPhotos(page: 1)
                        .map({ state.copy(keyword: keyword, randomImageResult: $0) })
                }

                return apiManager.fetchSearchedPhotos(page: state.page, keyword: keyword)
                    .map({ state.copy(keyword: keyword, searchedImageResult: $0) })
            })
    }
    
    private func loadMoreUsecase(
        _ intentions: Intentions,
        _ states: StatesStream,
        _ apiManager: UnsplashApiManagerType
    ) -> StatesStream {
        intentions.loadMore
            .withLatestFrom(states)
            .flatMap({ state -> StatesStream in
                let newPageCount = state.page + 1
                
                if state.keyword.isEmpty {
                    return apiManager.fetchRandomPhotos(page: newPageCount)
                        .map({ state.copy(page: newPageCount, randomImageResult: $0) })
                }
                
                return apiManager.fetchSearchedPhotos(page: newPageCount, keyword: state.keyword)
                    .map({ state.copy(page: newPageCount, searchedImageResult: $0) })
            })
    }
}
