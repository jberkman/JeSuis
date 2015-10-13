//
//  SectionOffsetting.swift
//  JeSuis
//
//  Created by jacob berkman on 2015-10-12.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import Foundation

public protocol SectionOffsetting {

    var sectionOffset: Int { get }
    
}

extension SectionOffsetting {

    public func insetIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - sectionOffset)
    }

    public func offsetIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + sectionOffset)
    }

}
