//
//  ImageFilterManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import UIKit
import CoreImage

enum ImageFilterManager {
    
    static func applyFilterFromUIImage(_ filter: Filter, to image: UIImage) -> UIImage? {
        
        // 1) original
        guard filter != .original else { return image }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        // 그 외 필터는 CIImage 변환
        guard let ciImage = CIImage(data: imageData) else { return nil }
        
        // 필터 객체
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        // TODO: 필터별 추가 파라미터 설정 가능
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        // 다시 UIImage로 변환
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(newImage, from: newImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    static func applyFilterFromData(_ filter: Filter, to data: Data) -> UIImage? {
        
        guard filter != .original else { return UIImage(data: data) }
        
        // orientation 메타 정보를 위한 이미지 변환
        guard let originImage = UIImage(data: data) else { return nil }
        
        guard let ciImage = CIImage(data: data) else { return nil }
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(newImage, from: newImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: originImage.scale, orientation: originImage.imageOrientation)
    }
}
