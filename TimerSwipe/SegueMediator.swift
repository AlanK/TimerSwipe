//
//  SegueMediator.swift
//  TimerSwipe
//
//  Created by Alan Kantz on 11/29/17.
//  Copyright © 2017 Alan Kantz. All rights reserved.
//

import UIKit

struct SegueMediator {
    /**
     Prepare for segue to the main view controller specifically. This has the same signature as `prepare(for:sender:)` for convenience.
     - parameter segue: The `TableToTimer` storyboard segue
     - parameter sender: A `TableCell` passed as `Any?`
     - parameter modelIntermediary: The data model
     */
    static func fromTableControllerToMainViewController(segue: UIStoryboardSegue, sender: Any?) {
        guard let source = segue.source as? TableController,
            let destination = segue.destination as? MainViewController,
            let selectedCell = sender as? TableCell,
            let indexPath = source.tableView.indexPath(for: selectedCell),
            let model = source.modelIntermediary?.model else { return }
        let timer = model[indexPath.row]
        // Make sure VoiceOver will focus on the selected cell if the user unwinds this segue
        source.accessibleFirstFocus = selectedCell
        // Set the destination view controller's providedDuration to the timer value
        destination.providedDuration = timer.seconds
    }
}
