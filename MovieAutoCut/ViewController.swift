//
//  ViewController.swift
//  MovieAutoCut
//
//  Created by cano on 2019/09/05.
//  Copyright © 2019 cano. All rights reserved.
//

import UIKit
import AVKit
import Photos
import SVProgressHUD

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // アクセス許可 忘れないように
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
            }
        }
    }

    @IBAction func onButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // 切り出した映像をカメラロールに保存
    func save(_ asset: AVAsset) {
        do{
            // 一時保存用の仮URL
            let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())TrimmedMovie.mp4")
            // すでにファイルがあれば削除
            try? FileManager.default.removeItem(at: url)
            
            // 切り出す動画のコンポジション作成
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = url
            exportSession.outputFileType = AVFileType.mp4
            
            // 動画の最初から10秒で切り出す 10秒未満の動画はその長さで切り出す
            let startTime = CMTime.zero
            let endTime = CMTimeMake(value: 10, timescale: 1)
            exportSession.timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.exportAsynchronously(completionHandler: {
                DispatchQueue.main.async {
                    switch exportSession.status {
                        case .completed:
                            print("exported at \(url)")
                            UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                            print("save ok")
                            Loading.stop()
                            SVProgressHUD.showSuccess(withStatus:" saved !")
                        
                        case .failed:
                            print("failed \(exportSession.error)")
                            Loading.stop()
                            if let errorStr = exportSession.error as? String {
                                SVProgressHUD.showError(withStatus: errorStr)
                            }
                        
                        case .cancelled:
                            print("cancelled \(exportSession.error)")
                            Loading.stop()
                            SVProgressHUD.showSuccess(withStatus:" cancelled !")
                        default: break
                    }
                }
            })
    
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// 映像選択時
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pHAsset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset{
            PHCachingImageManager().requestAVAsset(forVideo: pHAsset, options: nil) {  [unowned self](avAsset, _, _) in
                DispatchQueue.main.async {
                    if let asset = avAsset {
                        self.save(asset)
                        picker.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
