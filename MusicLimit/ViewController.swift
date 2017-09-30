	//
//  ViewController.swift
//  MusicLimit
//
//  Created by Bryan Mazariegos on 9/30/17.
//  Copyright © 2017 ICBM. All rights reserved.
//  Set a timer where music is selected to fit the alloted time within +/- 15s. Uses a slider in the middle to select time. Shows songs in tableview that are in queue. Shows time saved in comparison to last shower. Should have a 3-5 second delay before starting.

import UIKit

class ViewController: UIViewController, SPTCoreAudioControllerDelegate {
    @IBOutlet var loginButton:UIButton!
    @IBOutlet var timerLengthSlider:UISlider!
    @IBOutlet var songsForSession:UITableView!
    @IBOutlet var playButton:UIButton!
    @IBOutlet var minutesRemainingLabel:UILabel!
    @IBOutlet var unitLabel:UILabel!
    @IBOutlet var timeDifferenceFromLastShowerLabel:UILabel!
    @IBOutlet var shortestShowerLabel:UILabel!
    @IBOutlet var longestShowerLabel:UILabel!
    
    var colorLibraryR2W:[CGFloat] = [0.016,0.032,0.064,0.08,0.096,0.112,0.128,0.144,0.16,0.176,0.192,0.208,0.224,0.24,0.256,0.272,0.288,0.304,0.32,0.336,0.352,0.368,0.384,0.4,0.416,0.432,0.448,0.464,0.48,0.496,0.512,0.528,0.544,0.56,0.576,0.592,0.608,0.624,0.64,0.656,0.672,0.688,0.704,0.72,0.736,0.752,0.768,0.784,0.8,0.816,0.832,0.848,0.864,0.88,0.896,0.912,0.928,0.944,0.976,0.992]
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    var usersPlaylist:SPTPlaylistList?
    
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
    
    @IBAction func updateTimerLength() {
        minutesRemainingLabel.text = "\(Int(timerLengthSlider.value))"
        let position = Int(timerLengthSlider.value.rounded()) - 1
        let color = UIColor(red: 1, green: colorLibraryR2W[59 - position], blue: colorLibraryR2W[59 - position], alpha: 1)
        timerLengthSlider.thumbTintColor = color
        timerLengthSlider.minimumTrackTintColor = color
        minutesRemainingLabel.textColor = color
        unitLabel.textColor = color
    }
    
    @IBAction func startPlayingSongs() {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        if self.player!.loggedIn {
            print("logged in \(self.player!.loggedIn)")
            loginButton.isHidden = true
            unitLabel.isHidden = false
            minutesRemainingLabel.isHidden = false
            timerLengthSlider.isHidden = false
            playButton.isHidden = false
            self.player!.playSpotifyURI("spotify:track:1TZ3z6TBztuY0TLUlJZ8R7", startingWith: 0, startingWithPosition: 0, callback: { (error) in
                if (error != nil) {
                    print("\(error!)")
                }
            })
        }
    }
    
    @IBAction func findSongs(_ withTimeConstraint:Int) {
        usersPlaylist = SPTPlaylistList.playlists(forUser: auth.session.canonicalUsername, withAccessToken: auth.session.accessToken, callback: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ViewController: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        loginButton.isHidden = true
        unitLabel.isHidden = false
        minutesRemainingLabel.isHidden = false
        timerLengthSlider.isHidden = false
        playButton.isHidden = false
        print("logged in")
        
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("Oh no...")
    }
}

