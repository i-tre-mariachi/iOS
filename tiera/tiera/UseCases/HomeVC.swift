//
//  HomeVC.swift
//  tiera
//
//  Created by Christos Christodoulou on 02/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var selectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var stopCoffeeButton: UIButton!
    @IBOutlet weak var startCoffeeButton: FARoundedButton!
    @IBOutlet weak var scheduleCoffeeButton: UIButton!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func startCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Connecting ..."
        //TODO: start the BT process...
    }
    
    @IBAction func cancelCoffeeTapped(_ sender: Any) {
        progressLabel.text = "Ready to connect!"
        //TODO: stop the connection
        //Maybe 
    }
    
    @IBAction func scheduleCoffeeTapped(_ sender: Any) {
        performSegue(withIdentifier: "toScheduleSegue", sender: self)
    }
    
}
