//
//  ToastView.swift
//
//  Created by xglofter.
//  Copyright © 2016年 guang xu. All rights reserved.
//

import UIKit


let TGCToastHorizontalMargin: CGFloat = 12
let TGCToastVerticalMargin: CGFloat = 12
let TGCToastHorizontalMaxPer: CGFloat = 0.4  // 40% parent view width
let TGCToastVerticalMaxPer: CGFloat = 0.5    // 50% parent view height
let TGCToastImageWidth: CGFloat = 30
let TGCToastImageHeight: CGFloat = 30
let TGCToastSpaceBetweenTextAndImage: CGFloat = 14
let TGCToastErrorHeight: CGFloat = 25
let TGCToastErrorHorizontalMargin: CGFloat = 10
let TGCToastErrorVerticalMagin: CGFloat = 5

let TGCToastLayerCornerRadius: CGFloat = 12
let TGCToastLayerColor: UIColor = UIColor.black
let TGCToastLayerUseShadow: Bool = true
let TGCToastLayerShadowOpacity: CGFloat = 0.8
let TGCToastLayerShadowRadius: CGFloat = 5.0
let TGCToastLayerShadowOffset: CGSize = CGSize(width: 3.0, height: 3.0)
let TGCToastErrorLayerColor: UIColor = UIColor(red: 244/255, green: 81/255, blue: 78/255, alpha: 1)

let TGCToastTextColor: UIColor = UIColor.white
let TGCToastErrorTextColor: UIColor = UIColor.white

let TGCToastFadeInTime: Double = 0.5
let TGCToastFadeOutTime: Double = 0.4
let TGCToastDefaultTime: Double = 3
let TGCToastErrorMoveInTime: Double = 0.3
let TGCToastErrorMoveOutTime: Double = 0.2

var TGCTimer: UnsafePointer<Timer>? = nil
var TGCToastView: UnsafePointer<UIView>? = nil

var TGCErrorTimer: UnsafePointer<Timer>? = nil
var TGCErrorToastView: UnsafePointer<UIView>? = nil
var TGCErrorViewOriginBottomY: UnsafePointer<CGFloat>? = nil

enum ToastPosition
{
    case center,top,bottom
}


extension UIView {

    /**
     make a toast (only text)

     - parameter message:  message text
     - parameter duration: toast showing time(default is 3 seconds)
     */
    func tgc_makeToast(message: String, duration: Double = TGCToastDefaultTime , position:ToastPosition = .center) {
        tgc_toMakeToast(message: message, duration: duration, image: nil, position: position)
    }

    /**
     make a toast (image with text)

     - parameter message:  message text
     - parameter image: image
     - parameter duration: toast showing time(default is 3 seconds)
     */
    func tgc_makeToast(message: String, image: UIImage, duration: Double = TGCToastDefaultTime, position:ToastPosition = .center) {
        tgc_toMakeToast(message: message, duration: duration, image: image, position: position)
    }

    /**
     make a toast (only image)

     - parameter image: image
     - parameter duration: toast showing time(default is 3 seconds)
     */
    func tgc_makeToastImage(image: UIImage, duration: Double = TGCToastDefaultTime, position:ToastPosition = .center) {
        tgc_toMakeToast(message: nil, duration: duration, image: image, position: position)
    }

    /**
     make a error toast view

     - parameter message:  error information
     - parameter duration: showing time(default is 3 seconds)
     */
    func tgc_makeErrorToast(message: String, originBottomPosY posY: CGFloat = 0, duration: Double = TGCToastDefaultTime) {

        objc_setAssociatedObject(self, &TGCErrorViewOriginBottomY, posY, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        if let errorView = objc_getAssociatedObject(self, &TGCErrorToastView) {
            if let timer = objc_getAssociatedObject(errorView, &TGCErrorTimer) {
                (timer as AnyObject).invalidate()
            }
            tgc_hideErrorView(view: errorView as! UIView, force: true)
        }

        let toast = tgc_errorView(message: message)
        self.addSubview(toast)
        objc_setAssociatedObject(self, &TGCErrorToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        tgc_showErrorView(view: toast, duration: duration)
    }

    private func tgc_toMakeToast(message: String?, duration: Double, image: UIImage? , position : ToastPosition) {

        if let toastView = objc_getAssociatedObject(self, &TGCToastView)
        {
            if let timer = objc_getAssociatedObject(toastView, &TGCTimer)
            {
                (timer as AnyObject).invalidate()
            }
            tgc_hideWrapperView(view: toastView as! UIView, force: true)
        }

        let toast = tgc_wrapperView(msg: message, image: image , position: position)
        self.addSubview(toast)
        objc_setAssociatedObject(self, &TGCToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        tgc_showWrapperView(view: toast, duration: duration)
    }

    private func tgc_wrapperView(msg: String?, image: UIImage? , position: ToastPosition) -> UIView {

        let wrapperView = UIView()
        wrapperView.layer.cornerRadius = TGCToastLayerCornerRadius
        wrapperView.backgroundColor = TGCToastLayerColor.withAlphaComponent(0.9)
        wrapperView.alpha = 0.0
        if TGCToastLayerUseShadow {
            wrapperView.layer.shadowColor = TGCToastLayerColor.cgColor
            wrapperView.layer.shadowOpacity = Float(TGCToastLayerShadowOpacity)
            wrapperView.layer.shadowRadius = TGCToastLayerShadowRadius
            wrapperView.layer.shadowOffset = TGCToastLayerShadowOffset
        }

        var imageView: UIImageView!
        var msgLabel: UILabel!
        let parentSize = self.bounds.size

        if image != nil {
            imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame.size = CGSize(width: TGCToastImageWidth, height: TGCToastImageHeight)
            wrapperView.addSubview(imageView)
        }

        if msg != nil {
            msgLabel = UILabel()
            msgLabel.text = msg
            msgLabel.textColor = TGCToastTextColor
            msgLabel.font = UIFont.systemFont(ofSize: 14)
            msgLabel.lineBreakMode = .byWordWrapping
            msgLabel.numberOfLines = 0
            msgLabel.textAlignment = .center
            wrapperView.addSubview(msgLabel)

            let maxMsgWidth = parentSize.width * TGCToastHorizontalMaxPer - TGCToastHorizontalMargin * 2
            let maxMsgHeight = tgc_heightForLabel(textLabel: msgLabel, width: maxMsgWidth)
            msgLabel.frame.size = CGSize(width: maxMsgWidth, height:maxMsgHeight)
        }

        let imageHeight = (imageView != nil) ? imageView.frame.size.height + ((msgLabel != nil) ? TGCToastSpaceBetweenTextAndImage : 0) : 0
        let textHeight = (msgLabel != nil) ? msgLabel.frame.size.height : 0
        let wrapperWidth = parentSize.width * TGCToastHorizontalMaxPer
        let wrapperHeight = min(imageHeight + textHeight + TGCToastVerticalMargin * 2, parentSize.height * TGCToastVerticalMaxPer)
        wrapperView.frame.size = CGSize(width: wrapperWidth, height:wrapperHeight)
        
        var centerPosition : CGPoint!
        switch position
        {
        case .center:
            centerPosition = CGPoint(x: parentSize.width * 0.5, y: parentSize.height * 0.5)
        case .top:
            centerPosition = CGPoint(x: parentSize.width * 0.5, y: parentSize.height * 0.2)
        case .bottom:
            centerPosition = CGPoint(x: parentSize.width * 0.5, y: parentSize.height * 0.8)
        }
        
        wrapperView.center = centerPosition

        if imageView != nil {
            imageView!.center = CGPoint(x: wrapperWidth * 0.5, y: TGCToastVerticalMargin + imageView!.frame.size.height * 0.5)
        }

        if msgLabel != nil {
            msgLabel!.center = CGPoint(x: wrapperWidth * 0.5, y: wrapperHeight - msgLabel!.frame.size.height * 0.5 - TGCToastVerticalMargin)
        }

        return wrapperView
    }

    private func tgc_errorView(message: String) -> UIView {

        let errorView = UIView()
        errorView.backgroundColor = TGCToastErrorLayerColor

        let textLabel = UILabel()
        textLabel.text = message
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = TGCToastErrorTextColor
        errorView.addSubview(textLabel)

        let parentSize = self.bounds.size
        let maxTextWidth = parentSize.width - TGCToastErrorHorizontalMargin * 2
        let maxTextHeight = tgc_heightForLabel(textLabel: textLabel, width: maxTextWidth)
        textLabel.frame.size = CGSize(width: maxTextWidth, height: maxTextHeight)
        errorView.frame.size = CGSize(width: parentSize.width, height: maxTextHeight+TGCToastErrorVerticalMagin*2)
        textLabel.center = CGPoint(x: errorView.frame.size.width * 0.5, y: errorView.frame.size.height * 0.5)

        let posY = objc_getAssociatedObject(self, &TGCErrorViewOriginBottomY) as! CGFloat
        errorView.center = CGPoint(x: parentSize.width * 0.5, y: posY - errorView.frame.size.height * 0.5)

        return errorView
    }

    private func tgc_hideWrapperView(view: UIView, force: Bool) {
        func clearProperty() {
            view.removeFromSuperview()
            objc_setAssociatedObject(self, &TGCToastView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            objc_setAssociatedObject(self, &TGCTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        if force {
            clearProperty()
        } else {
            UIView.animate(withDuration: TGCToastFadeOutTime, delay: 0.0, options: [.curveEaseIn], animations: { view.alpha = 0.0 }) { (over: Bool) in
                clearProperty()
            }
        }
    }

    private func tgc_showWrapperView(view: UIView, duration: Double) {
        UIView.animate(withDuration: TGCToastFadeInTime, delay: 0, options: [.curveEaseOut], animations: { view.alpha = 1.0 }) { (over: Bool) in
            let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.tgc_onToHideToastView), userInfo: view, repeats: false)
            objc_setAssociatedObject(view, &TGCTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func tgc_hideErrorView(view: UIView, force: Bool) {
        func clearProperty() {
            view.removeFromSuperview()
            objc_setAssociatedObject(self, &TGCErrorToastView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            objc_setAssociatedObject(self, &TGCErrorTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        if force {
            clearProperty()
        } else {
            UIView.animate(withDuration: TGCToastErrorMoveOutTime, delay: 0.0, options: [.curveEaseIn], animations: {
                let posY = objc_getAssociatedObject(self, &TGCErrorViewOriginBottomY) as! CGFloat
                view.frame.origin.y = posY - view.frame.size.height
            }) { (over: Bool) in
                clearProperty()
            }
        }
    }

    private func tgc_showErrorView(view: UIView, duration: Double) {
        UIView.animate(withDuration: TGCToastErrorMoveInTime, delay: 0, options: [.curveEaseOut], animations: {
            view.frame.origin.y += view.frame.size.height
        }) { (over: Bool) in
            let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.tgc_onToHideErrorToastView), userInfo: view, repeats: false)
            objc_setAssociatedObject(view, &TGCErrorTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func tgc_onToHideToastView(timer: Timer) {
        self.tgc_hideWrapperView(view: timer.userInfo as! UIView, force: false)
    }

    func tgc_onToHideErrorToastView(timer: Timer) {
        self.tgc_hideErrorView(view: timer.userInfo as! UIView, force: false)
    }

    /**
     get a UILabel's max height, with UILabel's width

     - parameter textLabel: the text label
     - parameter width:     the text label's width

     - returns: get the label max height
     */
    func tgc_heightForLabel(textLabel: UILabel, width: CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: textLabel.font!]
        let rect = (textLabel.text! as NSString).boundingRect(with: CGSize(width: width, height: 0), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return rect.height
    }
}
