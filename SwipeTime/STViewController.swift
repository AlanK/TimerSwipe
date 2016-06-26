//
//  STViewController.swift
//  SwipeTime
//
//  Created by Alan Kantz on 6/26/16.
//  Copyright © 2016 Alan Kantz. All rights reserved.
//

import UIKit

class STViewController: UIViewController {

    
    var startTime = 30
    var timer = NSTimer()
    
    func millisecondsToMinutesSecondsMilliseconds(time: Int) -> ([Int]) {
        return [time / 6000, (time / 100) % 60, time % 100]
    }
    
    func formatTime(time: [Int]) -> (String) {
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
        
        var timeAsString = ["", "", ""]
        
        var i = 0
        for block in time {
            timeAsString[i] = numberFormatter.stringFromNumber(block)!
            i += 1
        }
        
        return timeAsString[0] + ":" + timeAsString[1] + "." + timeAsString[2]
        
    }

    
    @IBOutlet var timeDisplay: UILabel!
    @IBOutlet var cancelTimer: UIButton!
    @IBOutlet var rightStartTimer: UISwipeGestureRecognizer!
    @IBOutlet var leftStartTimer: UISwipeGestureRecognizer!
    @IBOutlet var upStartTimer: UISwipeGestureRecognizer!
    @IBOutlet var downStartTimer: UISwipeGestureRecognizer!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
