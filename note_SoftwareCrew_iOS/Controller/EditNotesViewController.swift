//
//  AppDelegate.swift
//  note_SoftwareCrew_iOS
//
//  Created by Kirna on 13/09/21.
//



import UIKit
import CoreData
import MapKit
import AVFoundation

class EditNotesViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate{
    
    var locationManager = CLLocationManager()
    @IBOutlet weak var txttitle: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var notesImageView: UIImageView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet var lblLong: UILabel!
    @IBOutlet weak var locationBtn: UIButton!
    var recordingSession:AVAudioSession!
    var audioRecoreder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var numberOfRecords:Int = 0
    var latitudeString:String = ""
    var longitudeString:String = ""
    var note:Note!
    var notebook : Notebook?
    var userIsEditing = true
    var old = true
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.purple
        textView.text = "Enter description"
        textView.textColor = UIColor.lightGray
        recordingSession = AVAudioSession.sharedInstance()
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber ") as? Int {
            numberOfRecords = number
        }
        AVAudioSession.sharedInstance().requestRecordPermission{(hasPermission) in
            if hasPermission{
                print("Permission given")
            }
        }
        navigationController?.navigationBar.barTintColor = UIColor.purple
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        if (userIsEditing == true) {
            txttitle.text = note.title!
            textView.text = note.text!
            self.notesImageView.image = UIImage(data: note.image! as Data)
            self.navigationController?.navigationItem.title = "Edit Notes"
        }
        else {
            self.navigationController?.navigationItem.title = "Add Notes"
            textView.text = ""
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(UserDefaults.standard.value(forKey: "userLat") != nil){
            let userLat = UserDefaults.standard.value(forKey: "userLat")
            let userLng = UserDefaults.standard.value(forKey: "userLong")
            latitudeString = "\(userLat!)"
            longitudeString = "\(userLng!)"
            locationBtn.setTitle("Lat : " + latitudeString + " , " + "Long : " + longitudeString, for: .normal)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description"
            textView.textColor = UIColor.lightGray
        }
    }
    @IBAction func selectimage(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        let alertController = UIAlertController(title: "Add Image", message: "Choose from", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imageData = image.pngData() as NSData?
            self.notesImageView.image = UIImage(data: imageData! as Data)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        note.lat = userLocation.coordinate.latitude
        note.long = userLocation.coordinate.longitude
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    @IBAction func record(_ sender: Any) {
        if  audioRecoreder == nil  {
            numberOfRecords += 1
            let filname = getDirectory().appendingPathComponent("Recording \(numberOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),AVSampleRateKey: 12000,AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            // start audio recording
            do {
                audioRecoreder = try AVAudioRecorder(url: filname,settings: settings)
                audioRecoreder.delegate = self
                audioRecoreder.record()
                recordBtn.setTitle("Stop recording", for: .normal)
            } catch  {
                displayAlert(title: "Error!", message: "Recording Failed!!")
            }
        }
        else{
            audioRecoreder.stop()
            audioRecoreder = nil
            UserDefaults.standard.set(numberOfRecords,forKey: "myNumber")
            myTableView.reloadData()
            do{
                try context.save()
                displayAlert(title: "Recording \(numberOfRecords)", message: "Recording saved!")
            }
            catch {
                print("Error saving recording!")
                // show an alert box with an error message
                let alertBox = UIAlertController(title: "Error", message: "Error while saving.", preferredStyle: .alert)
                alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertBox, animated: true, completion: nil)
            }
            recordBtn.setTitle("Make a VoiceNote", for: .normal)
        }
    }
    
    
    @IBAction func savenotes(_ sender: UIBarButtonItem) {
        if (textView.text!.isEmpty) {
            return
        }
        if (userIsEditing == true) {
            note.text = textView.text!
        }
        else {
            self.note = Note(context:context)
            note.setValue(Date(), forKey:"dateAdded")
            if (txttitle.text!.isEmpty) {
                note.title = "No Title"
            }
            else{
                note.title = txttitle.text!
            }
            note.text = textView.text!
            let imageData = notesImageView.image!.pngData() as NSData?
            note.image = imageData as Data?
            note.notebook = self.notebook
        }
        do {
            try context.save()
            print("Note Saved!")
            SHOW_ALERT_CONTROLLER_DOUBLE_BUTTON(alertTitle: "Saved!", message: "Save Successfully", btnTitle1: "Cancle", btnTitle2: "OK", viewController: self, completionHandler:{ (response) in
                if(response == "Button2"){
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        catch {
            print("Error saving note in Edit Note screen")
            
            // show an alert box with an error message
            let alertBox = UIAlertController(title: "Error", message: "Error while saving.", preferredStyle: .alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
        }
        
        if (userIsEditing == false) {
            self.navigationController?.popViewController(animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //get path
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //display alert
    func displayAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRecords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell1.textLabel?.text = String(indexPath.row + 1)
        return cell1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let path = getDirectory().appendingPathComponent("Recording \(indexPath.row + 1).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch
        {
            print("Error!")
        }
    }
    //MARK:- Alert 
    func SHOW_ALERT_CONTROLLER_DOUBLE_BUTTON(alertTitle:String, message:String, btnTitle1:String, btnTitle2:String,viewController:UIViewController,  completionHandler:@escaping (String) -> ())
    {
        let alert = ALERT_CONTROLLER(title: alertTitle, message: message)
        let cancelAction = ALERT_CONTROLLER_CANCEL_ACTION(title: btnTitle1) { (success) in
            completionHandler("Button1")
        }
        alert.addAction(cancelAction)
        
        let okAction = ALERT_CONTROLLER_OK_ACTION(title: btnTitle2) { (success) in
            completionHandler("Button2")
        }
        alert.addAction(okAction)
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    func ALERT_CONTROLLER(title: String, message : String) -> UIAlertController {
        return  UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    }

    func ALERT_CONTROLLER_CANCEL_ACTION(title:String, completionHandler:@escaping (Bool) -> ()) -> UIAlertAction {
        return  UIAlertAction(title: title, style: UIAlertAction.Style.cancel, handler:{                                          UIAlertAction in
            completionHandler(true)
        })
    }

    func ALERT_CONTROLLER_OK_ACTION(title:String, completionHandler:@escaping (Bool) -> ()) -> UIAlertAction {
        return  UIAlertAction(title: title, style: UIAlertAction.Style.default, handler:{                                          UIAlertAction in
            completionHandler(true)
        })
    }
}
