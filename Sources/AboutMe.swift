import Foundation
import UIKit
import PlaygroundSupport


public class SimmiController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)

        //Add the app title
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        title.center.x = self.view.center.x
        title.adjustsFontSizeToFitWidth = true
        title.text = "Hi! I'm Simmi!"
        title.font = UIFont(name: "Helvetica", size: 24)
        title.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        title.textAlignment = .center
        view.addSubview(title)
        
        //Add the app logo
        let hairLogo = UIImageView()
        hairLogo.image = UIImage(named: "IMG_0042.jpg")
        hairLogo.frame = CGRect(x: 0, y: 0, width: 224, height: 224)
        hairLogo.center.x = title.center.x
        hairLogo.center.y = title.frame.height + 110
        hairLogo.animationDuration = 4.5
        hairLogo.startAnimating()
        view.addSubview(hairLogo)
        
        //Add the description
        let caption = UILabel()
        caption.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        caption.center.x = hairLogo.center.x
        caption.center.y = hairLogo.center.y + 136
        caption.text = "Middle schooler from Vancouver, WA."
        caption.font = UIFont(name: "Helvetica", size: 15)
        caption.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        caption.textAlignment = .center
        view.addSubview(caption)
        
        let caption2 = UILabel()
        caption2.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        caption2.center.x = caption.center.x
        caption2.center.y = caption.center.y + 30
        caption2.text = "Fastest Rubik's cube 3 x 3 solve: 8.26 secs"
        caption2.font = UIFont(name: "Helvetica", size: 15)
        caption2.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        caption2.textAlignment = .center
        view.addSubview(caption2)
        
        let caption3 = UILabel()
        caption3.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        caption3.center.x = caption2.center.x
        caption3.center.y = caption2.center.y + 30
        caption3.text = "Enjoy painting and exploring digital art / design!"
        caption3.font = UIFont(name: "Helvetica", size: 15)
        caption3.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        caption3.textAlignment = .center
        view.addSubview(caption3)
        
        //Go back to home page
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        button.center.x = caption3.center.x
        button.center.y = caption3.center.y + 120
        button.setTitle("Go Back", for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = #colorLiteral(red: 0.5725490196078431, green: 0.0, blue: 0.23137254901960785, alpha: 1.0)
        button.alpha = 0.5
        button.layer.shadowOpacity = 0.8
        button.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        self.view = view
    }
    
    @objc func goBack(_ sender:UIButton!) {
        sender.alpha = 0.2
        sender.backgroundColor = #colorLiteral(red: 0.5725490196078431, green: 0.0, blue: 0.23137254901960785, alpha: 1.0)
        
        PlaygroundPage.current.liveView = HomeController()
    }
}
