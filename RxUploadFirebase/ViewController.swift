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
       example2()
    }
    
    func example1(of: String = "deferred") {
        var flip = false
        let factory: Observable<[Int]> = Observable.deferred { // 3
            flip.toggle()
            if flip {
                return Observable.of([1, 2, 3])
            } else {
                return Observable.of([4, 5, 6])
            }
        }
        
        for _ in 0...3 {
            factory.subscribe(onNext: {
                print($0, terminator: "\n")
            })
                .disposed(by: disposeBag)
            print()
        }
    }
    
    func example2(name: String = ".just") {
        let observable = Observable.just("this is element").do(onNext: { (element) in
            print("onNext")//2
        }, afterNext: { (_) in
            print("afterNext")//4
        }, onError: { (_) in
            print("onError")
        }, afterError: { (_) in
            print("afterError")
        }, onCompleted: {
            print("onCompleted")//5
        }, afterCompleted: {
            print("afterCompleted")//6
        }, onSubscribe: {
            print("onSubscribe")//1
        }, onSubscribed: {
            print("onSubscribed")//7
        }) {
            print("trddddddd")//8
        }
        observable.subscribe { event in
            print("event: \(event)")
            //3event: next(this is element)
            //6 event: completed
        }
        .disposed(by: disposeBag)
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
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            imagePicker.sourceType = .photoLibrary
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

