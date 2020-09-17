//
//  ModelTests.swift
//  UnsplashMVITests
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import UnsplashMVI

class ModelTests: XCTestCase {
    private let mockApiManager = MockApiManager()
    private let model = Model()
    
    private var disposeBag: DisposeBag!
    private var screenLaodEvents: PublishRelay<Void>!
    private var imageSearchEvents: PublishRelay<String>!
    private var loadMoreEvents: PublishRelay<Void>!
    private var statesRelay: PublishRelay<State>!
    private var observer: TestableObserver<State>!
    
    override func setUp() {
        disposeBag = DisposeBag()
        screenLaodEvents = PublishRelay<Void>()
        imageSearchEvents = PublishRelay<String>()
        loadMoreEvents = PublishRelay<Void>()
        statesRelay = PublishRelay<State>()
        observer = TestScheduler(initialClock: 0)
            .createObserver(State.self)
        
        let intentions = Intentions(
            screenLaod: self.screenLaodEvents.asObservable(),
            imageSearch: self.imageSearchEvents.asObservable(),
            loadMore: self.loadMoreEvents.asObservable()
        )
        
        model.bind(intentions: intentions, states: statesRelay.asObservable(), apiManager: mockApiManager)
            .do(onNext: { self.statesRelay.accept($0) })
            .subscribe(observer)
            .disposed(by: disposeBag)
    }
    
    override func tearDown() {
        disposeBag = nil
        screenLaodEvents = nil
        imageSearchEvents = nil
        loadMoreEvents = nil
        statesRelay = nil
    }
    
    // Test Suit
    func test_ScreenLoad_ApiFails() {
        // Given
        mockApiManager.fetchRandomPhotosResponse = .just(.fetchFailed(error: "Random Error"))
        // When
        screenLaodEvents.accept(())
        // Then
        let expectedStates = [
            Recorded.next(0, State.initial.copy(randomImageResult: .fetching)),
            Recorded.next(0, State.initial.copy(randomImageResult: .fetchFailed(error: "Random Error")))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_ScreenLoad_ApiSuccess() {
        // Given
        mockApiManager.fetchRandomPhotosResponse = .just(.fetchSuccess(data: MockData.imagesData))
        // When
        screenLaodEvents.accept(())
        // Then
        let expectedStates = [
            Recorded.next(0, State.initial.copy(randomImageResult: .fetching)),
            Recorded.next(0, State.initial.copy(randomImageResult: .fetchSuccess(data: MockData.imagesData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_ImageSearch_ApiFails() {
        // Given
        let keyword = "Test"
        mockApiManager.fetchSearchedPhotosResponse = .just(.fetchFailed(error: "Random Error"))
        statesRelay.accept(State.initial)
        // When
        imageSearchEvents.accept(keyword)
        // Then
        let expectedStates = [
            Recorded.next(0, State.initial.copy(keyword: keyword, searchedImageResult: .fetching)),
            Recorded.next(0, State.initial.copy(keyword: keyword, searchedImageResult: .fetchFailed(error: "Random Error")))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_ImageSearch_ApiSucceeds() {
        // Given
        let keyword = "Test"
        mockApiManager.fetchSearchedPhotosResponse = .just(.fetchSuccess(data: MockData.searchedData))
        statesRelay.accept(State.initial)
        // When
        imageSearchEvents.accept(keyword)
        // Then
        let expectedStates = [
            Recorded.next(0, State.initial.copy(keyword: keyword, searchedImageResult: .fetching)),
            Recorded.next(0, State.initial.copy(keyword: keyword, searchedImageResult: .fetchSuccess(data: MockData.searchedData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_LoadMore_NoKeyword_ApiSucceeds() {
        // Given
        mockApiManager.fetchRandomPhotosResponse = .just(.fetchSuccess(data: MockData.imagesData))
        statesRelay.accept(State.initial)
        // When
        loadMoreEvents.accept(())
        // Then
        let expectedStates = [
            Recorded.next(0, State.initial.copy(page: 2, randomImageResult: .fetching)),
            Recorded.next(0, State.initial.copy(page: 2, randomImageResult: .fetchSuccess(data: MockData.imagesData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_LoadMore_SomeKeyword_ApiSucceeds() {
        // Given
        mockApiManager.fetchSearchedPhotosResponse = .just(.fetchSuccess(data: MockData.searchedData))
        let lastState = State.initial.copy(keyword: "Some")
        statesRelay.accept(lastState)
        // When
        loadMoreEvents.accept(())
        // Then
        let expectedStates = [
            Recorded.next(0, lastState.copy(page: 2, searchedImageResult: .fetching)),
            Recorded.next(0, lastState.copy(page: 2, searchedImageResult: .fetchSuccess(data: MockData.searchedData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_ImageSearch_KeywordRemoved_ApiSucceeds() {
        // Given
        mockApiManager.fetchRandomPhotosResponse = .just(.fetchSuccess(data: MockData.imagesData))
        let lastState = State.initial.copy(keyword: "Some")
        statesRelay.accept(lastState)
        // When
        imageSearchEvents.accept("")
        // Then
        let expectedStates = [
            Recorded.next(0, lastState.copy(page: 2, keyword: "", randomImageResult: .fetching)),
            Recorded.next(0, lastState.copy(page: 2, keyword: "", randomImageResult: .fetchSuccess(data: MockData.imagesData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
    
    func test_ImageSearch_KeywordChanged_ApiSucceeds() {
        // Given
        mockApiManager.fetchSearchedPhotosResponse = .just(.fetchSuccess(data: MockData.searchedData))
        let lastState = State.initial.copy(keyword: "Some")
        statesRelay.accept(lastState)
        // When
        imageSearchEvents.accept("New")
        // Then
        let expectedStates = [
            Recorded.next(0, lastState.copy(page: 2, keyword: "New", searchedImageResult: .fetching)),
            Recorded.next(0, lastState.copy(page: 2, keyword: "New", searchedImageResult: .fetchSuccess(data: MockData.searchedData)))
        ]
        
        XCTAssertEqual(observer.events, expectedStates)
    }
}
