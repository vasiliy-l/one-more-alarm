//
//  Constants.swift
//  OneMoreAlarm
//
//  Created by Angelina on 3/21/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import Foundation
import UIKit

// Day theme

var bgDayModeColor = #colorLiteral(red: 1, green: 0.877138892, blue: 0.8017332913, alpha: 1)
var dayHourHandColor = #colorLiteral(red: 0.4784313725, green: 0.4549019608, blue: 0.5215686275, alpha: 1)
var dayMinuteHandColor = #colorLiteral(red: 0.4784313725, green: 0.4549019608, blue: 0.5215686275, alpha: 1)
var daySecondHandColor = #colorLiteral(red: 0.6078431373, green: 0, blue: 0, alpha: 1)
var dayDigitColor = #colorLiteral(red: 0.1882352941, green: 0.137254902, blue: 0.6823529412, alpha: 1)
var dayFontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

// Night theme

var bgNightModeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
var nightHourHandColor = #colorLiteral(red: 0.1882352941, green: 0.137254902, blue: 0.6823529412, alpha: 1)
var nightMinuteHandColor = #colorLiteral(red: 0.1882352941, green: 0.137254902, blue: 0.6823529412, alpha: 1)
var nightSecondHandColor = #colorLiteral(red: 0.8235294118, green: 0.6784313725, blue: 0.2274509804, alpha: 1)
var nightDigitColor = #colorLiteral(red: 0.9176470588, green: 0.9058823529, blue: 0.9333333333, alpha: 1)
var nightFontColor = #colorLiteral(red: 0.9176470588, green: 0.9058823529, blue: 0.9333333333, alpha: 1)


// Calendar data & time
let currentDate = Date()
let currentCalendar = Calendar.current
let currentHour = currentCalendar.component(.hour, from: currentDate)
let nightModeTime = 17

