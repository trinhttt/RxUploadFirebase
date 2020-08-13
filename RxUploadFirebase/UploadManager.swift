//
//  UploadManager.swift
//  RxUploadFirebase
//
//  Created by TrinhThai on 8/13/20.
//  Copyright © 2020 TrinhThai. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

public struct ImageData {
    var image: UIImage
}

public struct ImageKey {
    var key: String
}
public struct RxUpload: ObservableType {
    
    public typealias Element = ImageKey
    var data: ImageData
    
    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Self.Element == Observer.Element {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("images").child(imageName)
        let imgData = data.image.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if let error = error {
                print("error in save image")
                observer.onError(error)
            }
            observer.onNext(ImageKey(key: metaData.name ?? imageName))
            observer.onCompleted()
        }
        return Disposables.create()
    }
    
//    public static func upload(data: ImageData) -> Observable<Element> {
//        return Observable.deferred {
//            return RxUpload.init(data: data).asObservable()
//        }
//    }

    public static func upload(dataList: [ImageData]) -> Observable<[Element]> {
        return Observable.deferred {
            return Observable.from(dataList).flatMap { (data) -> Observable<Element> in
                return RxUpload.init(data: data).asObservable()
            }
        }.toArray().asObservable()
    }
}
