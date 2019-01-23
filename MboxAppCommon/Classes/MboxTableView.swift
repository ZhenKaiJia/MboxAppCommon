//
//  MboxTableView.swift
//  MboxAppCommon
//
//  Created by Memebox on 2019/1/23.
//

import UIKit

public protocol MboxTableViewCellProtocol: MboxListItemProtocol {

}

public protocol MboxTableViewCellDefaultProtocol: MboxTableViewCellProtocol, MboxListItemDefaultProtocol {

}

public protocol MboxTableViewProtocol {
    var viewCache: NSCache<AnyObject, AnyObject> { get }
    var tableViewWidth: CGFloat { get }
}

private var key: Void?

public extension MboxTableViewProtocol {

    var viewCache: NSCache<AnyObject, AnyObject> {
        if let cache = objc_getAssociatedObject(self, &key) as? NSCache<AnyObject, AnyObject> {
            return cache
        } else {
            let cache = NSCache<AnyObject, AnyObject>()
            objc_setAssociatedObject(self, &key, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
    }

    var tableViewWidth: CGFloat { return UIScreen.main.bounds.size.width }

    public func getTableViewCellHeight(_ item: MboxTableViewCellProtocol) -> CGFloat {
        var returnFloat: CGFloat?
        if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem) as? UITableViewCell {
            cell.frame = CGRect(x: 0, y: 0, width: tableViewWidth, height: 0)
            item.fillModel(item: cell)
            cell.sizeToFit()
            returnFloat = cell.frame.size.height
            viewCache.setObject(cell, forKey: item.identifa as AnyObject)
        }
        return returnFloat ?? 0
    }

    public func getTableViewCell(tableView: UITableView, item: MboxTableViewCellProtocol) -> UITableViewCell? {
        var cell = tableView.dequeueReusableCell(withIdentifier: item.identifa)
        if cell == nil {
            if let cellType = item.registClass as? UITableViewCell.Type {
                cell = cellType.init(style: .default, reuseIdentifier: item.identifa)
            }
        }
        if let cell = cell {
            cell.frame = CGRect(x: 0, y: 0, width: tableViewWidth, height: 0)
            item.fillModel(item: cell)
            cell.sizeToFit()
            return cell
        }
        return cell
    }

    public func getTableViewHeaderFooterHeight(_ item: MboxTableViewCellProtocol) -> CGFloat {
        var returnFloat: CGFloat?
        if let headerFooter = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
            as? UITableViewHeaderFooterView {
            headerFooter.frame = CGRect(x: 0, y: 0, width: tableViewWidth, height: 0)
            item.fillModel(item: headerFooter)
            headerFooter.sizeToFit()
            returnFloat = headerFooter.frame.size.height
            viewCache.setObject(headerFooter, forKey: item.identifa as AnyObject)
        }
        return returnFloat ?? 0
    }

    public func getTablViewHeaderFooter(tableView: UITableView, item: MboxTableViewCellProtocol) -> UITableViewHeaderFooterView? {
        var headerFooter = tableView.dequeueReusableHeaderFooterView(withIdentifier: item.identifa)
        if headerFooter == nil {
            if let viewType = item.registClass as? UITableViewHeaderFooterView.Type {
                headerFooter = viewType.init(reuseIdentifier: item.identifa)
            }
        }
        if let headerFooter = headerFooter {
            headerFooter.frame = CGRect(x: 0, y: 0, width: tableViewWidth, height: 0)
            item.fillModel(item: headerFooter)
            headerFooter.sizeToFit()
            return headerFooter
        }
        return headerFooter
    }
}

public class MboxTableViewViewModel: NSObject {

    public var tag: String?
    /// header需要继承于UITableViewHeaderFooterView，否则无法注册成功
    public var header: MboxTableViewCellProtocol?

    public var items: [MboxTableViewCellProtocol]?

    /// footer需要继承于UITableViewHeaderFooterView，否则无法注册成功
    public var footer: MboxTableViewCellProtocol?
}

public protocol MboxTableViewDelegate: NSObjectProtocol {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)

    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

public extension MboxTableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

open class MboxTableView: UITableView {

    public var allDelegate : MboxTableViewDelegate?

    public var viewModel = [MboxTableViewViewModel]() {
        didSet {
            for section in viewModel {
                if let header = section.header, header.registClass.isSubclass(of: UITableViewHeaderFooterView.self) {
                    register(header.registClass, forHeaderFooterViewReuseIdentifier: header.identifa)
                }
                if let cells = section.items {
                    for cell in cells {
                        register(cell.registClass, forHeaderFooterViewReuseIdentifier: cell.identifa)
                    }
                }
                if let footer = section.footer, footer.registClass.isSubclass(of: UITableViewHeaderFooterView.self) {
                    register(footer.registClass, forHeaderFooterViewReuseIdentifier: footer.identifa)
                }
            }
            reloadData()
        }
    }

    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        delegate = self
        dataSource = self
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
    }
}

extension MboxTableView: UITableViewDelegate, UITableViewDataSource {

    open override var numberOfSections: Int {
        return viewModel.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let defReturn: Int = {
            return 0
        }()

        guard section < viewModel.count else {
            return defReturn
        }

        return viewModel[section].items?.count ?? defReturn
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let defReturn = {
            return UITableViewCell()
        }

        guard indexPath.section < viewModel.count, indexPath.row < viewModel[indexPath.section].items?.count ?? 0 else {
            return defReturn()
        }

        guard let viewModel = viewModel[indexPath.section].items?[indexPath.row] else {
            return defReturn()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.identifa) else {
            return defReturn()
        }
        cell.frame = tableView.bounds
        viewModel.fillModel(item: cell)
        cell.sizeToFit()
        return cell
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let defReturn: CGFloat = {
            return 0
        }()

        guard indexPath.section < viewModel.count, indexPath.row < viewModel[indexPath.section].items?.count ?? 0 else {
            return defReturn
        }

        guard let viewModel = viewModel[indexPath.section].items?[indexPath.row] else {
            return defReturn
        }

        guard let cell = dequeueCacheCell(withIdentifier: viewModel.identifa) else {
            return defReturn
        }

        viewModel.fillModel(item: cell)
        return cell.sizeThatFits(tableView.frame.size).height
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIApplication.shared.keyWindow?.endEditing(true)
        allDelegate?.tableView(tableView, didSelectRowAt: indexPath)
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < viewModel.count else {
            return nil
        }

        guard let header = viewModel[section].header else {
            return nil
        }

        guard let view = dequeueReusableHeaderFooterView(withIdentifier: header.identifa) else {
            return nil
        }

        view.frame = tableView.bounds
        header.fillModel(item: view)
        view.sizeToFit()
        return view
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < viewModel.count else {
            return nil
        }

        guard let footer = viewModel[section].footer else {
            return nil
        }

        guard let view = dequeueReusableHeaderFooterView(withIdentifier: footer.identifa) else {
            return nil
        }

        view.frame = tableView.bounds
        footer.fillModel(item: view)
        view.sizeToFit()
        return view
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let defReturn: CGFloat = {
            return 0.0001
        }()

        guard section < viewModel.count else {
            return defReturn
        }

        guard let viewModel = viewModel[section].header else {
            return defReturn
        }

        guard let cell = dequeueCacheHeaderFooterView(withIdentifier: viewModel.identifa) else {
            return defReturn
        }

        viewModel.fillModel(item: cell)
        return cell.sizeThatFits(tableView.frame.size).height
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let defReturn: CGFloat = {
            return 0.0001
        }()

        guard section < viewModel.count else {
            return defReturn
        }

        guard let viewModel = viewModel[section].footer else {
            return defReturn
        }

        guard let cell = dequeueCacheHeaderFooterView(withIdentifier: viewModel.identifa) else {
            return defReturn
        }

        viewModel.fillModel(item: cell)
        return cell.sizeThatFits(tableView.frame.size).height
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        allDelegate?.scrollViewDidScroll(scrollView)
    }
}

/// MARK: 缓存cell
public extension UITableView {
    fileprivate struct StaticKeys {
        static var cacheForHeaderFooterAndCell = "UITableView.Mbox.cacheForHeaderFooterAndCell"
    }

    fileprivate var uitableview_mbox_cacheForHeaderFooterAndCell: NSCache<NSString, UIView> {
        if let cache = objc_getAssociatedObject(self, &StaticKeys.cacheForHeaderFooterAndCell) as? NSCache<NSString, UIView> {
            return cache
        } else {
            let cache = NSCache<NSString, UIView>()
            objc_setAssociatedObject(self, &StaticKeys.cacheForHeaderFooterAndCell, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
    }
    /// 获取自定义缓存的cell。如果没有，则自动创建
    ///
    /// - Parameter identifier: 重用标识符
    /// - Returns: 缓存的那个
    func dequeueCacheCell<T: UITableViewCell>(withIdentifier identifier: String) -> T? {
        if let cell = uitableview_mbox_cacheForHeaderFooterAndCell.object(forKey: identifier as NSString) {
            return cell as? T
        }

        if let cell = dequeueReusableCell(withIdentifier: identifier) {
            uitableview_mbox_cacheForHeaderFooterAndCell.setObject(cell, forKey: identifier as NSString)
            return cell as? T
        }

        return nil
    }
    /// 获取自定义缓存的headder/footer。如果没有则自动创建
    ///
    /// - Parameter identifier: 重用标识符
    /// - Returns: 缓存的那个
    func dequeueCacheHeaderFooterView<T: UITableViewHeaderFooterView>(withIdentifier identifier: String) -> T? {
        if let cell = uitableview_mbox_cacheForHeaderFooterAndCell.object(forKey: identifier as NSString) {
            return cell as? T
        }

        if let cell = dequeueReusableHeaderFooterView(withIdentifier: identifier) {
            uitableview_mbox_cacheForHeaderFooterAndCell.setObject(cell, forKey: identifier as NSString)
            return cell as? T
        }

        return nil
    }
}

