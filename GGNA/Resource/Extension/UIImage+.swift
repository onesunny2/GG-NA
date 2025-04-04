//
//  UIImage+.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/2/25.
//

import UIKit

extension UIImage {
    
    func downSample(scale: CGFloat) -> UIImage {
        guard let pngData = self.pngData() else { return UIImage() }
        let data = pngData as CFData
        let imageSource = CGImageSourceCreateWithData(data, nil)!
        let maxPixel = max(self.size.width, self.size.height) * scale
        let options = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ] as CFDictionary

        guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else { return UIImage() }

        return UIImage(cgImage: scaledImage)
    }
    
    func fixImageOrientation() -> UIImage {
        // 이미지가 이미 올바른 방향이면 그대로 반환
        if self.imageOrientation == .up {
            return self
        }
        
        // 이미지 방향 수정을 위한 그래픽 컨텍스트 생성
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func saveImageToDocument(foldername: String, filename: String) {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // 폴더경로
        let folderURL = documentDirectory.appendingPathComponent(foldername)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            
            do {
                // 없으면 폴더 생성
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                
            } catch {
                print("폴더 생성 실패")
                return
            }
        }
        
        let fileURL = folderURL.appendingPathComponent("\(filename).jpg")
        
        guard let data = self.jpegData(compressionQuality: 1) else { return }
        
        // 실제 저장하려는 이미지 파일
        do {
            try data.write(to: fileURL)  // fileURL에 해당 이미지가 저장이 될 것임
        } catch {
            print("이미지 저장 실패")
        }
    }
    
    func loadImageFromDocument(foldername: String, fileName: String) -> UIImage? {
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 폴더 경로
        let folderURL = documentDirectory.appendingPathComponent(foldername)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            print("\(foldername)폴더가 존재하지 않습니다.")
            return nil
        }
        
        let fileURL = folderURL.appendingPathComponent("\(fileName).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return nil // TODO: nil 일 때 어떻게 처리할건지도 고민 필요
        }
    }
}
