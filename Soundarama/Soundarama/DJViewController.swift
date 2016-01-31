//
//  DJViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 27/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJViewController_iPhone: DJViewController { }

class DJViewController_iPad: DJViewController { }

class DJViewController: UIViewController {

    weak var delegate: DJUserInterfaceDelegate!
    
    var audioStems:[AudioStem]!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var devicesTrayView: UIImageView!
    
    private var workspaces: [Workspace]!
    
    // TODO: Use TouchpressKit ViewController to handle this
    @IBAction func didPressBackButton(sender: AnyObject) { delegate.didRequestTravelBack() }
    
    private var performer_view_map: [Performer : UIView] = [ : ]
    
    private var view_performer_map: [UIView : Performer] = [ : ]
    
    private var zone_workspace_map: [SoundZoneView : Workspace] = [ : ]
    
    private var pickingAudioStemForSoundZoneView: SoundZoneView!
    
    private lazy var cells: [SoundZoneCollectionViewCell] = { [unowned self] in
        
        var cells: [SoundZoneCollectionViewCell] = []
        for idx in 0..<self.workspaces.count {
            let ip = NSIndexPath(forRow: idx, inSection: 0)
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath:ip) as! SoundZoneCollectionViewCell
            cells.append(cell)
        }
        return cells
    }()
    
    override func viewDidLoad() {
        
        delegate.ready()
    }
}

extension DJViewController: DJUserInterface {
    
    func setSuite(suite: Suite) {
        
        workspaces = suite.sort({ $0.identifier > $1.identifier})
        collectionView.reloadData()
    }
    
    func addPerformer(performer: Performer) {
        
        guard performer_view_map[performer] == nil else {
            return
        }
        
        let pv = newPerformerView()
        pv.center = newPerformerPoint()
        view.addSubview(pv)
        performer_view_map[performer] = pv
        view_performer_map[pv] = performer
        UIView.animateWithDuration(0.3, animations: { pv.alpha = 1.0 })
    }
    
    func removePerformer(performer: Performer) {
        
        guard let pv = performer_view_map[performer] else {
            return
        }
        
        performer_view_map[performer] = nil
        view_performer_map[pv] = nil

        UIView.animateWithDuration(0.3, animations: {
            pv.alpha = 0.0 }){ done in
                pv.removeFromSuperview()
        }
    }
}

extension DJViewController {
    
    @objc private func didPan(panGesture: UIPanGestureRecognizer) {
        
        playAnimation(panGesture)
        updateViewWithPan(panGesture)
        
        let performerView = panGesture.view as! PerformerView
        let userLetGo = (panGesture.state != .Began) && panGesture.state != UIGestureRecognizerState.Changed
        if userLetGo {
            let performer = view_performer_map[performerView]!
            userDidPlacePerformer(performer, pointInView: panGesture.locationInView(view))
        }
    }
    
    @objc private func didLongPress(pressGesture: UILongPressGestureRecognizer) {
        
        playAnimation(pressGesture)
    }
    
    
    func userDidPlacePerformer(performer: Performer, pointInView: CGPoint) {
        
        let fromWorkspace = workspaces.filter({$0.performers.contains(performer)}).first
        
        guard let soundZoneView = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(pointInView, fromView: view))?.soundZoneView else {
  
            if fromWorkspace != nil {
                delegate.didRequestRemovePerformer(performer, workspace: fromWorkspace!)
            }
            
            print("The performer was placed outside the collection view ")
            return
        }
        
        guard soundZoneView.pointIsInsideRings(view.convertPoint(pointInView, toView: soundZoneView)) else {
            
            if fromWorkspace != nil {
                delegate.didRequestRemovePerformer(performer, workspace: fromWorkspace!)
            }
            
            print("The performer was placed outside the rings of a soundZoneView")
            return
        }
        
        let toWorkspace = zone_workspace_map[soundZoneView]!
        
        guard fromWorkspace != toWorkspace else {
            
            print("The performer was moved inside the rings of the soundZoneView it started in")
            return
        }
        
        print("The performer was placed inside a new soundZoneView")
        delegate.didRequestAddPerformer(performer, workspace: toWorkspace)
        
    }
    
    func getCellUnderPoint(collectionViewPoint point: CGPoint) -> SoundZoneCollectionViewCell? {
        
        let cells = collectionView.visibleCells() as! [SoundZoneCollectionViewCell]
        for c in cells {
            if CGRectContainsPoint(c.frame, point) {
                return c
            }
        }
        return nil
    }
}


extension DJViewController {
    
    private func updateViewWithPan(panGesture: UIPanGestureRecognizer) {
        
        let performerView = panGesture.view as! PerformerView
        let translation = panGesture.translationInView(view)
        performerView.center = CGPoint(x: performerView.center.x + translation.x, y: performerView.center.y + translation.y)
        panGesture.setTranslation(CGPoint.zero, inView: performerView)
        
    }

    func playAnimation(gesture: UIGestureRecognizer) {
        
        let performerView = gesture.view as! PerformerView
        if gesture.state == .Began { playGrowAnimation(performerView) }
        else if gesture.state == .Ended { playShrinkAnimation(performerView) }
    }
    
    func playGrowAnimation(view: UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
            view.transform = CGAffineTransformMakeScale(1.6, 1.6)}, completion: nil)
    }
    
    func playShrinkAnimation(view: UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
            view.transform = CGAffineTransformIdentity }, completion: nil)
    }
}

extension DJViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

extension DJViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = cells[indexPath.row]
        let ws = workspaces[indexPath.row]
        let szv = cell.soundZoneView
        szv.delegate = self
        szv.title = ws.audioStem?.name ?? "EMPTY"
        szv.muteSelected = ws.isMuted
        szv.soloSelected = ws.isSolo
        szv.color = UIColor.darkGrayColor()
        if !ws.isMuted && ws.audioStem != nil && ws.isAntiSolo == false {
            szv.color = ws.audioStem!.colour
            szv.setAlphaRegular()
        }
        if ws.audioStem != nil {
            szv.hideAddStemControl()
        }
        
        zone_workspace_map[cell.soundZoneView] = workspaces[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return workspaces.count
    }
}

extension DJViewController: SoundZoneViewDelegate {
    
    func soundZoneViewDidChangeMuteState(soundZoneView: SoundZoneView) {
        
        let ws = zone_workspace_map[soundZoneView]!
        delegate.didRequestToggleMuteInWorkspace(ws)
    }
    
    func soundZoneViewDidChangeSoloState(soundZoneView: SoundZoneView) {
        
        let ws = zone_workspace_map[soundZoneView]!
        delegate.didRequestToggleSoloInWorkspace(ws)
    }
    
    func soundZoneViewDidRequestStemChange(soundZoneView: SoundZoneView) {
        
        pickingAudioStemForSoundZoneView = soundZoneView
        self.presentViewController(audioStemsViewController(), animated: true, completion: nil)
    }
}

extension DJViewController: AudioStemsViewControllerDelegate {
    
    func audioStemsViewControllerDidSelectStem(audioStemsVC: AudioStemsViewController, audioStem: AudioStem) {
        
        audioStemsVC.dismissViewControllerAnimated(true, completion: nil)
        let ws = zone_workspace_map[pickingAudioStemForSoundZoneView]!
        delegate.didRequestAudioStemInWorkspace(audioStem, workspace: ws)
    }
}


extension DJViewController: AudioStemsViewControllerDataSource {
    
    func audioStemAtIndex(index: Int) -> AudioStem {
        
        return audioStems[index]
    }
    
    func numberOfAudioStems() -> Int {
        
        return audioStems.count
    }
}

extension DJViewController {
    
    func newPerformerView() -> UIView {
        
        let performerView = PerformerView(frame: CGRectZero)
        performerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPan:"))
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        performerView.addGestureRecognizer(longPress)
        return performerView
    }
    
    func newPerformerPoint() -> CGPoint {
        
        let devicesAreaRect = CGRectInset(self.devicesTrayView!.frame, 16.0, 60.0)
        return CGPoint(
                x: CGFloat(Int.random(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(Int.random(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY))))
    }
}

extension DJViewController {
    
    func audioStemsViewController() -> UIViewController {
        
        let vc = AudioStemsViewController(nibName: nil, bundle: nil)
        vc.dataSource = self
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        vc.delegate = self
        return vc
    }
}
