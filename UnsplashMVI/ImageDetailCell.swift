//
//  ImageDetailCell.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 17/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import UIKit
import RxSwift

class ImageDetailCell: UITableViewCell {
    static let identifier = "ImageDetailCell"
    
    @IBOutlet private weak var iamgeView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    func bindData(data: ImageDetails) {
        self.titleLabel.text = data.title
        
        if let imageUrl = data.imageUrl {
            ImageDownloader.shared.downloadImage(for: data.id, from: imageUrl)
                .subscribe(onNext: { [weak self] imageId, imageData in
                    if data.id == imageId {
                        self?.iamgeView.image = UIImage(data: imageData)
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
