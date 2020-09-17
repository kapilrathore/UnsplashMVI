//
//  ImageDownloader.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import RxSwift

class ImageDownloader {
    private init() {}
    static let shared = ImageDownloader()
    
    private let cache = NSCache<NSString, NSData>()
    
    func downloadImage(for imageId: String, from imageUrl: URL) -> Observable<(String, Data)> {
        
        if let cachedData = cache.object(forKey: NSString(string: imageId)) {
            return .just((imageId, cachedData as Data))
        }
        
        let request = URLRequest(url: imageUrl)
        
        return URLSession.shared.rx.data(request: request)
            .map { imageData -> (String, Data) in
                self.cache.setObject(imageData as NSData, forKey: NSString(string: imageId))
                return (imageId, imageData)
            }
            .subscribeOn(TaskScheduler.backgroundScheduler)
            .observeOn(TaskScheduler.mainScheduler)
    }
}
