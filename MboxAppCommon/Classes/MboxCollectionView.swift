//  MboxCollectionView.swift
//  CollectionViewDemo
//
//  Created by Memebox on 2019/1/21.
//  Copyright © 2019 Justin. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout

public protocol MboxListItemProtocol {
    var identifa: String { get }
    var newItem: AnyObject { get }
    var registClass: AnyClass { get }
    func fillModel(item: AnyObject)
}

public protocol MboxCollectionViewItemProtocol: MboxListItemProtocol { }

public protocol MboxListItemDefaultProtocol: MboxListItemProtocol {
    associatedtype ItemType: UIView
    func fillModel(reusableView: ItemType)
}

public extension MboxListItemDefaultProtocol {
    var identifa: String { return  NSStringFromClass(ItemType.self)}
    var newItem: AnyObject { return ItemType() }
    var registClass: AnyClass { return ItemType.self }
    func fillModel(item: AnyObject) {
        if let reusableView = item as? ItemType {
            fillModel(reusableView: reusableView)
        }
    }
}

public protocol MboxCollectionViewItemDefaultProtocol: MboxCollectionViewItemProtocol, MboxListItemDefaultProtocol { }

public class MboxCollectionViewViewModel: NSObject {

    public var identifier = ""

    public var sectionInset = UIEdgeInsets.zero

    public var minimumColumnSpacing = 0.0

    public var minimumInteritemSpacing = 0.0

    public var columnCount: Int?

    public var header: MboxCollectionViewItemProtocol?

    public var items: [MboxCollectionViewItemProtocol]?

    public var footer: MboxCollectionViewItemProtocol?
}

/// 只有部分可用。具体更新参看 class MboxCollectionView
public protocol MboxCollectionViewDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public extension MboxCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    func scrollViewDidScroll(_ scrollView: UIScrollView) { }
}

/// 携带格式化好数据源瀑布流
public class MboxCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    public weak var allDelegate: MboxCollectionViewDelegate?

    /// 数据源
    public var viewModel = [MboxCollectionViewViewModel]() {
        didSet {
            for section in viewModel {
                if let header = section.header {
                    self.register(header.registClass,
                                  forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                  withReuseIdentifier: header.identifa)
                }
                if let footer = section.footer {
                    self.register(footer.registClass,
                                  forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                  withReuseIdentifier: footer.identifa)
                }
                if let items = section.items {
                    for item in items {
                        self.register(item.registClass, forCellWithReuseIdentifier: item.identifa)
                    }
                }
            }
            self.reloadData()
        }
    }

    private var viewCache = NSCache<AnyObject, AnyObject>()

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// 基础配置
    private func setup() {
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.count
    }

    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        var columnCount = 0
        if section < viewModel.count {
            columnCount = viewModel[section].columnCount ?? 1
        }
        return columnCount
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var items = 0
        if section < viewModel.count {
            items = viewModel[section].items?.count ?? 0
        }
        return items
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var returnCell: UICollectionViewCell?

        if indexPath.section < viewModel.count,
            indexPath.row < (viewModel[indexPath.section].items?.count ?? 0),
            let item = viewModel[indexPath.section].items?[indexPath.row] {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.identifa,
                                                          for: indexPath)
            //            cell.frame = collectionView.bounds
            item.fillModel(item: cell)
            cell.sizeToFit()
            returnCell = cell
        }

        return returnCell ?? UICollectionViewCell.init()
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var returnView: UICollectionReusableView?
        var item: MboxCollectionViewItemProtocol?

        if  indexPath.section < viewModel.count {
            if kind == CHTCollectionElementKindSectionHeader {
                item = viewModel[indexPath.section].header
            } else if kind == CHTCollectionElementKindSectionFooter {
                item = viewModel[indexPath.section].footer
            }
        }

        if let item = item {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: item.identifa,
                                                                       for: indexPath)
            //            view.frame = collectionView.bounds
            item.fillModel(item: view)
            //            view.sizeToFit()
            returnView = view
        }

        return returnView ?? UICollectionReusableView.init()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.allDelegate?.collectionView(self, didSelectItemAt: indexPath)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.allDelegate?.scrollViewDidScroll(scrollView)
    }

    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForHeaderInSection section: Int) -> CGFloat {

        var returnFloat: CGFloat?

        if section < viewModel.count,
            let item = viewModel[section].header {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UIView {

                cell.frame = collectionView.bounds
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnFloat = cell.frame.height
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnFloat ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForFooterInSection section: Int) -> CGFloat {

        var returnFloat: CGFloat?

        if section < viewModel.count,
            let item = viewModel[section].footer {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UIView {

                cell.frame = collectionView.bounds
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnFloat = cell.frame.height
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnFloat ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAt section: Int) -> UIEdgeInsets {

        if section < viewModel.count {
            return viewModel[section].sectionInset
        }

        return UIEdgeInsets.zero
    }
    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAt section: Int) -> CGFloat {

        if section < viewModel.count {
            return CGFloat(viewModel[section].minimumColumnSpacing)
        }

        return  0
    }
    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        if section < viewModel.count {
            return CGFloat(viewModel[section].minimumInteritemSpacing)
        }

        return  0
    }
}

// MARK: - CHTCollectionViewDelegateWaterfallLayout
extension MboxCollectionView: CHTCollectionViewDelegateWaterfallLayout {
    public func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {

        var returnSize: CGSize?

        if indexPath.section < viewModel.count,
            indexPath.row < (viewModel[indexPath.section].items?.count ?? 0),
            let item = viewModel[indexPath.section].items?[indexPath.row] {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UICollectionViewCell {

                let section = viewModel[indexPath.section]
                if let columnCount = section.columnCount,
                    columnCount > 1 {
                    var width = collectionView.bounds.width
                        - section.sectionInset.left
                        - section.sectionInset.right
                        - CGFloat(columnCount-1) * CGFloat(section.minimumColumnSpacing)
                    width /= CGFloat(columnCount)
                    cell.frame = CGRect(x: 0, y: 0, width: width, height: collectionView.bounds.height)
                } else {
                    cell.frame = CGRect(x: 0,
                                        y: 0,
                                        width: collectionView.bounds.width
                                            - section.sectionInset.left
                                            - section.sectionInset.right,
                                        height: collectionView.bounds.height)
                }
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnSize = cell.frame.size
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnSize ?? CGSize.zero
    }
}

extension MboxCollectionView {
    public class func waterfall() -> MboxCollectionView {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = MboxCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.isScrollEnabled = true
        return collectionView
    }
    var waterfallLayout: CHTCollectionViewWaterfallLayout? {
        return self.collectionViewLayout as? CHTCollectionViewWaterfallLayout
    }
}

