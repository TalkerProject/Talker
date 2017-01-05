//
//  VideoCallController.swift
//  TalkerProject
//
//  Created by trieulieuf9 on 12/3/16.
//  Copyright © 2016 Nguyen Duc Gia Bao. All rights reserved.
//

import Foundation
import UIKit
import TwilioVideo

class VideoCallController: UIViewController {
    
    var accessToken = "TWILIO_ACCESS_TOKEN"
    
    // URL to fetch access token from
    var tokenUrl = "https://nameless-wildwood-22600.herokuapp.com/index/getter?password=dongphuongbatbai"
    
    // API components
    var client: TVIVideoClient?
    var localMedia: TVILocalMedia?
    var room: TVIRoom?
    var camera: TVICameraCapturer?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var participant: TVIParticipant?
    
    // UI
    var callButton:UIButton?
    var endCallButton:UIButton?
    var previewView:UIView?
    var remoteView:UIView?
    var statusLabel: UILabel!
    var callingLabel: UILabel?
    
    // General
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    // Data passed from ChatLogController
    var isInviter:Bool = false // to recognize, who press call, and who is called
    var hotelRoomNumber:String? // to able to connect to the right person.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        // run in sub-thread, because it take a while for access token to be sent
        DispatchQueue.global(qos: .background).async {
            self.calling()
        }
        
        settingUpView()
        localMedia = TVILocalMedia()
        
        // set up the small screen in the corner, that show your face
        if PlatformUtils.isSimulator {
            self.previewView?.removeFromSuperview()
        } else {
            // Preview our local camera track in the local video preview view.
            startPreview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AnonymousChatController.inMediaPicker = false
    }
    
    func calling() {
        // get access token from the tokenUrl
        
        do {
            print("checkpoint 1: getting access token")
            accessToken = try TokenUtils.fetchToken(url: tokenUrl)
        } catch {
            let message = "Failed to fetch access token"
            statusLabel.text = message
            return
        }
        
        print(accessToken)
        print("checkpoint 2")
        
        // Create a Client with the access token that we fetched.
        if (client == nil) {
            client = TVIVideoClient(token: accessToken)
            if (client == nil) {
                statusLabel.text = "Failed to create video client"
                return
            }
        }
        
        // Prepare local media which we will share with Room Participants.
        // aka, accessing the video and audio in the device
        self.prepareLocalMedia()
        
        // Preparing the connect options
        let connectOptions = TVIConnectOptions { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.localMedia = self.localMedia
            
            // The name of the Room where the Client will attempt to connect to. Please note that if you pass an empty
            // Room `name`, the Client will create one for you. You can get the name or sid from any connected Room.
            
            // room name, 2 people have to get the same room name to connect
            builder.name = self.hotelRoomNumber
        }
        
        // Connect to the Room using the options we provided.
        room = client?.connect(with: connectOptions, delegate: self)
        
        statusLabel.text = "Attempting to connect to"
    }
    
    func endCallButtonClick() {
        print("button click")
        if self.room != nil {
            print("Room disconnected")
            self.room!.disconnect()
        }
        
        statusLabel.text = "Attempting to disconnect"
        
        // let the phone sleep in a period of non-touching time
        UIApplication.shared.isIdleTimerDisabled = false
        
        // go back to chatlogcontroller
        // It's yellow, but ok
        _ = self.navigationController?.popViewController(animated: true)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    //    func toggleMic() {
    //        if (self.localAudioTrack != nil) {
    //            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
    //
    //            // Update the button title
    //            if (self.localAudioTrack?.isEnabled == true) {
    //                self.micButton.setTitle("Mute", for: .normal)
    //            } else {
    //                self.micButton.setTitle("Unmute", for: .normal)
    //            }
    //        }
    //    }
    
    func settingUpView() {
        let screenSize: CGRect = UIScreen.main.bounds
        width = screenSize.width
        height = screenSize.height
        
        // label to see the status of the connection
        statusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 50))
        statusLabel.backgroundColor = .green
        statusLabel?.textAlignment = .center
        statusLabel.isHidden = true
        
        // Add end call Button, hidden at first
        endCallButton = UIButton(frame: CGRect(x: width * 0.5 - 50, y: height * 0.8, width: 100, height: 50))
        endCallButton?.backgroundColor = .red
        endCallButton?.setTitle("End Call", for: .normal)
        endCallButton?.addTarget(self, action: #selector(endCallButtonClick), for: .touchUpInside)
        
        // previewView, aka your side video
        previewView = UIView(frame: CGRect(x: width * 0.5 + 50, y: height * 0.75, width: 100, height: 120))
        previewView?.backgroundColor = .black
        
        // remoteView, aka other side video
        remoteView = UIView(frame: CGRect(x: 0, y: 20, width: width, height: height))
        remoteView?.backgroundColor = .black
        
        
        self.view.addSubview(remoteView!)
        self.view.addSubview(previewView!)
        self.view.addSubview(endCallButton!)
        self.view.addSubview(statusLabel!)
        
        if isInviter { // caller
            callingLabel?.text = "Calling..."
            statusLabel?.isHidden = false
        }
    }
    
    func startPreview() {
        if PlatformUtils.isSimulator {
            return
        }
        
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer()
        localVideoTrack = localMedia?.addVideoTrack(true, capturer: camera!)
        if (localVideoTrack == nil) {
            statusLabel.text = "Failed to add video track"
        } else {
            // Attach view to video track for local preview
            localVideoTrack!.attach(self.previewView!)
            
            statusLabel.text = "Video track added to localMedia"
            
            // We will flip camera on tap.
            let tap = UITapGestureRecognizer(target: self, action: #selector(VideoCallController.flipCamera))
            self.previewView?.addGestureRecognizer(tap)
        }
    }
    
    func flipCamera() {
        if (self.camera?.source == .frontCamera) {
            self.camera?.selectSource(.backCameraWide)
        } else {
            self.camera?.selectSource(.frontCamera)
        }
    }
    
    func prepareLocalMedia() {
        // We will offer local audio and video when we connect to room.
        
        // Adding local audio track to localMedia
        if (localAudioTrack == nil) {
            localAudioTrack = localMedia?.addAudioTrack(true)
        }
        
        // Adding local video track to localMedia and starting local preview if it is not already started.
        if (localMedia?.videoTracks.count == 0) {
            self.startPreview()
        }
    }
    
    func cleanupRemoteParticipant() {
        if ((self.participant) != nil) {
            if ((self.participant?.media.videoTracks.count)! > 0) {
                self.participant?.media.videoTracks[0].detach(self.remoteView!)
            }
        }
        self.participant = nil
    }
}

extension VideoCallController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        // At the moment, this example only supports rendering one Participant at a time.
        
//        statusLabel.text = "Connected"
        
        // when video call connected, hide this label
        statusLabel?.isHidden = true
        
        // not let the phone sleep in a period of non-touching time
        UIApplication.shared.isIdleTimerDisabled = true
        
        if (room.participants.count > 0) {
            self.participant = room.participants[0]
            self.participant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        statusLabel?.isHidden = false
        statusLabel.text = "Disconncted, error = \(error)"
        
        self.cleanupRemoteParticipant()
        self.room = nil
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        statusLabel?.isHidden = false
        statusLabel.text = "Failed to connect with error"
        self.room = nil
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        if (self.participant == nil) {
            self.participant = participant
            self.participant?.delegate = self
        }
//        statusLabel.text = "Participant connected"
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
        if (self.participant == participant) {
            cleanupRemoteParticipant()
        }
        statusLabel?.isHidden = false
        statusLabel.text = "Participant disconnected"
    }
}

extension VideoCallController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
//        statusLabel.text = "Participant added video track"
        
        if (self.participant == participant) {
            videoTrack.attach(self.remoteView!)
        }
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
//        statusLabel.text = "Participant removed video track"
        
        if (self.participant == participant) {
            videoTrack.detach(self.remoteView!)
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
//        statusLabel.text = "Participant added audio track"
    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
//        statusLabel.text = "Participant removed audio track"
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
//        statusLabel.text = "Participant enabled \(type) track"
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
//        statusLabel.text = "Participant disabled \(type) track"
    }
}


// what to do:

// organize the video call controller, show the navigationbar when go back. ---> Done!!
// organize the view. ---> Done!!
// get back to chat log, and show navigationbar again. ---> Done !!

// What i am doing:

// write function to identified chat invitation in 30s
// generate random roomNumber.

