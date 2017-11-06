import UIKit

class InputView: UIInputView {
    private let someHeight: CGFloat = 50.0, zeroHeight: CGFloat = 0.0
    private let subView = UIView()
    private var hide: NSLayoutConstraint?, show: NSLayoutConstraint?
   
    var isVisible: Bool {
        get {
            return show!.isActive
        }
        set {
            // Always deactivate constraints before activating conflicting ones
            if newValue == true {
                hide?.isActive = false
                show?.isActive = true
            } else {
                show?.isActive = false
                hide?.isActive = true
            }
        }
    }
    
    // MARK: Sizing

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: someHeight)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize.init(width: bounds.size.width, height: subView.bounds.size.height)
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect, inputViewStyle: UIInputViewStyle) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        addSubview(subView)
        subView.backgroundColor = UIColor.purple

        translatesAutoresizingMaskIntoConstraints = false
        subView.translatesAutoresizingMaskIntoConstraints = false

        subView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        subView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        
        show = subView.heightAnchor.constraint(equalToConstant: someHeight)
        hide = subView.heightAnchor.constraint(equalToConstant: zeroHeight)
        hide?.isActive = true
    }
}
