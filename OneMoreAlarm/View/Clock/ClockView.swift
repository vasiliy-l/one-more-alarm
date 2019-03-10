//
//  ClocketView.swift
//  OneMoreAlarm
//
//  Created by Angelina on 3/2/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

open class ClockView: UIView {

    private let translateToRadian = Double.pi/180.0

    open var hourHandColor: UIColor = #colorLiteral(red: 0.3176470588, green: 0.3098039216, blue: 0.4, alpha: 1)
    open var hourHandLength: CGFloat = 0.6
    open var hourHandWidth: CGFloat = 0.05

    open var minuteHandLength: CGFloat = 0.7
    open var minuteHandWidth: CGFloat = 0.02
    open var minuteHandColor: UIColor = #colorLiteral(red: 0.3176470588, green: 0.3098039216, blue: 0.4, alpha: 1)

    open var secondHandLength: CGFloat = 0.8
    open var secondHandWidth: CGFloat = 0.01
    open var secondHandColor: UIColor = #colorLiteral(red: 0.1882352941, green: 0.137254902, blue: 0.6823529412, alpha: 1)
    open var secondHandCircleDiameter: CGFloat = 4.0

    open var handTailLength: CGFloat = 0.2
    private var lineWidthFactor: CGFloat = 100.0
    //MARK: - Investigate this
    private var diameter: CGFloat { return min(bounds.width, bounds.height)}
    private var lineWidth: CGFloat { return diameter / lineWidthFactor}

    @IBInspectable open var displayRealTime: Bool = false
    @IBInspectable open var handShadow: Bool = true

    public struct LocalTime {
        var hour: Int = 10
        var minute: Int = 10
        var second: Int = 25
    }

    open var localTime = LocalTime()
    open var timer = Timer()
    open var refreshInterval: TimeInterval = 1.0

    private var clockFace = UIImageView()
    private var hourHand = ClockHand()
    private var minuteHand = ClockHand()
    private var secondHand = ClockHand()
    private var secondHandCircle = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }


    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    private func setup() {
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        setupHands()
        setupClockFace()
    }

    private func setupHands() {
        let hourHandParameters = ClockHandParameters(frame: frame,
                                                     length: hourHandLength,
                                                     width: hourHandWidth,
                                                     tailLength: handTailLength,
                                                     color: hourHandColor,
                                                     shadowIsOn: handShadow,
                                                     initValue: Double(localTime.hour * 30))
        hourHand = ClockHand(parameters: hourHandParameters)

        let minuteHandParameters = ClockHandParameters(frame: frame,
                                                       length: minuteHandLength,
                                                       width: minuteHandWidth,
                                                       tailLength: handTailLength,
                                                       color: minuteHandColor,
                                                       shadowIsOn: handShadow,
                                                       initValue: Double(localTime.minute * 6))
        minuteHand = ClockHand(parameters: minuteHandParameters)

        let secondHandParameters = ClockHandParameters(frame: frame,
                                                       length: secondHandLength,
                                                       width: secondHandWidth,
                                                       tailLength: handTailLength,
                                                       color: secondHandColor,
                                                       shadowIsOn: handShadow,
                                                       initValue: Double(localTime.second * 6))
        secondHand = ClockHand(parameters: secondHandParameters)

        secondHandCircle = SecondHandCircle(radius: diameter/2,
                                            circleDiameter: secondHandCircleDiameter,
                                            lineWidth: lineWidth,
                                            color: secondHandColor)
    }

    private func setupClockFace() {
        clockFace = ClockFace(frame: frame)
        //    clockFace = ClockFace(frame: self.frame, staticClockFaceImage: UIImage(named: "clockface"))

        addSubview(clockFace)
        addSubview(hourHand)
        addSubview(minuteHand)
        addSubview(secondHand)
        addSubview(secondHandCircle)

        clockFace.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        clockFace.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        clockFace.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        clockFace.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true

        secondHandCircle.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        secondHandCircle.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        secondHandCircle.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        secondHandCircle.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true

        hourHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        hourHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        hourHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        hourHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true

        minuteHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        minuteHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        minuteHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        minuteHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true

        secondHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        secondHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        secondHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        secondHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
    }

    open func setLocalTime(hour: Int, minute: Int, second: Int) {
        localTime.hour = hour % 12
        localTime.minute = minute % 60
        localTime.second = second % 60
        updateHands()
    }

    open func startClock() {
        if displayRealTime {
            refreshInterval = 1.0
        }
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }

    @objc private func tick() {
        if displayRealTime {
            let localTimeComponents: Set<Calendar.Component> = [.hour, .minute, .second]
            let realTimeComponents = Calendar.current.dateComponents(localTimeComponents, from: Date())
            localTime.second = realTimeComponents.second ?? 0
            localTime.minute = realTimeComponents.minute ?? 10
            localTime.hour = realTimeComponents.hour ?? 10
        }

        updateHands()
    }

    private func updateHands() {
        secondHand.updateHandAngle(angle: CGFloat(Double(localTime.second * 6) * translateToRadian))
        minuteHand.updateHandAngle(angle: CGFloat(Double(localTime.minute * 6) * translateToRadian))
        let hourDegree = Double(localTime.hour) * 30.0 + Double(localTime.minute) * 0.5
        hourHand.updateHandAngle(angle: CGFloat(hourDegree * translateToRadian))
    }




}
