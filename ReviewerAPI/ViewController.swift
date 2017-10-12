//
//  ViewController.swift
//  ReviewerAPI
//
//  Created by Christine Oakes on 9/27/17.
//  Copyright © 2017 Maedchen Oakes Prod. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var evals: [Eval]?
    var evalWrapper: EvalWrapper? // holds the last wrapper that we've loaded
    var isLoadingEvals = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // place tableview below status bar, cuz I think it's prettier that way
        self.tableView?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
       tableView.dataSource = self
//        tableView.delegate = self
        self.loadFirstEval()

    }
    
    // MARK: Loading Evals from API
    func loadFirstEval() {
        isLoadingEvals = true
         Eval.getEvals{ result in
            if let error = result.error {
                // TODO: improved error handling
                self.isLoadingEvals = false
                let alert = UIAlertController(title: "Error", message: "Could not load first eval :( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            let evalWrapper = result.value
            self.addEvalFromWrapper(evalWrapper)
            self.isLoadingEvals = false
            self.tableView?.reloadData()
        }
    }
    
    func loadMoreEvals() {
        self.isLoadingEvals = true
        if let evals = self.evals,
            let wrapper = self.evalWrapper,
            let totalEvalsCount = wrapper.count,
            evals.count < totalEvalsCount {
            // there are more species out there!
            Eval.getMoreEvals(evalWrapper) { result in
                if let error = result.error {
                    self.isLoadingEvals = false
                    let alert = UIAlertController(title: "Error", message: "Could not load more evals:( \(error.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let moreWrapper = result.value
                self.addEvalFromWrapper(moreWrapper)
                self.isLoadingEvals = false
                self.tableView?.reloadData()
            }
        }
    }
    
    func addEvalFromWrapper(_ wrapper: EvalWrapper?) {
        self.evalWrapper = wrapper
        if self.evals == nil {
            self.evals = self.evalWrapper?.evals
        } else if self.evalWrapper != nil && self.evalWrapper!.evals != nil {
            self.evals = self.evals! + self.evalWrapper!.evals!
        }
    }

    private var data: [String] = []

    //override func didReceiveMemoryWarning() {
       // super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
   // }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
 
    // MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.evals == nil {
            return 0
        }
        return self.evals!.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNameFill", for: indexPath) //1.
        
        if self.evals != nil && self.evals!.count >= indexPath.row {
            let evals = self.evals![indexPath.row]
            cell.textLabel?.text = evals.applicantFullName
            
            let string = evals.assignedDt
            
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = dateFormatter.date(from: (string)!) {
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
            dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)
            
            cell.detailTextLabel?.text = dateString
            }
        
            // See if we need to load more evals
            let rowsToLoadFromBottom = 5;
            let rowsLoaded = self.evals!.count
            if (!self.isLoadingEvals && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
                //let totalRows = self.evalWrapper?.count
                //let remainingEvalsToLoad = totalRows! - rowsLoaded;
                //if (remainingEvalsToLoad > 0) {
                   // self.loadMoreEvals()
                //}
                self.loadMoreEvals()
            }
        }
        
        //cell.label.text = text
        
        return cell
    }
    
    func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: "Hint", message: "You have selected row.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    // alternate row colors
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0) // very light gray
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}

