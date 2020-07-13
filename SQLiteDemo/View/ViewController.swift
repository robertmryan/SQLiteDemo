//
//  ViewController.swift
//  SQLiteDemo
//
//  Created by Robert Ryan on 7/12/20.
//  Copyright © 2020 Robert Ryan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var personTable: UITableView!

    let cellReuseIdentifier = "cell"

    var db = DBHelper()

    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        db.insert(id: 1, name: "Bilal", age: 24)
        db.insert(id: 2, name: "Bosh", age: 25)
        db.insert(id: 3, name: "Thor", age: 23)
        db.insert(id: 4, name: "Edward", age: 44)
        db.insert(id: 5, name: "Foobar", age: -1)  // dummy record, replaced below
        db.insert(id: 5, name: "Ronaldo", age: 34)

        people = db.read()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.text = "Name: \(people[indexPath.row].name), Age: \(people[indexPath.row].age)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    // this is intentionally blank
}
