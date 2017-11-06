import UIKit

class MainViewController: UIViewController {
    let testInputView = InputView.init(frame: .zero, inputViewStyle: .default)
    
    @IBAction func button(_ sender: AnyObject) {
        UIView.animate(withDuration: 1.0) {
            let isVisible = self.testInputView.isVisible
            self.testInputView.isVisible = !isVisible
            self.testInputView.layoutIfNeeded()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return testInputView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
