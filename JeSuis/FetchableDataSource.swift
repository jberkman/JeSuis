//
//  FetchableDataSource.swift
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

public protocol FetchableDataSource: SectionOffsetting {

    typealias Element: AnyObject
    typealias Cell: UITableViewCell

    var fetchRequest: NSFetchRequest { get }
    var reuseIdentifier: String { get }
    var sectionNameKeyPath: String? { get }
    var cacheName: String? { get }

    var managedObjectContext: NSManagedObjectContext? { get }
    var fetchedResultsController: NSFetchedResultsController? { get set }
    var tableView: UITableView! { get }

    func configureCell(cell: Cell, forElement Element: Element)

}

extension FetchableDataSource {

    public subscript (index: Int) -> Element {
        return fetchedResultsController!.fetchedObjects![index] as! Element
    }

    public subscript (indexPath: NSIndexPath) -> Element {
        return fetchedResultsController!.objectAtIndexPath(insetIndexPath(indexPath)) as! Element
    }

    public subscript (element: Element) -> NSIndexPath? {
        guard let indexPath = fetchedResultsController!.indexPathForObject(element) else { return nil }
        return offsetIndexPath(indexPath)
    }

    public var fetchedElements: [Element]? {
        return fetchedResultsController?.fetchedObjects as? [Element]
    }

    public mutating func reloadData() {
        guard let managedObjectContext = managedObjectContext else { return }
        if fetchRequest.entity == nil {
            fetchRequest.entity = managedObjectContext.persistentStoreCoordinator?.managedObjectModel.entities.lazy.filter {
                $0.managedObjectClassName == NSStringFromClass(Element.self)
                }.first
        }

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)

        do {
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            NSLog("Could not perform fetch: %@", error)
            fetchedResultsController = nil
        }
        tableView.reloadData()
    }

}
