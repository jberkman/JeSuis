//
//  ProxyDataSource.swift
//  JeSuis
//
//  Created by jacob berkman on 2015-10-12.
//  Copyright © 2015 jacob berkman.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit

public class ProxyDataSource: NSObject {

    private let rootDataSource: UITableViewDataSource
    private var dataSources = [Int: UITableViewDataSource]()

    public init(dataSource: UITableViewDataSource) {
        rootDataSource = dataSource
        super.init()
    }

    public subscript (section: Int) -> UITableViewDataSource? {
        get { return dataSources[section] }
        set { dataSources[section] = newValue }
    }

    public subscript (indexPath: NSIndexPath) -> UITableViewDataSource? {
        get { return self[indexPath.section] }
        set { self[indexPath.section] = newValue }
    }

    private func tableView(tableView: UITableView, dataSourceForSection section: Int) -> UITableViewDataSource {
        let rootSections = rootDataSource.numberOfSectionsInTableView?(tableView) ?? 1
        return section < rootSections ? (dataSources[section] ?? rootDataSource) : dataSources[rootSections - 1]!
    }

}

extension ProxyDataSource: UITableViewDataSource {

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = rootDataSource.numberOfSectionsInTableView?(tableView) ?? 1
        let dataSource = self.tableView(tableView, dataSourceForSection: numberOfSections - 1)
        return dataSource.numberOfSectionsInTableView?(tableView) ?? 1
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView?(tableView, titleForHeaderInSection: section)
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView?(tableView, titleForFooterInSection: section)
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        return dataSource.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? true
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        dataSource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }

}

public class StoryboardProxyDataSource: ProxyDataSource {

    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return rootDataSource.tableView?(tableView, titleForHeaderInSection: section)
    }

    override public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return rootDataSource.tableView?(tableView, titleForFooterInSection: section)
    }
    
}
