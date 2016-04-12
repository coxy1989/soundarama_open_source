//
//  DJViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 27/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class DJViewController_iPhone: DJViewController { }

class DJViewController_iPad: DJViewController { }

class DJViewController: ViewController {

    weak var delegate: DJUserInterfaceDelegate!
    
    @IBOutlet weak var broadcastingButton: UIButton!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var devicesTrayView: UIImageView!
    
    private var uiWorkspaces: [UIWorkspace]!
    
    @IBAction func didPressBroadcastingButton(sender: AnyObject) { delegate.didRequestConfigureBroadcast() }
    
    @IBAction func didPressBackButton(sender: AnyObject) { userInterfaceDelegate?.userInterfaceDidNavigateBack(self) }
    
    private var group_view_map: [GroupID : GroupView] = [ : ]
    
    private var view_group_map: [GroupView : GroupID] = [ : ]
    
    private var performer_view_map: [Performer : PerformerView] = [ : ]
    
    private var view_performer_map: [PerformerView : Performer] = [ : ]
    
    private var zone_workspace_map: [SoundZoneView : UIWorkspace] = [ : ]
    
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
        for idx in 0..<self.uiWorkspaces.count {
            let ip = NSIndexPath(forRow: idx, inSection: 0)
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath:ip) as! SoundZoneCollectionViewCell
            cells.append(cell)
        }
        return cells
    }()
    
    private lazy var viewPanGestureRecognizer: UIPanGestureRecognizer = {
       
        let r = UIPanGestureRecognizer()
        r.addTarget(self, action: #selector(DJViewController.didLassooWithPan(_:)))
        r.delegate = self
        return r
    }()
}

extension DJViewController: DJUserInterface {
    
    func setBroadcastingStatusMessage(message: String) {
        
        broadcastingButton.setTitle(message, forState: .Normal)
    }
    
    func setUISuite(uiSuite: UISuite) {
        
        uiWorkspaces = uiSuite.sort({ $0.workspaceID > $1.workspaceID })
        collectionView.reloadData()
    }
    
    func addPerformer(performer: Performer) {
        
        guard performer_view_map[performer] == nil else {
            return
        }
        
        let pv = newPerformerView()
        pv.center = randomDeviceTrayPoint()
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
    
    func selectPerformer(performer: Performer) {
        
        let v = performer_view_map[performer]!
        playGrowAnimation(v)
    }
    
    func movePerformer(performer: Performer, translation: CGPoint) {
        
        let v = performer_view_map[performer]!
        v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
    }
    
    func deselectPerformer(performer: Performer) {
        
        let v = performer_view_map[performer]!
        playShrinkAnimation(v)
    }
    
    func setGroupingMode(on: Bool) {
        
        if on {
            view.addGestureRecognizer(viewPanGestureRecognizer)
            view.layer.addSublayer(lassoShapeLayer)
        }
            
        else {
            view.removeGestureRecognizer(viewPanGestureRecognizer)
            lassoShapeLayer.removeFromSuperlayer()
        }
    }
    
    func startLassoo(atPoint: CGPoint) {
        
        lassoPath = UIBezierPath()
        lassoPath!.moveToPoint(atPoint)
    }
    
    func continueLasoo(toPoint: CGPoint) {
        
        lassoPath?.addLineToPoint(toPoint)
    }
    
    func endLasoo(atPoint: CGPoint) {
        
        lassoPath?.addLineToPoint(atPoint)
        lassoPath?.closePath()
        delegate.didRequestCreateGroup(lassooedPerformers(), groupIDs: lassooedGroupIDs())
        lassoPath = nil
    }
    
    func createGroup(groupID: GroupID, groupSize: UInt, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>) {
                
        let p_views = Set(performer_view_map.filter() { p, v in sourcePerformers.contains(p) }.map({ $0.1 as UIView }))
        let g_views = Set(group_view_map.filter() { g, v in sourceGroupIDs.contains(g) }.map({ $0.1 as UIView }))
        let views = p_views.union(g_views)
        
        sourcePerformers.forEach() { p in
            let v = performer_view_map[p]!
            performer_view_map[p] = nil
            view_performer_map[v] = nil
        }
        
        sourceGroupIDs.forEach() { g in
            let v = group_view_map[g]!
            group_view_map[g] = nil
            view_group_map[v] = nil
        }
        
        let in_tray = Set(views.filter({ devicesTrayView.frame.contains($0.center) }))
        
        if in_tray.count == views.count {
            
            /* All the views in the animation are in the devicesTrayView */
            
            UIView.animateWithDuration(1, animations: moveViewsToCentroid(views), completion: createGroupAnimationCompletion(views, groupID: groupID, groupSize: groupSize))
        }
        
        else if in_tray.count != 0 {
            
            /* At least one of the views in the animation is in the devicesTrayView */
            
            UIView.animateWithDuration(1, animations: moveViewsToView(views, stationaryView: in_tray.first!), completion: createGroupAnimationCompletion(views, groupID: groupID, groupSize: groupSize))
        }
        
        else {
            
            /* none of the views in the animation are in the devicesTrayView */
            
            let view = g_views.count > 0 ? g_views.first! : views.first!
            
            UIView.animateWithDuration(1, animations: moveViewsToView(views, stationaryView: view), completion: createGroupAnimationCompletion(views, groupID: groupID, groupSize: groupSize))
        }
    }
    
    func addPerformerView(point pt: CGPoint, performer per: Performer, performerView vw: PerformerView) {
        
            view_performer_map[vw] = per
            performer_view_map[per] = vw
            vw.center = pt
            view.addSubview(vw)
    }
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>) {
        
        let gv = group_view_map[groupID]!
        group_view_map[groupID] = nil
        view_group_map[gv] = nil
        
        guard let cell = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(gv.center, fromView: view)) else {
            
            /* Animation is occurring in the device tray */
            
            destroyGroupViewInDeviceTray(gv, intoPerformers: intoPerformers)
            return
        }
        
        guard cell.soundZoneView.pointIsInsideRings(cell.soundZoneView.convertPoint(gv.center, fromView: view)) else {
            
            /* Animation is occuring outsize the rings of a workspace */
            
            destroyGroupViewOutsideSoundZoneView(gv, intoPerformers: intoPerformers)
            return
        }
        
        /* Animation is occuring inside the rings of a workspace */
        
        destroyGroupviewInsideSoundZoneView(gv, soundZoneView: cell.soundZoneView, intoPerformers: intoPerformers)
        
    }
    
    func selectGroup(groupID: GroupID) {
     
        let v = group_view_map[groupID]!
        playGrowAnimation(v)
    }
    
    func deselectGroup(groupID: GroupID) {
        
        let v = group_view_map[groupID]!
        playShrinkAnimation(v)
    }
    
    func moveGroup(groupID: GroupID, translation: CGPoint) {
     
        let v = group_view_map[groupID]!
        v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
    }
}

extension DJViewController {
    
    private func getWorkspaceIDUnderPanGesture(panGesture: UIPanGestureRecognizer) -> WorkspaceID? {
        
        guard let soundZoneView = getCellUnderPoint(collectionViewPoint: panGesture.locationInView(collectionView))?.soundZoneView else {
            
            return nil
        }
        
        guard soundZoneView.pointIsInsideRings(panGesture.locationInView(soundZoneView)) else {
            
            return nil
        }
        
        return zone_workspace_map[soundZoneView]!.workspaceID
    }
    
    private func getCellUnderPoint(collectionViewPoint point: CGPoint) -> SoundZoneCollectionViewCell? {
        
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
    
    @objc private func didPanPerformer(panGesture: UIPanGestureRecognizer) {
        
        guard let p = view_performer_map[panGesture.view as! PerformerView] else {
            
            print("Warning. This is an odd state (didPanPerformer:)")
            return
        }
        let t = panGesture.translationInView(view)
        
        if panGesture.state == .Changed {
            
            delegate.didRequestMovePerformer(p, translation: t)
            panGesture.setTranslation(CGPoint.zero, inView: panGesture.view)
        }
        
        if panGesture.state == .Ended {
            
            guard let workspaceID = getWorkspaceIDUnderPanGesture(panGesture) else {
                delegate.didRequestRemovePerformerFromWorkspace(p)
                return
            }
            
            delegate.didRequestAddPerformerToWorkspace(p, workspaceID: workspaceID)
        }
    }
    
    @objc private func didLongPressPerformer(pressGesture: UILongPressGestureRecognizer) {
        
        let pv = pressGesture.view as! PerformerView
        
        guard let p = view_performer_map[pv] else {
            
            print("Warning: This is an odd state (didLongPressPerformer:)")
            return
        }
        
        if pressGesture.state == .Began {
            delegate.didRequestSelectPerformer(p)
        }
        
        if pressGesture.state == .Ended {
            delegate.didRequestDeselectPerformer(p)
        }
    }
}

extension DJViewController {
    
    @objc private func didPanGroup(panGesture: UIPanGestureRecognizer) {
        
        guard let g = view_group_map[panGesture.view as! GroupView] else {
            
            print("Warning. This is an odd state (didPanGroup:)")
            return
        }
        
        let t = panGesture.translationInView(view)
        
        if panGesture.state == .Changed {
            
            delegate.didRequestMoveGroup(g, translation: t)
            panGesture.setTranslation(CGPoint.zero, inView: panGesture.view)
        }
        
        if panGesture.state == .Ended {
            
            guard let workspaceID = getWorkspaceIDUnderPanGesture(panGesture) else {
                delegate.didRequestRemoveGroupFromWorkspace(g)
                return
            }
            
            delegate.didRequestAddGroupToWorkspace(g, workspaceID: workspaceID)
        }
    }

    @objc private func didLongPressGroup(pressGesture: UILongPressGestureRecognizer) {

        let gv = pressGesture.view as! GroupView
        guard let g = view_group_map[gv] else {
            
            print("Warning. This is an odd state (didLongPressGroup:)")
            return
        }
        
        if pressGesture.state == .Began {
            delegate.didRequestSelectGroup(g)
        }
        
        if pressGesture.state == .Ended {
            delegate.didRequestDeselectGroup(g)
        }
    }
    
    @objc private func didDoubleTapGroup(tapGesture: UITapGestureRecognizer) {
    
        let v = tapGesture.view as! GroupView
        let g = view_group_map[v]!
        delegate.didRequestDestroyGroup(g)
    }
}

extension DJViewController {
    
    private func playGrowAnimation(view: UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
            view.transform = CGAffineTransformMakeScale(1.6, 1.6)}, completion: nil)
    }
    
    private func playShrinkAnimation(view: UIView) {
        
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

        let ws = uiWorkspaces[indexPath.row]
        let cell = configureSoundZoneCollectionViewCell(cells[indexPath.row], uiworkspace: ws)
        zone_workspace_map[cell.soundZoneView] = uiWorkspaces[indexPath.row]
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return uiWorkspaces.count
    }
    
    func configureSoundZoneCollectionViewCell(cell: SoundZoneCollectionViewCell, uiworkspace ws: UIWorkspace) -> SoundZoneCollectionViewCell {
        
        let szv = cell.soundZoneView
        szv.delegate = self
        szv.title = ws.title ?? "EMPTY"
        szv.muteSelected = ws.muteSelected
        szv.soloSelected = ws.soloSelected
        szv.color = UIColor.darkGrayColor()
        if !ws.muteSelected && ws.color != nil && ws.antiSoloSelected == false {
            szv.color = ws.color!
            szv.setAlphaRegular()
        }
        if ws.hasAudio {
            szv.hideAddStemControl()
        }
        return cell
    }
}

extension DJViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var w: CGFloat = 0, h: CGFloat = 0
        
        if uiWorkspaces.count == 4 {
        
            let total_height = view.bounds.size.height - CGRectGetHeight(devicesTrayView.bounds)
            let total_width = CGRectGetWidth(view.bounds)
            
                w = (total_width - 12) * 0.5
                h = (total_height - 12) * 0.5
                return CGSizeMake(w,h)
        }
        
        else if uiWorkspaces.count == 9 {
        
            let total_height = view.bounds.size.height
            let total_width = CGRectGetWidth(view.bounds) - CGRectGetWidth(devicesTrayView.bounds)
            
            w = (total_width - 12) * (1/3)
            h = (total_height - 12) * (1/3)
            
            return CGSizeMake(w,h)
        }
    
        assert(false, "Unsupported UIWorkspace configuration: got \(uiWorkspaces.count), expected 4 or 9")
        return CGSizeMake(0, 0)
    }
}

extension DJViewController: SoundZoneViewDelegate {
    
    func soundZoneViewDidChangeMuteState(soundZoneView: SoundZoneView) {
        
        let ws = zone_workspace_map[soundZoneView]!
        delegate.didRequestToggleMuteInWorkspace(ws.workspaceID)
    }
    
    func soundZoneViewDidChangeSoloState(soundZoneView: SoundZoneView) {
        
        let ws = zone_workspace_map[soundZoneView]!
        delegate.didRequestToggleSoloInWorkspace(ws.workspaceID)
    }
    
    func soundZoneViewDidRequestStemChange(soundZoneView: SoundZoneView) {
        
        let uiws = zone_workspace_map[soundZoneView]!
        delegate.didRequestAudioStemChangeInWorkspace(uiws.workspaceID)
    }
}

extension DJViewController {
    
    private func groupViewGestureRecongnizers() -> Set<UIGestureRecognizer> {
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DJViewController.didPanGroup(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(DJViewController.didLongPressGroup(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.075
        let tap = UITapGestureRecognizer(target: self, action: #selector(DJViewController.didDoubleTapGroup(_:)))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        return Set([longPress, pan, tap])
    }
 
    private func newGroupView(size: UInt) -> GroupView {
        
        let v = GroupView(frame: CGRectZero)
        groupViewGestureRecongnizers().forEach({ v.addGestureRecognizer($0) })
        v.label.text = "\(size)"
        return v
    }
}

extension DJViewController {
    
    private func performerViewGestureRecognizers() -> Set<UIGestureRecognizer> {
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DJViewController.didPanPerformer(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(DJViewController.didLongPressPerformer(_:)))
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        return Set([pan, longPress])
    }
    
    private func newPerformerView() -> PerformerView {
        
        let v = PerformerView(frame: CGRectZero)
        performerViewGestureRecognizers().forEach({ v.addGestureRecognizer($0) })
        return v
    }
    
    private func randomDeviceTrayPoint() -> CGPoint {
        
        let devicesAreaRect = CGRectInset(self.devicesTrayView!.frame, 16.0, 60.0)
        return CGPoint(
                x: CGFloat(Int.random(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(Int.random(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY))))
    }
}

extension DJViewController {
    
    @objc private func didLassooWithPan(panGesture: UIPanGestureRecognizer) {
        
        let point = panGesture.locationInView(view)
        
        switch panGesture.state {
            
            case .Began:
                delegate.didRequestStartLassoo(point)
            case .Changed:
                delegate.didRequestContinueLasoo(point)
            case .Ended:
                delegate.didRequestEndLasoo(point)
                lassoPath = nil
            default:
                return
            }
        
        lassoShapeLayer.path = lassoPath?.CGPath
    }

    private func lassooedPerformers() -> Set<Performer> {
        
        let p = view_performer_map
            .filter() { v, p in(lassoPath!.containsPoint(v.center) )}
            .map() { v, p in return p }
        
        print("lasooed performers: \(p)")
        return Set(p)
    }
    
    private func lassooedGroupIDs() -> Set<GroupID> {
        
        let g = view_group_map
            .filter() { v, g in  (lassoPath!.containsPoint(v.center))}
            .map() { v, g in return g }

        print("lasooed groups: \(g)")
        return Set(g)
    }
}

extension DJViewController {
    
    private func destroyGroupViewOutsideSoundZoneView(groupView: GroupView, intoPerformers: Set<Performer>) {
        
        intoPerformers.forEach() { performer in
            
            let v = newPerformerView()
            addPerformerView(point: groupView.center, performer: performer, performerView: v)
            let pt = randomDeviceTrayPoint()
            UIView.animateWithDuration(0.5) {
                v.center = pt
            }
        }
        
        groupView.removeFromSuperview()
    }
    
    private func destroyGroupViewInDeviceTray(groupView: GroupView, intoPerformers: Set<Performer>) {
        
        let views = intoPerformers.map({ _ in newPerformerView() })
        let points = CGPoint.vogelSpiral(UInt(intoPerformers.count))
        
        intoPerformers.enumerate().forEach() { index, performer in
            
            addPerformerView(point: groupView.center, performer: performer, performerView: views[index])
            animateDestructionInDeviceTray(views[index], fromCenter: groupView.center, toCenter: points[index])
        }
        
        groupView.removeFromSuperview()
    }
    
    private func destroyGroupviewInsideSoundZoneView(groupView: GroupView, soundZoneView: SoundZoneView, intoPerformers: Set<Performer>) {
        
        let views = intoPerformers.map({ _ in newPerformerView() })
        let points = CGPoint.vogelSpiral(UInt(intoPerformers.count))
        
        intoPerformers.enumerate().forEach() { index, performer in
            
            addPerformerView(point: groupView.center, performer: performer, performerView: views[index])
            animateDestructionInSoundZoneView(views[index], soundZoneView: soundZoneView, toCenter: points[index])
        }
        
        groupView.removeFromSuperview()
    }
    
    
    private func animateDestructionInDeviceTray(performerView: UIView, fromCenter: CGPoint, toCenter: CGPoint) {
        
        UIView.animateWithDuration(0.5) { [weak self] in
            
            guard let this = self else {
                return
            }
            
            let rect = CGRectInset(this.devicesTrayView.frame, 20, 20)
            performerView.center = toCenter.inRelativeCoordinateSpace(fromCenter, size: CGSizeMake(75, 75)).inRect(rect)
        }
    }
    
    private func animateDestructionInSoundZoneView(performerView: PerformerView, soundZoneView: SoundZoneView, toCenter: CGPoint) {
        
        UIView.animateWithDuration(0.5) { [weak self] in
            
            guard let this = self else { return }
            
            let rect = soundZoneView.convertRect(soundZoneView.frame, toView:this.view)
            performerView.center = toCenter.inRelativeCoordinateSpace(this.view.convertPoint(soundZoneView.center, fromView: soundZoneView), size: CGSizeMake(75, 75)).inRect(rect)
        }
    }
}


extension DJViewController {
    
    private func moveViewsToCentroid(sourceViews: Set<UIView>) -> () -> () {
        
        let centroid = CGPoint.centroid(sourceViews.map({ $0.center }))
        
        return {
            sourceViews.forEach() {
                $0.center = centroid
            }
        }
    }
    
    private func moveViewsToView(sourceViews: Set<UIView>, stationaryView: UIView) -> () -> () {
        
        return { sourceViews.forEach() { $0.center =  stationaryView.center } }
    }
    
    private func createGroupAnimationCompletion(sourceViews: Set<UIView>, groupID: GroupID, groupSize: UInt) -> (Bool) -> () {
        
        return { [weak self] done in
            
            guard let this = self else {
                return
            }
            
            sourceViews.forEach() {
                v in v.removeFromSuperview()
            }
            
            let v = this.newGroupView(groupSize)
            v.center = CGPoint.centroid(sourceViews.map({ $0.center }))
            this.view.addSubview(v)
            this.view_group_map[v] = groupID
            this.group_view_map[groupID] = v
        }
    }
}

