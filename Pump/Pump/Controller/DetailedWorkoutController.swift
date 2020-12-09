//
//  DetailedWorkoutController.swift
//  Pump
//
//  Created by Akash Kaul on 12/8/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import UIKit

class DetailedWorkoutController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var post: Post!
    var name: String!
    var likes: Int!
    
    let numExerciseComponents = 4
    var fontSize:CGFloat = 14
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        tableView.reloadData()
    }
    init(post: Post) {
        self.post = post
        self.name = post.title
        self.likes = post.likes
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return post.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section % numExerciseComponents == 0 {
            if indexPath.section == 0 {
                let cell:TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! TextFieldTableViewCell
                cell.workoutTitleTextField.text = self.name
                return cell
            }
            else {
                
                let cell:TextFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! TextFieldTableViewCell
                cell.workoutTitleTextField.text = post.exercises[indexPath.section]["exercise"]
                return cell
            }
        }
        else if indexPath.section % numExerciseComponents == 1 {
            let cell:ExerciseWorkoutTableViewCell = tableView.dequeueReusableCell(withIdentifier: "exerciseCellNoDelete") as! ExerciseWorkoutTableViewCell
            cell.exerciseLabel.text = "Exercise \(indexPath.section)"
            return cell
        }
        else if indexPath.section % numExerciseComponents == 2 {
            let cell:LabelCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! LabelCellTableViewCell
            cell.label.text = "Reps"
            cell.rightLabel.text = post.exercises[indexPath.section]["reps"]
            return cell
        }
        else {
            let cell:LabelCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: "workoutCell") as! LabelCellTableViewCell
            cell.label.text = "Sets"
            cell.rightLabel.text = post.exercises[indexPath.section]["sets"]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || (section % numExerciseComponents == 0) {
            return 40
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

}
