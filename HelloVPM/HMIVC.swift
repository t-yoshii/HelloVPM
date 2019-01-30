//
//  HMIVC.swift
//  HelloVPM
//
//  Created by Takamitsu Yoshii on 2019/01/25.
//  Copyright © 2019年 XevoKK. All rights reserved.
//

import UIKit
import GoogleMaps
import SmartDeviceLink

class HMIVC: UIViewController, SDLTouchManagerDelegate, GMSMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHMIStatus), name: NSNotification.Name.SDLDidChangeHMIStatus, object: nil)
    }

    @objc func onHMIStatus(_ notification: SDLRPCNotificationNotification) {
        guard let onHMIStatus = notification.notification as? SDLOnHMIStatus else {
            return
        }

        if onHMIStatus.hmiLevel == .limited || onHMIStatus.hmiLevel == .full {
            // TODO add first check
            ProxyManager.sharedManager.sdlManager?.streamManager?.touchManager.isTouchEnabled = true
            ProxyManager.sharedManager.sdlManager?.streamManager?.touchManager.touchEventDelegate = self


            let zoominBtnImage = UIImageView(image: UIImage(named: "btn_zoomin_white_normal"))
            let zoominButtonView = FocusableView(frame: CGRect(x: 0, y: 0, width: Int(zoominBtnImage.frame.width), height: Int(zoominBtnImage.frame.height)))
            zoominButtonView.addSubview(zoominBtnImage)

            let zoomInHandler : ((UIView) -> Void) = {[unowned self] view in
                guard let _ = view as? FocusableView else {
                    print("view is not FocusableView")
                    return
                }

                if let mapView = self.view as? GMSMapView {
                    DispatchQueue.main.async {
                        mapView.animate(
                            to: GMSCameraPosition(target: mapView.camera.target,
                                                  zoom: mapView.camera.zoom * 1.1,
                                                  bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle))
                    }
                }

                print("ZoomIn View tapped")
            }

            zoominButtonView.tapHandler = zoomInHandler
            view.addSubview(zoominButtonView)


            let zoomoutBtnImage = UIImageView(image: UIImage(named: "btn_zoomout_white_normal"))
            let zoomoutButtonView = FocusableView(frame: CGRect(x: 0, y: Int(zoominBtnImage.frame.height),
                                                                width: Int(zoomoutBtnImage.frame.width), height: Int(zoominBtnImage.frame.height)))
            zoomoutButtonView.addSubview(zoomoutBtnImage)

            let zoomOutHandler : ((UIView) -> Void) = {[unowned self] view in
                guard let _ = view as? FocusableView else {
                    print("view is not FocusableView")
                    return
                }

                if let mapView = self.view as? GMSMapView {
                    DispatchQueue.main.async {
                        mapView.animate(
                            to: GMSCameraPosition(target: mapView.camera.target,
                                                  zoom: mapView.camera.zoom * 0.9,
                                                  bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle))
                    }
                }

                print("ZoomOut View tapped")
            }

            zoomoutButtonView.tapHandler = zoomOutHandler
            view.addSubview(zoomoutButtonView)

            NotificationCenter.default.post(name: SDLDidUpdateProjectionView, object: nil)
        }
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView

        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    var pinchTargetView: FocusableView?
    var panTargetView: FocusableView?
    func touchManager(_ manager: SDLTouchManager, didReceiveSingleTapFor view: UIView?, at point: CGPoint) {
        print("Tap at \(point)")
        if let view = view as? FocusableView {
            view.onTap()
        } else if let mapView = self.view as? GMSMapView {
            DispatchQueue.main.async {
                let coord = mapView.projection.coordinate(for: point)
                mapView.animate(
                    to: GMSCameraPosition(target: coord, zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle))
            }
        }
    }

    func touchManager(_ manager: SDLTouchManager, panningCanceledAt point: CGPoint) {
        print("Panning canceled at \(point)")
    }

    func touchManager(_ manager: SDLTouchManager, pinchCanceledAtCenter point: CGPoint) {
        print("Pinch canceled at \(point)")
    }

    func touchManager(_ manager: SDLTouchManager, panningDidStartIn view: UIView?, at point: CGPoint) {
        print("Panning did start at \(point)")
        if let view = view as? FocusableView {
            panTargetView = view
            view.onPanStarted()
        }
    }

    func touchManager(_ manager: SDLTouchManager, panningDidEndIn view: UIView?, at point: CGPoint) {
        print("Panning did end at \(point)")
        if let view = view as? FocusableView {
            panTargetView = nil
            view.onPanEnded()
        }
    }

    func touchManager(_ manager: SDLTouchManager, pinchDidEndIn view: UIView?, atCenter point: CGPoint) {
        print("Pinch did end at \(point)")
        if let view = view as? FocusableView {
            pinchTargetView = nil
            view.onPinchEnded()
        }
    }

    func touchManager(_ manager: SDLTouchManager, pinchDidStartIn view: UIView?, atCenter point: CGPoint) {
        print("Pinch did start at \(point)")
        if let view = view as? FocusableView {
            pinchTargetView = view
            view.onPinchStarted()
        }
    }

    func touchManager(_ manager: SDLTouchManager, didReceiveDoubleTapFor view: UIView?, at point: CGPoint) {
        print("Double tap at \(point)")
        if let view = view as? FocusableView {
            view.onDoubleTap()
        }
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePanningFrom fromPoint: CGPoint, to toPoint: CGPoint) {
        print("Did receive panning from \(fromPoint) to \(toPoint)")
        if let view = panTargetView {
            view.onPan(from: fromPoint, to: toPoint)
        } else if let mapView = self.view as? GMSMapView {
            DispatchQueue.main.async {
                let diff = CGPoint(x: mapView.frame.width / 2 - toPoint.x + fromPoint.x,
                                   y: mapView.frame.height / 2 - toPoint.y + fromPoint.y)
                let coord = mapView.projection.coordinate(for: diff)
                mapView.animate(
                    to: GMSCameraPosition(target: coord, zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle))
            }
        }
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePinchAtCenter point: CGPoint, withScale scale: CGFloat) {
        print("Did receive pinch at center \(point) with scale \(scale)")
        if let view = pinchTargetView {
            view.onPinch(withScale: scale)
        }
    }

    func touchManager(_ manager: SDLTouchManager, didReceivePinchIn view: UIView?, atCenter point: CGPoint, withScale scale: CGFloat) {
        print("Did receive pinch in view at center \(point) with scale \(scale)")
        if let view = view as? FocusableView {
            view.onPinch(withScale: scale)
        }
    }

}


class FocusableView: UIView {
    override var canBecomeFocused: Bool {
        return true
    }

    var tapHandler: ((UIView) -> Void)? = nil
    var doubleTapHandler: ((UIView) -> Void)? = nil

    var pinchStartHandler: ((UIView) -> Void)? = nil
    var pinchEndHandler: ((UIView) -> Void)? = nil
    var pinchHandler: ((UIView, CGFloat) -> Void)? = nil

    var panStartHandler: ((UIView) -> Void)? = nil
    var panEndHandler: ((UIView) -> Void)? = nil
    var panHandler: ((UIView, CGPoint, CGPoint) -> Void)? = nil

    func onTap() {
        //print("OnTap")
        if let handler = tapHandler {
            handler(self)
        }
    }

    func onDoubleTap() {
        //print("onDoubleTap")
        if let handler = doubleTapHandler {
            handler(self)
        }
    }

    func onPinchStarted() {
        //print("onPinchStarted")
        if let handler = pinchStartHandler {
            handler(self)
        }
    }

    func onPinchEnded() {
        //print("onPinchEnded")
        if let handler = pinchEndHandler {
            handler(self)
        }
    }

    func onPinch(withScale: CGFloat) {
        //print("onPinch with scale \(withScale)")
        if let handler = pinchHandler {
            handler(self, withScale)
        }
    }

    func onPanStarted() {
        //print("onPanStarted")
        if let handler = panStartHandler {
            handler(self)
        }
    }

    func onPan(from: CGPoint, to: CGPoint) {
        //print("onPan from \(from) to \(to)")
        if let handler = panHandler {
            handler(self, from, to)
        }
    }

    func onPanEnded() {
        //print("onPanEnded")
        if let handler = panEndHandler {
            handler(self)
        }
    }
}
