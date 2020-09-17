//
//  Renderer.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation

protocol Renderer {
    func render(state: State)
    
    func showLoader(_ show: Bool)
    func showError(_ error: String)
    func showImages(_ images: [ImageDetails])
}

extension Renderer {
    func render(state: State) {
        showLoader(state.isFetching)
        showImages(state.images)
        
        if !state.errorMessage.isEmpty {
            showError(state.errorMessage)
        }
    }
}
