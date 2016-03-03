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
    
    private var uiWorkspaces: [UIWorkspace]!
    
    @IBAction func groupingModeButtonWasPressed(sender: AnyObject) { delegate.didRequestToggleGroupingMode() }
    
    // TODO: Use TouchpressKit ViewController to handle this
    @IBAction func didPressBackButton(sender: AnyObject) { delegate.didRequestTravelBack() }
    // -----
    
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
        r.addTarget(self, action: Selector("didLassooWithPan:"))
        r.delegate = self
        return r
    }()
    
    override func viewDidLoad() {
        
        /* TODO: Use TouchpressUI to handle this */
        delegate.ready()
    }
}

extension DJViewController: DJUserInterface {
    
    func setUISuite(uiSuite: UISuite) {
        
        uiWorkspaces = uiSuite.sort({ $0.workspaceID > $1.workspaceID })
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
        
        groupingModeButton.setTitle(on ? "Exit Grouping Mode" : "Enter Grouping Mode", forState: .Normal)
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
    
    func createGroup(groupID: GroupID, sourcePerformers: Set<Performer>, sourceGroupIDs: Set<GroupID>) {
                
        let p_views = Set(performer_view_map.filter() { p, v in sourcePerformers.contains(p) }.map({ $0.1 }))
        let g_views = Set(group_view_map.filter() { g, v in sourceGroupIDs.contains(g) }.map({ $0.1 }))
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
        
        UIView.animateWithDuration(1, animations: createGroupAnimation(views), completion: createGroupAnimationCompletion(views, groupID: groupID))
    }
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>) {
        
        let gv = group_view_map[groupID]!
        let points = CGPoint.vogelSpiral(UInt(intoPerformers.count))
        let performers = Array(intoPerformers)
        for i in 0..<points.count {
            let pt = points[i]
            let pr = performers[i]
            let v = newPerformerView()
            view_performer_map[v] = pr
            performer_view_map[pr] = v
            v.center = gv.center
            view.addSubview(v)
            UIView.animateWithDuration(0.5) {
                
                let rect = CGRectInset(self.devicesTrayView.frame, 20, 20)
                v.center = pt.inRelativeCoordinateSpace(gv.center, size: CGSizeMake(75, 75)).inRect(rect)
            }
        }
        gv.removeFromSuperview()
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
    
    @objc private func didPanPerformer(panGesture: UIPanGestureRecognizer) {
        
        let p = view_performer_map[panGesture.view as! PerformerView]!
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
        let p = view_performer_map[pv]!
        
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
        
        let g = view_group_map[panGesture.view as! PerformerView]!
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
        let g = view_group_map[gv]!
        
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
    
    func getWorkspaceIDUnderPanGesture(panGesture: UIPanGestureRecognizer) -> WorkspaceID? {
        
        guard let soundZoneView = getCellUnderPoint(collectionViewPoint: panGesture.locationInView(collectionView))?.soundZoneView else {
            
            return nil
        }
        
        guard soundZoneView.pointIsInsideRings(panGesture.locationInView(soundZoneView)) else {
            
            return nil
        }
        
        return zone_workspace_map[soundZoneView]!.workspaceID
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
        
        pickingAudioStemForSoundZoneView = soundZoneView
        self.presentViewController(audioStemsViewController(), animated: true, completion: nil)
    }
}

extension DJViewController: AudioStemsViewControllerDelegate {
    
    func audioStemsViewControllerDidSelectStem(audioStemsVC: AudioStemsViewController, audioStem: AudioStem) {
        
        audioStemsVC.dismissViewControllerAnimated(true, completion: nil)
        let ws = zone_workspace_map[pickingAudioStemForSoundZoneView]!
        delegate.didRequestAudioStemInWorkspace(audioStem, workspaceID: ws.workspaceID)
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
    
    func groupViewGestureRecongnizers() -> Set<UIGestureRecognizer> {
        
        let pan = UIPanGestureRecognizer(target: self, action: Selector("didPanGroup:"))
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressGroup:")
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        let tap = UITapGestureRecognizer(target: self, action: "didDoubleTapGroup:")
        tap.numberOfTapsRequired = 2
        return Set([longPress, pan, tap])
    }
 
    func newGroupView() -> GroupView {
        
        let v = PerformerView(frame: CGRectZero)
        groupViewGestureRecongnizers().forEach({ v.addGestureRecognizer($0) })
        v.backgroundColor = UIColor.greenColor()
        return v
    }
}

extension DJViewController {
    
    func performerViewGestureRecognizers() -> Set<UIGestureRecognizer> {
        
        let pan = UIPanGestureRecognizer(target: self, action: "didPanPerformer:")
        let longPress = UILongPressGestureRecognizer(target: self, action: "didLongPressPerformer:")
        longPress.delegate = self
        longPress.minimumPressDuration = 0.001
        return Set([pan, longPress])
    }
    
    func newPerformerView() -> PerformerView {
        
        let v = PerformerView(frame: CGRectZero)
        performerViewGestureRecognizers().forEach({ v.addGestureRecognizer($0) })
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

extension DJViewController {
    
    @objc func didLassooWithPan(panGesture: UIPanGestureRecognizer) {
        
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
        
        return Set(p)
    }
    
    private func lassooedGroupIDs() -> Set<GroupID> {
        
        let g = view_group_map
            .filter() { v, g in  (lassoPath!.containsPoint(v.center))}
            .map() { v, g in return g }
        
        return Set(g)
    }
}

extension DJViewController {
    
    private func createGroupAnimation(sourceViews: Set<UIView>) -> () -> () {
        
        let centroid = CGPoint.centroid(sourceViews.map({ $0.center }))
        
        return {
            sourceViews.forEach() {
                $0.center = centroid
            }
        }
    }
    
    private func createGroupAnimationCompletion(sourceViews: Set<UIView>, groupID: GroupID) -> (Bool) -> () {
        
        return { [weak self] done in
            
            guard let this = self else {
                return
            }
            
            sourceViews.forEach() {
                v in v.removeFromSuperview()
            }
            
            let v = this.newGroupView()
            v.center = CGPoint.centroid(sourceViews.map({ $0.center }))
            this.view.addSubview(v)
            this.view_group_map[v] = groupID
            this.group_view_map[groupID] = v
        }
    }
}

extension DJViewController {
    
    /*
    func transform(point: CGPoint, toPoint:CGPoint) -> CGPoint {
        
        if !devicesTrayView.frame.contains(toPoint) {
            
            if let soundZoneView = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(toPoint, fromView: view))?.soundZoneView {
                
                let radius = soundZoneView.frame.size.width * 0.3
                let center = soundZoneView.convertPoint(soundZoneView.center, toView: view)
                let x = point.x + center.x + (point.x * radius)
                let y = point.y + center.y + (point.y * radius)
                print(radius)
                return CGPointMake(x, y)
            }
        }
        
        
        let right = view.bounds.width - toPoint.x
        let permit = CGFloat(100)
        var xadj: CGFloat = 0
        
        if right < permit {
            xadj = permit - right
            print("clip right")
        }
        
        let x = point.x + toPoint.x - xadj + (point.x * 75)
        let y = point.y + toPoint.y + (point.y * 75)
        
        return CGPointMake(x, y)
        
    }
*/
}

    /*
    
    func createGroup(groupID: GroupID, performers: Set<Performer>, groupIDs: Set<GroupID>) {
        
        var p_views = Set<PerformerView>()
        var g_views = Set<GroupView>()
        
        performers.forEach() { p in
            let v = performer_view_map[p]!
            p_views.insert(v)
            performer_view_map[p] = nil
            view_performer_map[v] = nil
        }
        
        groupIDs.forEach() { g in
            let v = group_view_map[g]!
            g_views.insert(v)
            group_view_map[g] = nil
            view_group_map[v] = nil
        }
        
        let sourceViews = p_views.union(g_views)
        
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
                this.view_group_map[v] = groupID
                this.group_view_map[groupID] = v
        }
    }
    
    func destroyGroup(groupID: GroupID, intoPerformers: Set<Performer>) {
        
        let gv = group_view_map[groupID]!
        let points = CGPoint.vogelSpiral(UInt(intoPerformers.count))
        let performers = Array(intoPerformers)
        for i in 0..<points.count {
            let pt = points[i]
            let pr = performers[i]
            let v = newPerformerView()
            view_performer_map[v] = pr
            performer_view_map[pr] = v
            v.center = gv.center
            view.addSubview(v)
            UIView.animateWithDuration(0.5) {
                
                let rect = CGRectInset(self.devicesTrayView.frame, 20, 20)
                v.center = pt.inRelativeCoordinateSpace(gv.center, size: CGSizeMake(75, 75)).inRect(rect)
            }
        }
        gv.removeFromSuperview()
    }
*/
    /*
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
        
        for g in fromGroups {
            
            let wasMerged = toGroups.filter({ g.members.isSubsetOf($0.members)}).count == 1
            
            guard !wasMerged else {
                return
            }
            
            let gv = group_view_map[g]!
            let points = CGPoint.vogelSpiral(UInt(g.members.count))
            let performers = Array(g.members)
            for i in 0..<points.count {
                let pt = points[i]
                let pr = performers[i]
                let v = newPerformerView()
                view_performer_map[v] = pr
                performer_view_map[pr] = v
                v.center = gv.center
                view.addSubview(v)
                UIView.animateWithDuration(0.5) {

                    let rect = CGRectInset(self.devicesTrayView.frame, 20, 20)
                    v.center = pt.inRelativeCoordinateSpace(gv.center, size: CGSizeMake(75, 75)).inRect(rect)
                }
            }
                gv.removeFromSuperview()
        }
    }
*/

extension CGPoint {
    
    static func centroid(points: [CGPoint]) -> CGPoint {
        
        let x = points.reduce(0) { $0 + $1.x } / CGFloat(points.count)
        let y =  points.reduce(0) { $0 + $1.y } / CGFloat(points.count)
        return CGPointMake(x, y)
    }
    
    func inRect(rect: CGRect) -> CGPoint {
        
        if !rect.contains(self) {
            
            var xx = x
            var yy = y
            
            if x < CGRectGetMinX(rect){
                xx = x + (CGRectGetMinX(rect) - x)
            }
                
            else if x > CGRectGetMaxX(rect) {
                xx = x - (x - CGRectGetMaxX(rect))
            }
            
            if y < CGRectGetMinY(rect) {
                yy = y + (CGRectGetMinY(rect) - y)
            }
            
            else if  y > CGRectGetMaxY(rect) {
                yy =  y - (y - CGRectGetMaxY(rect))
            }
        
            return CGPointMake(xx, yy)
            
        }
        
        return self
    }
    
    func inRelativeCoordinateSpace(origin: CGPoint, size: CGSize) -> CGPoint {
        
        let conv_x = x + origin.x + (x * size.width)
        let conv_y = y + origin.y + (y * size.height)
        return CGPointMake(conv_x, conv_y)
    }
    
    static func vogelSpiral(n: UInt) -> [CGPoint] {
        
        let golden = M_PI * (3 - sqrt(5))
        var points: [CGPoint] = []
        for i in 0..<Int(n) {
            let theta = Double(i) * golden
            let r = sqrt(Double(i)) / sqrt(Double(n))
            let x = CGFloat(r * cos(theta))
            let y = CGFloat(r * sin(theta))
            points.append(CGPointMake(x, y))
        }
        return points
    }
}
