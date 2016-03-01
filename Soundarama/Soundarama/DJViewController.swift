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
    
    @IBOutlet weak var groupingModeButton: UIButton!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var devicesTrayView: UIImageView!
    
    private var workspaces: [Workspace]!
    
    @IBAction func groupingModeButtonWasPressed(sender: AnyObject) { delegate.didRequestToggleGroupingMode() }
    
    // TODO: Use TouchpressKit ViewController to handle this
    @IBAction func didPressBackButton(sender: AnyObject) { delegate.didRequestTravelBack() }
    // -----
    
    private var group_view_map: [Group : GroupView] = [ : ]
    
    private var view_group_map: [GroupView : Group] = [ : ]
    
    private var performer_view_map: [Performer : PerformerView] = [ : ]
    
    private var view_performer_map: [PerformerView : Performer] = [ : ]
    
    private var zone_workspace_map: [SoundZoneView : Workspace] = [ : ]
    
    private var pickingAudioStemForSoundZoneView: SoundZoneView!
    
    private var lassoPath: UIBezierPath?
    
    private lazy var lassoShapeLayer: CAShapeLayer = {
        
        let l = CAShapeLayer()
        l.lineWidth = 3.0
        l.strokeColor = UIColor.whiteColor().CGColor
        l.lineDashPattern = [ 5, 9 ]
        l.fillColor = UIColor.clearColor().CGColor
        return l
    }()
    
    private lazy var cells: [SoundZoneCollectionViewCell] = { [unowned self] in
        
        var cells: [SoundZoneCollectionViewCell] = []
        for idx in 0..<self.workspaces.count {
            let ip = NSIndexPath(forRow: idx, inSection: 0)
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath:ip) as! SoundZoneCollectionViewCell
            cells.append(cell)
        }
        return cells
    }()
    
    private lazy var viewPanGestureRecognizer: UIPanGestureRecognizer = {
       
        let r = UIPanGestureRecognizer()
        r.addTarget(self, action: Selector("didPanView:"))
        return r
    }()
    
    override func viewDidLoad() {
        
        /* TODO: Use TouchpressUI to handle this */
        delegate.ready()
        
        view.addGestureRecognizer(viewPanGestureRecognizer)
        view.layer.addSublayer(lassoShapeLayer)
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
    
    func changeGroups(fromGroups: Set<Group>, toGroups: Set<Group>) {
        
        for g in toGroups {
            
            let subgroups = group_view_map.filter({ g2, v in  g2.members.intersect(g.members).count != 0})
            let performers = performer_view_map.filter(){ p, v in g.members.contains(p)}
            
            subgroups.forEach() { g, v in
                group_view_map[g] = nil
                view_group_map[v] = nil
            }
            
            performers.forEach() { p, v in
                performer_view_map[p] = nil
                view_performer_map[v] = nil
            }
            
            let sourceViews = Set(subgroups.map({$1})).union(Set(performers.map({$1})))
            
            let centroid_x = sourceViews.reduce(0) { return $0 + $1.center.x } / CGFloat(sourceViews.count)
            let centroid_y = sourceViews.reduce(0) { return $0 + $1.center.y } / CGFloat(sourceViews.count)
            let centroid = CGPointMake(centroid_x, centroid_y)
            
            UIView.animateWithDuration(1, animations: {
                sourceViews.forEach() { v in v.center = centroid }
                }) { [weak self]  done in
                    
                    guard let this = self else {
                        return
                    }
                    
                    sourceViews.forEach() {
                        v in v.removeFromSuperview()
                    }
                    
                    let v = this.newGroupView()
                    v.center = centroid
                    this.view.addSubview(v)
                    this.view_group_map[v] = g
                    this.group_view_map[g] = v
            }
        }
    }
    
    func enterGroupingMode() {
        
        groupingModeButton.setTitle("Exit Grouping Mode", forState: .Normal)
    }
    
    func exitGroupingMode() {
        
        groupingModeButton.setTitle("Exit Grouping Mode", forState: .Normal)
    }
}

extension DJViewController {
    
    @objc func didPanView(panGesture: UIPanGestureRecognizer) {
    
        let point = panGesture.locationInView(view)
        
        switch panGesture.state {
            
            case .Began:
        
                lassoPath = UIBezierPath()
                lassoPath?.moveToPoint(point)
            
            case .Changed:
                
                lassoPath?.addLineToPoint(point)
            
            case .Ended:
                
                lassoPath?.addLineToPoint(point)
                lassoPath?.closePath()
                let p = Set(view_performer_map.filter() { v, p in  (lassoPath!.containsPoint(v.center))}.map( { v, p in return p }))
                let g = Set(view_group_map.filter() { v, p in  (lassoPath!.containsPoint(v.center))}.map( { v, p in return p }))
                if p.count + g.count > 0 {
                    delegate.didRequestCreateGroup(p, groups: g)
                }
                lassoPath = nil
            default:
                return
            }
        
        lassoShapeLayer.path = lassoPath?.CGPath
    }
}

extension DJViewController {
    
    @objc private func didPanPerformer(panGesture: UIPanGestureRecognizer) {
        
        let performerView = panGesture.view as! PerformerView
        let performer = view_performer_map[performerView]!
        
        playSelectionAnimation(panGesture, view: performerView)
        updateViewWithPan(panGesture)
        
        if (panGesture.state != .Began) && panGesture.state != UIGestureRecognizerState.Changed {
            userDidPlacePerformer(performer, pointInView: panGesture.locationInView(view))
            viewPanGestureRecognizer.enabled = true
        }
    }
    
    @objc private func didLongPressPerformer(pressGesture: UILongPressGestureRecognizer) {
        
        if  pressGesture.state == .Began {
            viewPanGestureRecognizer.enabled = false
        }
        playSelectionAnimation(pressGesture, view: pressGesture.view!)
    }
}

extension DJViewController {
    
    func userDidPlaceGroup(group: Group, pointInView: CGPoint) {
    
        let fromWorkspace = workspaces.filter({ $0.performers.contains(group.members.first!)}).first
        
        guard let soundZoneView = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(pointInView, fromView: view))?.soundZoneView else {
            
            if let fws = fromWorkspace {
                delegate.didRequestRemoveGroup(group, workspaceID: fws.identifier)
            }
            
            print("The performer was placed outside the collection view ")
            return
        }
        
        guard soundZoneView.pointIsInsideRings(view.convertPoint(pointInView, toView: soundZoneView)) else {
            
            if let fws = fromWorkspace {
                delegate.didRequestRemoveGroup(group, workspaceID: fws.identifier)
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
        delegate.didRequestAddGroup(group, workspaceID: toWorkspace.identifier)
        
    }
    
    func userDidPlacePerformer(performer: Performer, pointInView: CGPoint) {
        
        let fromWorkspace = workspaces.filter({$0.performers.contains(performer)}).first
        
        guard let soundZoneView = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(pointInView, fromView: view))?.soundZoneView else {
            
            if let fws = fromWorkspace {
                delegate.didRequestRemovePerformer(performer, workspaceID: fws.identifier)
            }
            
            print("The performer was placed outside the collection view ")
            return
        }
        
        guard soundZoneView.pointIsInsideRings(view.convertPoint(pointInView, toView: soundZoneView)) else {
            
            if let fws = fromWorkspace {
                delegate.didRequestRemovePerformer(performer, workspaceID: fws.identifier)
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
        delegate.didRequestAddPerformer(performer, workspaceID: toWorkspace.identifier)
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
    
    @objc func didDoubleTapGroup(tapGesture: UITapGestureRecognizer) {
    
        print("double tapped")
    }
    
    @objc private func didPanGroup(panGesture: UIPanGestureRecognizer) {
        
        let groupView = panGesture.view as! GroupView
        
        playSelectionAnimation(panGesture, view: groupView)
        updateViewWithPan(panGesture)
        
        if (panGesture.state != .Began) && panGesture.state != UIGestureRecognizerState.Changed {
            let group = view_group_map[groupView]!
            userDidPlaceGroup(group, pointInView: panGesture.locationInView(view))
            viewPanGestureRecognizer.enabled = true
        }
    }
    
    @objc private func didLongPressGroup(pressGesture: UILongPressGestureRecognizer) {
        
        if  pressGesture.state == .Began {
            viewPanGestureRecognizer.enabled = false
        }
        playSelectionAnimation(pressGesture, view: pressGesture.view!)
    }
}


extension DJViewController {
    
    private func updateViewWithPan(panGesture: UIPanGestureRecognizer) {
        
        let performerView = panGesture.view as! PerformerView
        let translation = panGesture.translationInView(view)
        performerView.center = CGPoint(x: performerView.center.x + translation.x, y: performerView.center.y + translation.y)
        panGesture.setTranslation(CGPoint.zero, inView: performerView)
        
    }

    func playSelectionAnimation(gesture: UIGestureRecognizer, view: UIView) {
        
        if gesture.state == .Began { playGrowAnimation(view) }
        else if gesture.state == .Ended { playShrinkAnimation(view) }
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
        delegate.didRequestToggleMuteInWorkspace(ws.identifier)
    }
    
    func soundZoneViewDidChangeSoloState(soundZoneView: SoundZoneView) {
        
        let ws = zone_workspace_map[soundZoneView]!
        delegate.didRequestToggleSoloInWorkspace(ws.identifier)
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
        delegate.didRequestAudioStemInWorkspace(audioStem, workspaceID: ws.identifier)
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
    
    func newPerformerView() -> PerformerView {
        
        let v = PerformerView(frame: CGRectZero)
        v.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPanPerformer:"))
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressPerformer:")
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        v.addGestureRecognizer(longPress)
        return v
    }
    
    func newGroupView() -> GroupView {
        
        let v = PerformerView(frame: CGRectZero)
        v.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPanGroup:"))
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressGroup:")
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        v.addGestureRecognizer(longPress)
        let tgr = UITapGestureRecognizer(target: self, action: "didDoubleTapGroup:")
        tgr.numberOfTapsRequired = 2
        v.addGestureRecognizer(tgr)
        v.backgroundColor = UIColor.greenColor()
        return v
    }
    
    func newPerformerPoint() -> CGPoint {
        
        let devicesAreaRect = CGRectInset(self.devicesTrayView!.frame, 16.0, 60.0)
        return CGPoint(
                x: CGFloat(Int.random(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(Int.random(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY))))
    }
}

extension DJViewController {
    
    /* TODO: Move this into DJWireframe and call via UI delegate method */
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
