import UIKit
import Foundation
import PlaygroundSupport


public class HomeController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = #colorLiteral(red: 0.9568627450980393, green: 0.6588235294117647, blue: 0.5450980392156862, alpha: 1.0)

        //Add the app title
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        title.center.x = self.view.center.x
        title.adjustsFontSizeToFitWidth = true
        title.text = "Eliza: Virtual Hair Assistant"
        title.font = UIFont(name: "Helvetica", size: 24)
        title.textColor = #colorLiteral(red: 0.09019607843137255, green: 0.0, blue: 0.30196078431372547, alpha: 1.0)
        title.textAlignment = .center
        view.addSubview(title)
        
        //Add the app logo
        let hairLogo = UIImageView()
        let animationImages: [UIImage] = [
            UIImage(named: "hair_logo.svg")!,
            UIImage(named: "curly_hair.svg")!,
            UIImage(named: "golden_hair.svg")!,
            UIImage(named: "red_hair.svg")!
        ]
        hairLogo.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        hairLogo.center.x = title.center.x
        hairLogo.center.y = title.frame.height + 100
        hairLogo.animationImages = animationImages
        hairLogo.animationDuration = 4.5
        hairLogo.startAnimating()
        view.addSubview(hairLogo)
        
        //Add the description
        let caption = UILabel()
        caption.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        caption.center.x = hairLogo.center.x
        caption.center.y = hairLogo.center.y + 132
        caption.text = "Experience new hair styles and colors with Eliza"
        caption.font = UIFont(name: "Helvetica", size: 14)
        caption.textColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        caption.textAlignment = .center
        view.addSubview(caption)
        
        //Meet Eliza
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        button.center.x = caption.center.x
        button.center.y = caption.center.y + 100
        button.setTitle("Meet Eliza", for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = #colorLiteral(red: 0.5725490196078431, green: 0.0, blue: 0.23137254901960785, alpha: 1.0)
        button.alpha = 0.5
        button.layer.shadowOpacity = 0.8
        button.addTarget(self, action: #selector(updateElizaView(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        //About Me
        let simmiButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        simmiButton.center.x = button.center.x
        simmiButton.center.y = button.center.y + 60
        simmiButton.setTitle("About Me!", for: .normal)
        simmiButton.layer.cornerRadius = 20
        simmiButton.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        simmiButton.alpha = 0.5
        simmiButton.layer.shadowOpacity = 0.8
        simmiButton.addTarget(self, action: #selector(updateSimmiView(_:)), for: .touchUpInside)
        view.addSubview(simmiButton)
        
        self.view = view
    }
    
    @objc func updateElizaView(_ sender:UIButton!) {
        sender.alpha = 0.2
        sender.backgroundColor = #colorLiteral(red: 0.5725490196078431, green: 0.0, blue: 0.23137254901960785, alpha: 1.0)
        
        PlaygroundPage.current.liveView = ElizaController()
    }
    
    @objc func updateSimmiView(_ sender:UIButton!) {
        sender.alpha = 0.2
        sender.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        PlaygroundPage.current.liveView = SimmiController()
    }
}

