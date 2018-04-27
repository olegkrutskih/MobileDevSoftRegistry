//
//  DBModels.swift
//  #mobile_dev software registry
//
//  Created by Круцких Олег on 18.04.2018.
//


import StORM
import MySQLStORM



class Project: MySQLStORM {
    var id_proj: Int = 0
	var name: String = ""
	var type: String = ""
	var description: String = ""
    var owner: String = ""
    var current_version: String = ""

    // The name of the database table
	override open func table() -> String { return "projects" }

    // The mapping that translates the database info back to the object
	// This is where you would do any validation or transformation as needed
	override func to(_ this: StORMRow) {
        id_proj = this.data["id_proj"] as? Int ?? 0
        name = this.data["name"] as? String ?? ""
        type = this.data["type"] as? String ?? ""
        description = this.data["description"] as? String ?? ""
        owner = this.data["owner"] as? String ?? ""
        current_version = this.data["current_version"] as? String ?? ""
	}

    // A simple iteration.
	// Unfortunately necessary due to Swift's introspection limitations
	func rows() -> [Project] {
		var rows = [Project]()
		for i in 0..<self.results.rows.count {
			let row = Project()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}