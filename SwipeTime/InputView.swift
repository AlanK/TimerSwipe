import UIKit

class InputView: UIInputView {
    
    private let providedHeight: CGFloat = 50.0
    private let usefulView = UIView()
    private var constraintToHideView: NSLayoutConstraint?, constraintToShowView: NSLayoutConstraint?
   
    var isVisible: Bool {
        get {
            return constraintToShowView!.isActive
        }
        set {
            // Always deactivate constraints before activating conflicting ones
            if newValue == true {
                constraintToHideView?.isActive = false
                constraintToShowView?.isActive = true
            } else {
                constraintToShowView?.isActive = false
                constraintToHideView?.isActive = true
            }
        }
    }
    
    // MARK: Sizing

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: providedHeight)
    }
    
    override var intrinsicContentSize: CGSize {
        var size = bounds.size
        size.height = usefulView.bounds.size.height
        return size
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        let guide = layoutMarginsGuide
        
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(usefulView)
        
        usefulView.backgroundColor = UIColor.purple
        usefulView.translatesAutoresizingMaskIntoConstraints = false
        usefulView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        usefulView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        usefulView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        usefulView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        
        constraintToShowView = usefulView.heightAnchor.constraint(equalToConstant: providedHeight)
        constraintToHideView = usefulView.heightAnchor.constraint(equalToConstant: 0.0)
        
        constraintToHideView?.isActive = true
    }
}
