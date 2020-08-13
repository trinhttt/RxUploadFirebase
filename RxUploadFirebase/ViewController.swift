//
//  ViewController.swift
//  RxUploadFirebase
//
//  Created by TrinhThai on 8/13/20.
//  Copyright © 2020 TrinhThai. All rights reserved.
//

import UIKit
import Firebase
import RxSwift

class ViewController: UIViewController {

    @IBOutlet var ibImageViews: [UIImageView]!
    
    var imagePicker = UIImagePickerController()
    var selectedImageViewIndex: Int = 0
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (index, image) in ibImageViews.enumerated() {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.openGalleryClick(tapGesture:)))
            image.tag = index
            image.isUserInteractionEnabled = true
            image.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    @objc func openGalleryClick(tapGesture: UITapGestureRecognizer) {
        guard let selectedImageView = tapGesture.view else { return }
        selectedImageViewIndex = selectedImageView.tag
        self.setupImagePicker()
    }

    @IBAction func btnSaveClick(_ sender: UIButton) {
         self.uploadData()
    }

    func uploadData(){
        let images = ibImageViews.compactMap { $0.image }
        self.uploadMedia(images: images) { url in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadMedia(images: [UIImage], completion: @escaping ((_ url: URL?) -> ())) {
//        for image in images {
//            let imageName = NSUUID().uuidString
//            let storageRef = Storage.storage().reference().child("images").child(imageName)
//            let imgData = image.pngData()
//            let metaData = StorageMetadata()
//            metaData.contentType = "image/png"
//            storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
//                if error == nil{
//                    storageRef.downloadURL(completion: { (url, error) in
//                        completion(url)
//                    })
//                } else {
//                    print("error in save image")
//                    completion(nil)
//                }
//            }
//        }
        let imageDataList = images.compactMap { ImageData(image: $0) }
        RxUpload.upload(dataList: imageDataList)
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                print(response) // response is array with 3 ImageKey
            }, onError: { error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    func setupImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.allowsEditing = true

            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        ibImageViews[selectedImageViewIndex].image = image
        picker.dismiss(animated: true, completion: nil)
    }

}

