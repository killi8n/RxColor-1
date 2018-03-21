//
//  ColorViewController.swift
//  RxColor
//
//  Created by leonard on 2018. 3. 21..
//  Copyright © 2018년 Jeansung. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ColorViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var hexColorTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}

extension ColorViewController {
    func bind() {
        
        let color = Observable
            .combineLatest(redSlider.rx.value, greenSlider.rx.value, blueSlider.rx.value) { (redValue, greenValue, blueValue) -> UIColor in
                UIColor(red: CGFloat(redValue), green: CGFloat(greenValue), blue: CGFloat(blueValue), alpha: 1.0)
        }.debug("color")
        
        color
            .subscribe(onNext: { [weak self] (color: UIColor) in
                self?.colorView.backgroundColor = color
            }).disposed(by: disposeBag)
        
        color
            .map { (color: UIColor) -> String in
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return String(format: "%.2X%.2X%.2X" , Int(255*red), Int(255*green) ,Int(255*blue))
            }.subscribe(onNext: { [weak self] (colorString: String) in
                self?.hexColorTextField.text = colorString
            }).disposed(by: disposeBag)
        
        applyButton.rx.tap.asObservable().withLatestFrom(self.hexColorTextField.rx.text)
            .map { (hexText: String?) -> (Int, Int, Int)? in
                return hexText?.rgb
            }.filter { rgb -> Bool in
                return rgb != nil
            }.map { $0! }.debug()
            .subscribe(onNext: { [weak self] (red,green,blue) in
                self?.redSlider.rx.value.onNext(Float(red)/255.0)
                self?.redSlider.sendActions(for: .valueChanged)
                self?.greenSlider.rx.value.onNext(Float(green)/255.0)
                self?.greenSlider.sendActions(for: .valueChanged)
                self?.blueSlider.rx.value.onNext(Float(blue)/255.0)
                self?.blueSlider.sendActions(for: .valueChanged)
            }).disposed(by: disposeBag)
    }
}

extension String {
    var rgb: (Int, Int, Int)? {
        guard let number: Int = Int(self, radix: 16) else { return nil }
        let blue = number & 0x0000ff
        let green = (number & 0x00ff00) >> 8
        let red = (number & 0xff0000) >> 16
        return (red, green, blue)
    }
}
