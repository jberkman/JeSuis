//
//  StaticDataSource.swift
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

public class Row {
    public let reuseIdentifier: String
    public let configureCell: (cell: UITableViewCell, indexPath: NSIndexPath) -> Void

    public init(reuseIdentifier: String, configureCell: (cell: UITableViewCell, indexPath: NSIndexPath) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        self.configureCell = configureCell
    }
}

public class Section {
    public let rows: [Row]
    public let headerTitle: String?
    public let footerTitle: String?

    public init(rows: [Row], headerTitle: String? = nil, footerTitle: String? = nil) {
        self.rows = rows
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
    }

    subscript (row: Int) -> Row { return rows[row] }
}

public class StaticDataSource: NSObject, SectionOffsetting {

    public let sectionOffset: Int
    private let sections: [Section]

    public init(sections: [Section], sectionOffset: Int = 0) {
        self.sectionOffset = sectionOffset
        self.sections = sections
    }

    public subscript (section: Int) -> Section { return sections[section - sectionOffset] }
    public subscript (indexPath: NSIndexPath) -> Row { return self[indexPath.section - sectionOffset][indexPath.row] }

    public func indexPathForRowWithReuseIdentifier(reuseIdentifier: String) -> NSIndexPath? {
        for (sectionIndex, section) in sections.enumerate() {
            for (rowIndex, row) in section.rows.enumerate() {
                guard row.reuseIdentifier == reuseIdentifier else { continue }
                return NSIndexPath(forRow: rowIndex, inSection: sectionIndex + sectionOffset)
            }
        }
        return nil
    }

}

extension StaticDataSource: UITableViewDataSource {

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionOffset + sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section].rows.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self[indexPath].reuseIdentifier, forIndexPath: indexPath)
        self[indexPath].configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self[section].headerTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self[section].footerTitle
    }

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}
