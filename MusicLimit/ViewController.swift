//
//  ViewController.swift
//  MusicLimit
//
//  Created by Bryan Mazariegos on 9/30/17.
//  Copyright © 2017 ICBM. All rights reserved.
//  Set a timer where music is selected to fit the alloted time within +/- 15s. Uses a slider in the middle to select time. Shows songs in tableview that are in queue. Shows time saved in comparison to last shower. Should have a 3-5 second delay before starting.

import UIKit

class ViewController: UIViewController {
    @IBOutlet var loginButton:UIButton!
    @IBOutlet var timerLengthSlider:UISlider!
    @IBOutlet var songsForSession:UITableView!
    @IBOutlet var reloadSongList:UIButton!
    @IBOutlet var timeDifferenceFromLastShowerLabel:UILabel!
    @IBOutlet var shortestShowerLabel:UILabel!
    @IBOutlet var longestShowerLabel:UILabel!
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUp()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUp() {
        auth.clientID = "07e2571edcaa4e619e271a2de33043de"
        auth.redirectURL = URL(string: "MusicLimit://returnAfterLogin")
        auth.requestedScopes = [SPTAuthStreamingScope,SPTAuthUserLibraryReadScope,SPTAuthPlaylistReadPrivateScope,SPTAuthPlaylistReadCollaborativeScope]
        auth.tokenRefreshURL = URL(string: "MusicLimit://returnAfterLogin")
        loginUrl = auth.spotifyWebAuthenticationURL()
    }
    
    @objc func updateAfterFirstLogin () {
        print("Ye 1")
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    func initializePlayer(authSession:SPTSession) {
        if self.player == nil {
            print("Ye 2")
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            do {
                try self.player!.start(withClientId: auth.clientID)
            } catch {
                print("Failed to start with clientId")
            }
            
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    @IBAction func login(_ sender:UIButton) {
        if player == nil {
            UIApplication.shared.open(loginUrl!, options: [:], completionHandler: { _ in
                if self.auth.canHandle(self.auth.redirectURL) {
                    
                }
            })
        } else {
            print("Should be good 2 go")
            startPlayingSongs()
        }
    }
    
    @IBAction func reselectSongs() {
        
    }
    
    @IBAction func startPlayingSongs() {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        if self.player!.loggedIn {
            print("logged in \(self.player!.loggedIn)")
            loginButton.isHidden = true
            self.player!.playSpotifyURI("spotify:track:1TZ3z6TBztuY0TLUlJZ8R7", startingWith: 0, startingWithPosition: 0, callback: { (error) in
                if (error != nil) {
                    print("\(error!)")
                }
            })
        }
    }
    
    @IBAction func findSongs(_ withTimeConstraint:Int) {
        
    }
}

extension ViewController: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        loginButton.isHidden = true
        print("logged in")
        
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("Oh no...")
    }
}

