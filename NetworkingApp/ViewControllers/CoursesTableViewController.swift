//
//  CoursesTableViewController.swift
//  NetworkingApp
//
//  Created by Felix Titov on 6/28/22.
//  Copyright © 2022 by Felix Titov. All rights reserved.
//  


import UIKit

class CoursesTableViewController: UITableViewController {
    
    private let url = "https://swiftbook.ru//wp-content/uploads/api/api_courses"
    private let postRequestURL = "https://jsonplaceholder.typicode.com/posts"
    private let putRequestURL = "https://jsonplaceholder.typicode.com/posts/1"
    
    private var courses = [Course]()
    private var courseName: String?
    private var courseURL: String?
    
    func fetchData() {
        NetworkManager.fetchData(url: url) { [unowned self] courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkManager.sendRequest(url: url) { courses in
            self.courses = courses
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func postRequest() {
        AlamofireNetworkManager.postRequest(url: postRequestURL) { courses in
            self.courses = courses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func putRequest() {
        AlamofireNetworkManager.putRequest(url: putRequestURL) { courses in
            self.courses = courses
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureCell(cell: TableViewCell, for indexPath: IndexPath) {
        let course = courses[indexPath.row]
        
        cell.courseNameLabel.text = course.name
        if let numberOfLessons = course.numberOfLessons {
            cell.numberOfLessons.text = "Number of lessons: \(numberOfLessons)"
        }
        
        if let numberOfTests = course.numberOfTests {
            cell.numberOfTests.text = "Number of tests: \(numberOfTests)"
        }
        
        DispatchQueue.global().async {
            guard let imageUrl = URL(string: course.imageUrl!) else { return }
            guard let imageData = try? Data(contentsOf: imageUrl) else { return }
            
            DispatchQueue.main.async {
                cell.courseImage.image = UIImage(data: imageData)
            }
        }
    }
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[indexPath.row]
        courseURL = course.link
        courseName = course.name
        
        performSegue(withIdentifier: "Description", sender: self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        configureCell(cell: cell, for: indexPath)

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webVC = segue.destination as? WebViewController
        webVC?.selectedCourse = courseName
        if let url = courseURL {
            webVC?.courseURL = url
        }
    }

}
