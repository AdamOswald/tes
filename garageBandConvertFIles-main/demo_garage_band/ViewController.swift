//
//  ViewController.swift
//  demo_garage_band
//
//  Created by   Валерий Мельников on 31.01.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func upload(path : String) {
        var inputFile: String? = nil
         inputFile = Bundle.main.path(forResource: "ringtone.mp3", ofType: nil)
         let fileName = URL(fileURLWithPath: inputFile?.lastPathComponent ?? "").deletingPathExtension().path


         //1.скопируй сначала bandFolder
         let copyAtPath = AppConfigure.shared().bandfolder
         let copyToPath = URL(fileURLWithPath: AppConfigure.shared().bandfolderDirectory).appendingPathComponent("\(fileName).band").path
         do {
             try FileManager.default.copyItem(atPath: copyAtPath, toPath: copyToPath)
         } catch {
         }
         //2.Затем перекодируйте собственное аудио в aiff
         let converter = ExtAudioConverter()
         converter.inputFile = inputFile
         converter.outputFile = "\(copyToPath)/Media/ringtone.aiff"
         converter.outputFileType = kAudioFileAIFFType
         converter.convert()

        //let b = FileManager.default.fileExists(atPath: copyToPath)
        
        //3.Всплывающее окно «Поделиться» и поделиться
        let items = [URL(fileURLWithPath: copyToPath)]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.airDrop]
        
        // Обратный звонок после обмена
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if completed {
            } else if activityError != nil {
            }
        }
        present(activityViewController, animated: true) {
        }
    }
    
    
    
    @IBAction func tap(_ sender: UIButton) {
        upload(path: "test")
    }
    

}

extension String {
    var ns: NSString {
        return self as NSString
    }
    var pathExtension: String {
        return ns.pathExtension
    }
    var lastPathComponent: String {
        return ns.lastPathComponent
    }
}
