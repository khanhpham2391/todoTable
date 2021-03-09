//
//  Category.swift
//  TodoTable
//
//  Created by inmac on 01/03/2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
    
}
