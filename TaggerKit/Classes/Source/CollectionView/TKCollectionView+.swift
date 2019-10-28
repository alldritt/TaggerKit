//
//  TKCollectionView+.swift
//  TaggerKit
//
//  Created by Filippo Zaffoni on 11/03/2019.
//  Copyright © 2019 Filippo Zaffoni. All rights reserved.
//


import UIKit


// MARK: - UICollectionViewDataSource
extension TKCollectionView: UICollectionViewDataSource {
	
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return visibleTags.count
	}
	
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TKCell", for: indexPath) as! TKTagCell
		
		cell.tagName 		= visibleTags[indexPath.item]
		cell.tagAction		= action ?? defaultAction
		cell.cornerRadius 	= customCornerRadius ?? defaultCornerRadius
		cell.font			= customFont ?? defaultFont
        if receiver == nil {
            cell.color          = customBackgroundColor ?? defaultBackgroundColor
            cell.borderWidth    = 0
            if #available(iOS 13.0, *) {
                cell.nameLabel.textColor                                 = customTextColor ?? UIColor.label
            }
            else {
                cell.nameLabel.textColor                                 = customTextColor ?? UIColor.white
            }
        }
        else {
            cell.borderWidth    = 2
            cell.borderColor    = customBackgroundColor ?? defaultBackgroundColor
            cell.color          = (customBackgroundColor ?? defaultBackgroundColor).withAlphaComponent(0.2)
        }
		cell.delegate		= self
		
		return cell
	}
	
	
	public func addNewTag(named: String?) {
		guard let receiver = receiver else { return }
		if let tagToAdd = named {
			guard tagToAdd.count > 0 else { return }
			if receiver.tags.contains(tagToAdd) {
				return
			} else {
                let insertIndex = receiver.tags.count
				receiver.tags.insert(tagToAdd, at: insertIndex)

                receiver.tagsCollectionView.performBatchUpdates({
					receiver.tagsCollectionView.insertItems(at: [IndexPath(item: insertIndex, section: 0)])
				}, completion: { _ in
                    receiver.delegate?.tagsDidChange(viewController: receiver)
                })
                
                if let deleteIndex = visibleTags.firstIndex(of: tagToAdd) {
                    visibleTags.remove(at: deleteIndex)
                    tagsCollectionView.performBatchUpdates({
                        self.tagsCollectionView.deleteItems(at: [IndexPath(row: deleteIndex, section: 0)])
                    }, completion: { _ in
                        self.delegate?.tagsDidChange(viewController: self)
                    })
                }
			}
		}
	}
	
	
	public func removeOldTag(named: String?) {
		if let tagToRemove = named {
			if tags.contains(tagToRemove) {
				let index = tags.firstIndex(of: tagToRemove)
				tags.remove(at: index!)
				let indexPath = IndexPath(item: index!, section: 0)
				tagsCollectionView.performBatchUpdates({
					self.tagsCollectionView?.deleteItems(at: [indexPath])
				}, completion: { _ in
                    self.delegate?.tagsDidChange(viewController: self)
                })
                
                if let source = source {
                    let insertIndex = source.visibleTags.insertionIndexOf(elem: tagToRemove, isOrderedBefore: { s1, s2 in
                        return s1.caseInsensitiveCompare(s2) == .orderedAscending
                    })
                    source.visibleTags.insert(tagToRemove, at: insertIndex)
                    source.tagsCollectionView.performBatchUpdates({
                        source.tagsCollectionView.insertItems(at: [IndexPath(row: insertIndex, section: 0)])
                    }, completion: { _ in
                        source.delegate?.tagsDidChange(viewController: source)
                    })
                }
			}
		}
	}
	
    public func updateVisibleTags() {
        if let receiver = receiver {
            visibleTags = Array<String>(Set<String>(tags).subtracting(receiver.tags)).sorted(by: { s1, s2 in
                return s1.caseInsensitiveCompare(s2) == .orderedAscending
            })
        }
        else {
            visibleTags = tags
        }
    }

}


// MARK: - UICollectionViewDelegate
extension TKCollectionView: UICollectionViewDelegate {
	
	public  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
}


// MARK: - TagCellLayoutDelegate
extension TKCollectionView: TagCellLayoutDelegate {
	
	public func tagCellLayoutInteritemHorizontalSpacing(layout: TagCellLayout) -> CGFloat {
		return customSpacing ?? defaultSpacing
	}
	
	
	public func tagCellLayoutInteritemVerticalSpacing(layout: TagCellLayout) -> CGFloat {
		return customSpacing ?? defaultSpacing
	}
	
	
	public func tagCellLayoutTagSize(layout: TagCellLayout, atIndex index: Int) -> CGSize {
		let tagName 	= visibleTags[index]
		let font 		= customFont ?? defaultFont
		let cellSize 	= textSize(text: tagName, font: font, collectionView: tagsCollectionView)
		
		return cellSize
	}
	
	
	public func textSize(text: String, font: UIFont, collectionView: UICollectionView) -> CGSize {
		var viewBounds 			= collectionView.bounds
		viewBounds.size.height 	= 9999.0
		let label 				= UILabel()
		label.numberOfLines 	= 0
		label.text 				= text
		label.font 				= font
		var s 					= label.sizeThatFits(viewBounds.size)
		s.height 				= oneLineHeight
		
		if action == .addTag || action == .removeTag {
			s.width += 50
		} else if action == nil || action == .noAction {
			s.width += 30
		}
		
		return s
	}
}


// MARK: - TagCellDelegate (action delegate)
extension TKCollectionView: TagCellDelegate {
	
    
	public func didTapButton(name: String?, action: actionType) {
		
		switch action {
		case .addTag:
			addNewTag(named: name)
            delegate?.tagIsBeingAdded(viewController: self, name: name)
		case .removeTag:
			removeOldTag(named: name)
			delegate?.tagIsBeingRemoved(viewController: self, name: name)
		case .noAction:
			break
		}
		
	}
	
}


extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}
