//
//  ClockFace.swift
//  OneMoreAlarm
//
//  Created by Angelina on 3/2/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

class ClockFace: UIImageView {

    private var staticClockFaceImage: UIImage?
    private var diameter: CGFloat { return min(frame.width, frame.height) }

    var lineWidthFactor = CGFloat(100.0)

    lazy var lineWidth = {
        return diameter / lineWidthFactor
    }()

    var enableDigits = true
    var digitFontName = "Avenir-Medium"
    var digitFontCoefficient = CGFloat(9.0)
    var digitFont: UIFont { return UIFont(name: digitFontName, size: diameter/digitFontCoefficient)! }
    var digitColor = dayDigitColor

    // MARK: - Dark mode theme function 
    func darkModeTheme() {
        if currentHour > nightModeTime {
            digitColor = nightDigitColor
            
        } else {
            digitColor = dayDigitColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        darkModeTheme()
        setup()
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        darkModeTheme()
        setup()
    }


    convenience init(frame: CGRect, staticClockFaceImage: UIImage?) {
        self.init(frame: frame)
        self.staticClockFaceImage = staticClockFaceImage
        darkModeTheme()
        setup()
    }


    func setup() {
        image = staticClockFaceImage ?? drawClockFace()
        translatesAutoresizingMaskIntoConstraints = false
    }


    func drawClockFace() -> UIImage {
        let digits = drawDigits()
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { (ctx) in
            let origin = CGPoint(x: 0, y: 0)
            digits.draw(at: origin)
        }
    }


    func drawDigits() -> UIImage {
        if !enableDigits {return UIImage()}

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter,
                                                            height: diameter))
        let fontHeight = digitFont.lineHeight
        let halfFontHeight = fontHeight/2

        let center = CGPoint(x: diameter/2 - halfFontHeight/2,
                             y: diameter/2 - halfFontHeight)
        let digitDistanceFromCenter = (diameter-lineWidth)/2 - fontHeight/4 //- digitOffset
        let attrs = [NSAttributedString.Key.font: digitFont, NSAttributedString.Key.foregroundColor: digitColor] as [NSAttributedString.Key : Any]

        return renderer.image { (ctx) in
            for i in 1...12 {
                let rectOriginX = center.x + (digitDistanceFromCenter - halfFontHeight) * CGFloat(cos((Double.pi/180) * Double((i + 3) * 30) + Double.pi))
                let rectOriginY = center.y + -1 * (digitDistanceFromCenter - halfFontHeight) * CGFloat(sin((Double.pi/180) * Double((i + 3) * 30)))
                let digitRect: CGRect
                let hourDigit = String(i)
                if i < 10 { //digits 1..9
                    digitRect = CGRect(x: rectOriginX, y: rectOriginY, width: halfFontHeight, height: fontHeight)
                } else { //10-12
                    digitRect = CGRect(x: rectOriginX - fontHeight/4, y: rectOriginY, width: fontHeight, height: fontHeight)
                }
                hourDigit.draw(with: digitRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            }
        }
    }

}
