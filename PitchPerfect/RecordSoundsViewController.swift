//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Florent Spahiu on 04/05/2017.
//  Copyright © 2017 Florent Spahiu. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRecordingViewUI(false)
    }

    @IBAction func recordAudio(_ sender: Any) {
        configureRecordingViewUI(true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        configureRecordingViewUI(false)
        audioRecorder.stop();
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool){
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("There was an error saving file")
            showAlertToUser()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundVC.recordedAudioUrl = recordedAudioURL
        }
    }
    
    //this funciton will be called to configure UI of RecordSoudnsViewController.swift
    func configureRecordingViewUI(_ isRecording: Bool) {
        stopRecordingButton.isEnabled = isRecording
        recordButton.isEnabled = !isRecording
        recordingLabel.text=isRecording ? "Recording in progress..." : "Tap to record"
    }
    
    func showAlertToUser() {
        let alertController = UIAlertController(title: "Error", message: "There was an error saving the audio file.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            print("OK clicked.")
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
