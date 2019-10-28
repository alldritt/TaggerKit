//
//  TKCollectionView.swift
//  TaggerKit
//
//  Created by Filippo Zaffoni on 09/03/2019.
//  Copyright © 2019 Filippo Zaffoni. All rights reserved.
//


import UIKit


protocol TKCollectionViewDelegate {
	func tagIsBeingAdded(viewController: TKCollectionView, name: String?)
	func tagIsBeingRemoved(viewController: TKCollectionView, name: String?)
    func tagsDidChange(viewController: TKCollectionView)
}


public class TKCollectionView: UIViewController {

	
	// MARK: - Customasible properties
	public var customFont				: UIFont?
	public var customSpacing 			: CGFloat?
	public var customCornerRadius 	  	: CGFloat?
	public var customBackgroundColor 	: UIColor?
    public var customTextColor          : UIColor?
	public var action 					: actionType?
	
	
	// MARK: - Class properties
	public var tagsCollectionView	: UICollectionView!
	public var tagCellLayout		: TagCellLayout!
    public var receiver 			: TKCollectionView? {
        didSet {
            updateVisibleTags()
        }
    }
    public var source               : TKCollectionView? {
        didSet {
            updateVisibleTags()
        }
    }
	public var delegate 			: UIViewController?
	
	let defaultFont				= UIFont.boldSystemFont(ofSize: 14)
	let defaultSpacing			= CGFloat(10.0)
	let defaultCornerRadius 	= CGFloat(14.0)
	let defaultBackgroundColor 	= UIColor(red: 1.00, green: 0.80, blue: 0.37, alpha: 1.0)
	let defaultAction 			= actionType.noAction
	
	var oneLineHeight	: CGFloat {
		guard customFont != nil else { return 28 }
		return customFont!.pointSize * 2
	}
	
	var longTagIndex	: Int { return 1 }
    public var tags 	= [String]() {
        didSet {
            updateVisibleTags()
        }
    }
    public var visibleTags = [String]()
	
	// MARK: - Lifecycle methods
    public override func viewDidLoad() {
        super.viewDidLoad()
		setupView()
    }
	
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tagsCollectionView.frame = view.bounds
	}
	
	
	// MARK: - View setup
	private func setupView() {
		tagCellLayout 			= TagCellLayout(alignment: .left, delegate: self)
		tagCellLayout.delegate 	= self
		
		tagsCollectionView 						= UICollectionView(frame: view.bounds, collectionViewLayout: tagCellLayout)
		tagsCollectionView.dataSource 			= self
		tagsCollectionView.delegate 				= self
		tagsCollectionView.alwaysBounceVertical 	= true
		tagsCollectionView.backgroundColor		= UIColor.clear
		tagsCollectionView.register(TKTagCell.self, forCellWithReuseIdentifier: "TKCell")
		
		view.addSubview(tagsCollectionView)
	}
	
	
}

