//
//  Constant.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import UIKit

let App_Name = "TMM-mini"

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
let sceneDelegate = windowScene?.delegate as? SceneDelegate

let screenSize = UIScreen.main.bounds.size

let safeAreaTop = sceneDelegate?.window?.safeAreaInsets.top ?? 0
let safeAreaBottom = sceneDelegate?.window?.safeAreaInsets.bottom ?? 0

let DFormat = "d"
let HMMAFormat = "hh:mm a"
let HDotMMAFormat = "h.mm a"
let MMMMFormat = "MMMM"
let DDMMM = "dd MMM"
let DD_MM_YYYY = "dd-MM-yyyy"
let DD_MMM_YYYY = "dd MMM, yyyy"
let appFulldate = "dd MMMM yyyy"
let MMMM_YYYY = "MMMM yyyy"

let NewDDMMYYYY = "dd/MM/yyyy"

let DateFormatLong = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
let DateFormatLongNew = "yyyy-MM-dd'T'HH:mm:ssZ"

let TIME_24HOUR = "HH:mm"

let DD = "dd"
let MMMM = "MMMM"
let YYYY = "yyyy"
let HH = "hh"

let E_HHMMADate = "E - hh:mm a"

let MMMMDDYYYY = MMMM + " " + DD + ", " + YYYY
