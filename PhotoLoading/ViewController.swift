//
//  ViewController.swift
//  PhotoLoading
//
//  Created by Zheng on 12/30/20.
//

import UIKit
import Photos
import SDWebImage
import SDWebImagePhotosPlugin

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class ViewController: UIViewController {

    var allPhotos: PHFetchResult<PHAsset>? = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    let reuseID = "CellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Supports HTTP URL as well as Photos URL globally
        SDImageLoadersManager.shared.loaders = [SDWebImageDownloader.shared, SDImagePhotosLoader.shared]
        // Replace default manager's loader implementation
        SDWebImageManager.defaultImageLoader = SDImageLoadersManager.shared
        
        let options = PHImageRequestOptions()
        options.sd_targetSize = CGSize(width: 500, height: 500) /// make sure don't load too big
        SDImagePhotosLoader.shared.imageRequestOptions = options
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        PHPhotoLibrary.requestAuthorization { (status) in /// request access
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                DispatchQueue.main.async {
                    self.collectionView.reloadData() /// reload collectionview once done
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CollectionViewCell
        
        let asset = allPhotos![indexPath.item]
        let photosURL = NSURL.sd_URL(with: asset)
        cell.imageView.sd_setImage(with: photosURL as URL?, placeholderImage: nil, options: SDWebImageOptions.fromLoaderOnly, context: [SDWebImageContextOption.storeCacheType: SDImageCacheType.none.rawValue])
        return cell
    }
}
