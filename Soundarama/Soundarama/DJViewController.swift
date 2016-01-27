//
//  DJViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 27/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJViewController: UIViewController {

    weak var delegate: DJUserInterfaceDelegate!
    
    weak var dataSource: DJUserInterfaceDataSource!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var devicesTrayView: UIImageView!
    
    private var performer_performerView_map: [Performer : PerformerView] = [ : ]
    
    private var performerView_performer_map: [PerformerView : Performer] = [ : ]
    
    private var performer_soundZoneView_map: [Performer : SoundZoneView] = [ : ]
    
    private var soundZoneView_audioStem_map: [SoundZoneView : AudioStem] = [ : ]
    
    private var soundZoneView_performer_map: [SoundZoneView : Performer] = [ : ]
    
    private var audioStemsVC_soundZoneView_map : [AudioStemsViewController : SoundZoneView] = [ : ]
    
    private var audioStems: [AudioStem]!
    
    private var soloingSoundZoneViews: Set<SoundZoneView> = Set()
    
    override func viewDidLoad() {
        
        audioStems = dataSource.audioStems()
        delegate.ready()
    }
}

extension DJViewController: DJUserInterface {
    
    func addPerformer(performer: Performer) {
        
        guard performer_performerView_map[performer] == nil else {
            return
        }
        
        let performerView = PerformerView(frame: CGRectZero)
        performerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "didPan:"))
        performerView.center = newPerformerPoint()
        view.addSubview(performerView)
        performer_performerView_map[performer] = performerView
        performerView_performer_map[performerView] = performer
        UIView.animateWithDuration(0.3, animations: { performerView.alpha = 1.0 })
    }
    
    func removePerformer(performer: Performer) {
        
        guard let performerView = performer_performerView_map[performer] else {
            return
        }
        
        performer_performerView_map[performer] = nil
        performerView_performer_map[performerView] = nil
        UIView.animateWithDuration(0.3, animations: {
            performerView.alpha = 0.0 }){ done in
                performerView.removeFromSuperview()
        }
    }
}

extension DJViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SoundZoneCollectionViewCell
        cell.soundZoneView.delegate = self
        return cell
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 9
    }
}

extension DJViewController: SoundZoneViewDelegate {
    
    func soundZoneViewDidChangeMuteState(soundZoneView: SoundZoneView) {
        
        // Update model
        
        // check effective mute state and call delegate if changed
    }
    
    func soundZoneViewDidChangeSoloState(soundZoneView: SoundZoneView) {
        
        if soundZoneView.isSolo {
            soloingSoundZoneViews.insert(soundZoneView)
        } else {
            soloingSoundZoneViews.remove(soundZoneView)
        }
        
        // check effective mute state and call delegate if changed
    }
    
    func soundZoneViewDidPressAddNewStemButton(soundZoneView: SoundZoneView) {
        
        presentAudioStemPicker(soundZoneView)
    }
}

extension DJViewController: AudioStemsViewControllerDelegate {
    
    
    func audioStemsViewControllerDidSelectStem(audioStemsVC: AudioStemsViewController, audioStem: AudioStem) {
        
        audioStemsVC.dismissViewControllerAnimated(true, completion: nil)
        
        guard let szv = audioStemsVC_soundZoneView_map[audioStemsVC] else {
            return
        }
        
        audioStemsVC_soundZoneView_map[audioStemsVC] = nil
        soundZoneView_audioStem_map[szv] = audioStem
        
        for pair in soundZoneView_performer_map where pair.0 == szv {
            
            //delegate.didSelectAudioStemForPerformer(audioStem, performer: pair.1, muted: szv.muted)
        }
        
        szv.audioStem = audioStem
        
        //TODO: Remove SoundZoneView dependecy on audioStem
        //TODO: Volume
    }
}

extension DJViewController {
    
    private func presentAudioStemPicker(soundZoneView: SoundZoneView) {
        
        
        /* TODO: 
            - Storyboard this controller 
            - Blurred background
        */
        let vc = AudioStemsViewController(nibName: nil, bundle: nil)
        audioStemsVC_soundZoneView_map[vc] =  soundZoneView
        vc.audioStems = audioStems
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

extension DJViewController {
    
    func newPerformerPoint() -> CGPoint {
        
        /* TODO: Move this to an Int extension */
        
        func randomInt(min: Int, max:Int) -> Int {
            
            return min + Int(arc4random_uniform(UInt32(max - min + 1)))
        }
        
        let devicesAreaRect = CGRectInset(self.devicesTrayView!.frame, 16.0, 60.0)
        return CGPoint(
                x: CGFloat(randomInt(Int(devicesAreaRect.minX), max: Int(devicesAreaRect.maxX))),
                y: CGFloat(randomInt(Int(devicesAreaRect.minY), max: Int(devicesAreaRect.maxY))))
    }
    
}

extension DJViewController {
    
    private func updateView(panGesture: UIPanGestureRecognizer) {
        
        let performerView = panGesture.view as! PerformerView
        if panGesture.state == .Began { playGrowAnimation(performerView) }
        else if panGesture.state == .Ended { playShrinkAnimation(performerView) }
        
        let translation = panGesture.translationInView(view)
        performerView.center = CGPoint(x: performerView.center.x + translation.x, y: performerView.center.y + translation.y)
        panGesture.setTranslation(CGPoint.zero, inView: performerView)
        
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
    
    func playGrowAnimation(view: UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
            view.transform = CGAffineTransformMakeScale(1.6, 1.6)}, completion: nil)
    }
    
    func playShrinkAnimation(view: UIView) {
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .BeginFromCurrentState, animations: {
            view.transform = CGAffineTransformIdentity }, completion: nil)
    }
}

extension DJViewController {
    
    private func updateModel(panGesture: UIPanGestureRecognizer) {
        
        let performerView = panGesture.view as! PerformerView
        let userLetGo = (panGesture.state != .Began) && panGesture.state != UIGestureRecognizerState.Changed
        
        if userLetGo {
            let performer = performerView_performer_map[performerView]!
            userDidPlacePerformer(performer, pointInView: panGesture.locationInView(view))
        }
    }
    
    func userDidPlacePerformer(performer: Performer, pointInView: CGPoint) {
        
        guard let cell = getCellUnderPoint(collectionViewPoint: collectionView.convertPoint(pointInView, fromView: view)) else {
            
            print("The performer was placed outside the collection view ")
            deselectAudioStemForPerformerIfNeeded(performer)
            return
        }
        
        guard cell.soundZoneView.pointIsInsideRings(view.convertPoint(pointInView, toView: cell.soundZoneView)) else {
            
            print("The performer was placed outside the rings of it's soundZoneView")
            deselectAudioStemForPerformerIfNeeded(performer)
            return
        }
        
        guard performer_soundZoneView_map[performer] != cell.soundZoneView else {
            
            print("The performer was moved inside the rings of the soundZoneView it started in")
            /* noop */
            return
        }
        
        guard let audioStem = soundZoneView_audioStem_map[cell.soundZoneView] else {
            
            print("The performer was placed inside the rings of an EMPTY new soundZoneView")
            deselectAudioStemForPerformerIfNeeded(performer)
            return
        }
        
        print("The performer was placed inside the rings of a new soundZoneView")
        performer_soundZoneView_map[performer] = cell.soundZoneView
        soundZoneView_performer_map[cell.soundZoneView] = performer
        delegate.didSelectAudioStemForPerformer(audioStem, performer: performer, muted: effectiveIsMuteState(cell.soundZoneView))
    }
    
    func deselectAudioStemForPerformerIfNeeded(performer: Performer) {
        
        if let szv = performer_soundZoneView_map[performer] {
            performer_soundZoneView_map[performer] = nil
            soundZoneView_performer_map[szv] = nil
            delegate.didDeselectAudioStemForPerformer(performer)
        }
    }
}


extension DJViewController {
    
    /* NB: There is NOT a clean mapping between the mute state of a soundZoneView and the mute state of the model layer */
    
    func effectiveIsMuteState(soundZoneView: SoundZoneView) -> Bool {
        
        guard soundZoneView.isMute == false else {
        //print("This zone is muted")
            return true
        }
        
        guard soloingSoundZoneViews.count > 0 else {
        //print("This zone is not muted and there are no soloing zones")

            return false
        }
        
        guard soloingSoundZoneViews.contains(soundZoneView) else {
        //print("This zone is not muted and it being soloed")
            
            return false
        }
        
        //print("This zone is not muted, and there is another zone soloing")
        return true
    }
    
    func effectiveMuteStateDidChange(soundZoneView: SoundZoneView) {
        
        /* HERE */
    }
}

extension DJViewController {

    @objc private func didPan(panGesture: UIPanGestureRecognizer) {

        updateView(panGesture)
        updateModel(panGesture)
    }
}
