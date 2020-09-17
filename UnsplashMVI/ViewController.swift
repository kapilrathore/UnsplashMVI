//
//  ViewController.swift
//  UnsplashMVI
//
//  Created by Kapil Rathore on 16/09/20.
//  Copyright © 2020 Kapil Rathore. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet private weak var imagesTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    private let disposeBag = DisposeBag()
    private let unsplashApiManager = UnsplashApiManager(networkManager: NetworkManager.shared)
    
    private let imagesToShow = BehaviorRelay<[ImageDetails]>(value: [])
    private let screenLaodEvents = PublishRelay<Void>()
    private let imageSearchEvents = PublishRelay<String>()
    private let loadMoreEvents = PublishRelay<Void>()
    private lazy var intentions = Intentions(
        screenLaod: self.screenLaodEvents.asObservable(),
        imageSearch: self.imageSearchEvents.asObservable(),
        loadMore: self.loadMoreEvents.asObservable()
    )
    private let model = Model()
    private let statesRelay = PublishRelay<State>()
    
    private var dataIsPresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupMVIBinding()
        self.setupTableViewBinding()
        self.setupSearchBarBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        screenLaodEvents.accept(())
    }
    
    private func setupMVIBinding() {
        model
            .bind(
                intentions: intentions, states:
                statesRelay.asObservable(),
                apiManager: unsplashApiManager
            )
            .subscribe(onNext: { [weak self] state in
                print(state)
                self?.statesRelay.accept(state)
                self?.render(state: state)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableViewBinding() {
        imagesToShow.asObservable()
            .bind(to: imagesTableView.rx.items(cellIdentifier: ImageDetailCell.identifier)) {
                (index, item: ImageDetails, cell: ImageDetailCell) in
                cell.bindData(data: item)
            }
            .disposed(by: disposeBag)
        
        imagesTableView.rx.contentOffset
            .subscribe(onNext: { [weak self] offset in
                guard let self = self else { return }
                guard self.dataIsPresent else { return }
                
                let someDiff = self.imagesTableView.contentSize.height - self.imagesTableView.frame.size.height
                if offset.y >= someDiff {
                    self.loadMoreEvents.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupSearchBarBinding() {
        searchBar.rx.text.asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.imageSearchEvents.accept(text ?? "")
            })
            .disposed(by: disposeBag)
    }
}

extension ViewController: Renderer {
    func showLoader(_ show: Bool) {
        self.loadingView.isHidden = !show
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Oops", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showImages(_ images: [ImageDetails]) {
        self.dataIsPresent = !images.isEmpty
        self.imagesToShow.accept(images)
    }
}
