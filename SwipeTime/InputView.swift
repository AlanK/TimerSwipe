import UIKit

class InputView: UIInputView {
    
    private let someHeight: CGFloat = 50.0, zeroHeight: CGFloat = 0.0
    private let view = UIView()
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
        
        addSubview(view)
        view.backgroundColor = UIColor.purple

        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false

        view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
        
        show = view.heightAnchor.constraint(equalToConstant: someHeight)
        hide = view.heightAnchor.constraint(equalToConstant: zeroHeight)
        
        hide?.isActive = true
    }
}
