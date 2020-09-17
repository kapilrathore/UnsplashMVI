//
//  ImageDetails.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import Foundation

struct SearchedImageDetails: Equatable, Decodable {
    let results: [ImageDetails]
}

struct ImageDetails: Equatable {
    let id: String
    private let description: String?
    private let altDescription: String?
    let imageUrl: URL?
    
    var title: String {
        description ?? altDescription ?? "Some Image"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case altDescription = "alt_description"
        case urls = "urls"
        
        enum ImageUrlKeys: String, CodingKey {
            case imageUrl = "thumb"
        }
    }
    
    init(
        id: String,
        description: String?,
        altDescription: String?,
        imageUrl: URL?
    ) {
        self.id = id
        self.description = description
        self.altDescription = altDescription
        self.imageUrl = imageUrl
    }
}

extension ImageDetails: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        description = try container.decode(String?.self, forKey: .description)
        altDescription = try container.decode(String?.self, forKey: .altDescription)
        
        let imageUrlContainer = try container.nestedContainer(keyedBy: CodingKeys.ImageUrlKeys.self, forKey: .urls)
        let imageUrlString = try imageUrlContainer.decode(String.self, forKey: .imageUrl)
        imageUrl = URL(string: imageUrlString)
    }
}
