//
//  ViewController.swift
//  NSFW Detect
//
//  Created by Lakshay Chhabra on 17/10/19.
//  Copyright © 2019 Lakshay Chhabra. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet var warning: UILabel!
    @IBOutlet var blur: UIVisualEffectView!
    @IBOutlet var image_View: UIImageView!
    @IBOutlet var output_label: UILabel!
    let imagePicker = UIImagePickerController()
    var k = 0
    var confidence = "0"
    var dict : [String : Int] = ["Neutral" : 0 ,"Porn" : 1,"Sexy" : 2]
    let image_array : [UIImage] = [UIImage(named: "1.jpg")!, UIImage(named: "2.jpg")!, UIImage(named: "3.jpg")!,UIImage(named: "4.jpg")!, UIImage(named: "5.jpg")!,UIImage(named: "6.jpg")!,UIImage(named: "7.jpg")!,UIImage(named: "8.jpg")!,UIImage(named: "9.jpg")!,UIImage(named: "10.jpg")!, UIImage(named: "11.jpg")!, UIImage(named: "12.jpg")!, UIImage(named: "13.jpg")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("running")
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        blur.alpha = 0.9
        output_label.text = "Choose Something"
        warning.text = " "
//        image_View.image = image_array[0]
       
    }
   

    @IBOutlet var switch_out: UISwitch!
    @IBAction func `switch`(_ sender: Any) {
        if(!switch_out.isOn){
            print("Unblur")
            blur.alpha = 0
        }else{
            print("blur")
            blur.alpha = 0.90
        }
    }
    var image = UIImage()
    @IBAction func camera_icon(_ sender: Any) {
         present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.image_View.image = info[.editedImage] as? UIImage
       var userPickedImage = info[.editedImage] as? UIImage

            
           userPickedImage = resizeImage(image: userPickedImage!)
        guard let convertedCiImage = CIImage(image: userPickedImage!) else {
                fatalError("Cant convert to CI IMage")
            }
            
            detectImage(image: convertedCiImage)
        
        //after picking the image to dismiss the popped up gallery
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }

    
    func detectImage(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: NSFW().model) else{
            fatalError("Cant Load the machine learning Module")
            
        }
        
        
        //Now we gonna create a request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            print(request.results!)
            
            guard let classification = request.results?.first as? VNClassificationObservation else{
                fatalError("cant find the image")
            }
            DispatchQueue.main.async {
                let confidenceRate = (classification.confidence) * 100
                self.output_label.text = "\(confidenceRate)% it's \(String(describing: classification.identifier))"
                self.k = self.dict[classification.identifier]!
                if(self.k == 0){
                    self.warning.text = "Safe Image"
                }
                else if(self.k == 1){
                    self.warning.text = "NSFW Image"
                }else{
                    self.warning.text = "Not For Kids Image"
                }
                
            }
            
            self.k = self.dict[classification.identifier]!
            
            print(classification.identifier)
            print(classification.confidence)
            print(classification)

        }
        
        
        //handler to process that request
        
        let handler = VNImageRequestHandler(ciImage: image)
        do  {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
    }
    
    
    func resizeImage(image: UIImage) -> UIImage {
        
        
        var newSize: CGSize
        newSize = CGSize(width: 224, height: 224)
        let rect = CGRect(x: 0, y: 0, width: 224, height: 224)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func shuffle(_ sender: Any) {
        let randomInt = Int.random(in: 0 ..< 12)
        image_View.image = image_array[randomInt]
        let userPickedImage : UIImage = image_array[randomInt]
        guard let convertedCiImage = CIImage(image: userPickedImage) else {
            fatalError("Cant convert to CI IMage")
        }
        
        detectImage(image: convertedCiImage)
        
    }
}

