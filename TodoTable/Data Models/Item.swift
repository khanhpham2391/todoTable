//
//  Item.swift
//  TodoTable
//
//  Created by inmac on 01/03/2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var colour: String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
