import UIKit

class CustomBetslip: UIView {
  let button1 = UIButton()
  let button2 = UIButton()
  let textView = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupUI()
  }
  
  private func setupUI() {
    isHidden = true
    button1.setTitle("Place bet", for: .normal)
    button1.addTarget(self, action: #selector(hide), for: .touchUpInside)
    button1.backgroundColor = UIColor.blue
    button1.layer.cornerRadius = 5

    button2.setTitle("Cancel", for: .normal)
    button2.addTarget(self, action: #selector(hide), for: .touchUpInside)
    button2.backgroundColor = UIColor.blue
    button2.layer.cornerRadius = 5
    
    textView.text = "makertId:"
    textView.numberOfLines = 10
    textView.font = UIFont.systemFont(ofSize: 12)
    
    backgroundColor = UIColor.white.withAlphaComponent(0.8)
    layer.cornerRadius = 10

    addSubview(button1)
    addSubview(button2)
    addSubview(textView)
  }
  @objc func hide() {
    isHidden = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // Layout your subviews
    button1.frame = CGRect(x: 20, y: 140, width: 100, height: 40)
    button2.frame = CGRect(x: 140, y: 140, width: 100, height: 40)
    textView.frame = CGRect(x: 20, y: 20, width: bounds.width - 40, height: 120)
  }
}
