//
//  YPLibrary+LibraryChange.swift
//  YPImagePicker
//
//  Created by Sacha DSO on 26/01/2018.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit
import Photos

extension YPLibraryVC: PHPhotoLibraryChangeObserver {
    func registerForLibraryChanges() {
        PHPhotoLibrary.shared().register(self)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            let fetchResult = self.mediaManager.fetchResult!
            let collectionChanges = changeInstance.changeDetails(for: fetchResult)
            if collectionChanges != nil {
                self.mediaManager.fetchResult = collectionChanges!.fetchResultAfterChanges
                let collectionView = self.v.collectionView!
                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
                    collectionView.reloadData()
                } else {
                    collectionView.performBatchUpdates({
                        let removedIndexes = collectionChanges!.removedIndexes
                        if (removedIndexes?.count ?? 0) != 0 {
                            collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                    }, completion: { finished in
                        if finished {
                            let changedIndexes = collectionChanges!.changedIndexes
                            if (changedIndexes?.count ?? 0) != 0 {
                                collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                            }
                        }
                    })
                }
                self.mediaManager.resetCachedAssets()
            }
            if self.mediaManager.hasResultItems {
                self.changeAsset(self.mediaManager.fetchResult[0])
                self.v.collectionView.reloadData()
                self.v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                                 animated: false,
                                                 scrollPosition: UICollectionView.ScrollPosition())
                if !self.multipleSelectionEnabled && YPConfig.library.preSelectItemOnMultipleSelection {
                    self.addToSelection(indexPath: IndexPath(row: 0, section: 0))
                }
                self.v.assetViewContainer.multipleSelectionButton.isHidden = false
            } else {
                self.delegate?.noPhotosForOptions()
                self.v.assetViewContainer.multipleSelectionButton.isHidden = true
            }
        }
    }
}
