//
//  ViewController.swift
//  JitsiSample
//
//  Created by Muhammad Sajad on 24/01/2019.
//  Copyright © 2019 Muhammad Sajad. All rights reserved.
//

import UIKit
import JitsiMeet

class CallViewController: UIViewController {
    
    @IBOutlet weak var videoButton: UIButton?
    
    var didEndCall: (()->Void)?
    
    var callRoomName: String? {
        didSet {
            print("Call room name is \"\(callRoomName)\"")
        }
    }
    
    //fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var jitsiMeetView: JitsiMeetView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        if callRoomName != nil {
            startSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
       // pipViewCoordinator?.resetBounds(bounds: rect)
    }
    
    // MARK: - Actions
    
    private func startSession() {
        cleanUp()
        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.welcomePageEnabled = true
        jitsiMeetView.pictureInPictureEnabled = false
        
        let inviteController = jitsiMeetView.inviteController
        inviteController.delegate = self
        inviteController.addPeopleEnabled = true
        inviteController.dialOutEnabled = true
        
        //jitsiMeetView.load(URL(string: "https://meet.jit.si/test1"))
        //jitsiMeetView.loadURLString("test2")
//        jitsiMeetView.loadURLObject(["config": ["startWithAudioMuted": false,
//                                                "startWithVideoMuted": false],
//                                     "url": callRoomName!.replacingOccurrences(of: " ", with: "").trimmingCharacters(in: .whitespaces)])
        
        jitsiMeetView.load(nil)
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        self.view = jitsiMeetView
        
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        //pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        //pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        // animate in
        jitsiMeetView.alpha = 0
        //pipViewCoordinator?.show()
    }
    
    /*
    @IBAction func openJitsiMeet(sender: Any?) {
        cleanUp()
        
        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.welcomePageEnabled = false
        jitsiMeetView.pictureInPictureEnabled = true
        //jitsiMeetView.load(URL(string: "https://meet.jit.si/test1"))
        //jitsiMeetView.loadURLString("test2")
        jitsiMeetView.loadURLObject(["config": ["startWithAudioMuted": true,
                                                "startWithVideoMuted": false],
                                     "url": "test2"])
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        // animate in
        jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }*/
    
    fileprivate func cleanUp() {
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        //pipViewCoordinator = nil
    }
}

extension CallViewController: JitsiMeetViewDelegate {
    
    func conferenceFailed(_ data: [AnyHashable : Any]!) {
        hideJitsiMeetViewAndCleanUp()
    }
    
    func conferenceLeft(_ data: [AnyHashable : Any]!) {
        hideJitsiMeetViewAndCleanUp()
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            //self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
    
    private func hideJitsiMeetViewAndCleanUp() {
        DispatchQueue.main.async {
            
            self.cleanUp()
            self.didEndCall?()
            self.navigationController?.popViewController(animated: true)
//            self.pipViewCoordinator?.hide() { _ in
//
//            }
        }
    }
}

extension CallViewController: JMInviteControllerDelegate {
    func beginAddPeople(_ addPeopleController: JMAddPeopleController!) {
        
    }
    
    
}
