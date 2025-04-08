//
//  ImageFilterManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import UIKit
import CoreImage

enum ImageFilterManager {
    
    static func applyFilterAtUIImage(_ filter: Filter, to image: UIImage) -> UIImage? {
        
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
}
