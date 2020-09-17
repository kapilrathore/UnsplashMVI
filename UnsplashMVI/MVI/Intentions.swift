//
//  Intentions.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation
import RxSwift

struct Intentions {
    let screenLaod: Observable<Void>
    let imageSearch: Observable<String>
    let loadMore: Observable<Void>
    
    init(
        screenLaod: Observable<Void>,
        imageSearch: Observable<String>,
        loadMore: Observable<Void>
    ) {
        self.screenLaod = screenLaod
        self.imageSearch = imageSearch
        self.loadMore = loadMore
    }
}
