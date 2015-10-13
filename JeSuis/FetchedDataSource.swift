//
//  FetchedDataSource.swift
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

import CoreData
import Foundation
import UIKit

public class FetchedDataSource<Element: NSManagedObject, Cell: UITableViewCell>: NSObject, FetchableDataSource, NSFetchedResultsControllerDelegate, UITableViewDataSource {

    public let fetchRequest = NSFetchRequest()
    public var reuseIdentifier = "reuseIdentifier"
    public var sectionNameKeyPath: String?
    public var cacheName: String?

    public var tableView: UITableView!

    public let sectionOffset: Int

    public init(sectionOffset: Int = 0) {
        assert(sectionOffset >= 0)
        self.sectionOffset = sectionOffset
        super.init()
    }

    public var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }

    public var managedObjectContext: NSManagedObjectContext?

    public func configureCell(cell: Cell, forElement element: Element) { }

    // extension UITableViewDataSource where Self: FetchableDataSource {

    @objc public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedResultsController?.sections?.count ?? 0) + sectionOffset
    }

    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section - sectionOffset].numberOfObjects ?? 0
    }

    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        configureCell(cell, forElement: self[indexPath])
        return cell
    }

    @objc public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController!.sections![section - sectionOffset].name
    }

    @objc public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }

    @objc public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController!.sectionForSectionIndexTitle(title, atIndex: index - sectionOffset)
    }

    // extension NSFetchedResultsControllerDelegate where Self: FetchableDataSource {

    @objc public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    @objc public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex + sectionOffset), withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex + sectionOffset), withRowAnimation: .Fade)

        default:
            break
        }
    }

    @objc public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([offsetIndexPath(newIndexPath!)], withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteRowsAtIndexPaths([offsetIndexPath(indexPath!)], withRowAnimation: .Fade)

        case .Update:
            guard let cell = tableView.cellForRowAtIndexPath(offsetIndexPath(indexPath!)) as? Cell else { break }
            configureCell(cell, forElement: anObject as! Element)

        case .Move:
            tableView.deleteRowsAtIndexPaths([offsetIndexPath(indexPath!)], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([offsetIndexPath(newIndexPath!)], withRowAnimation: .Fade)
        }
    }

    @objc public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
