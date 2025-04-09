//
//  ImageFilterManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/8/25.
//

import UIKit
import CoreImage

enum ImageFilterManager {
    
    
    // UIImage를 필터링
    static func applyFilterFromUIImage(_ filter: Filter, to image: UIImage) -> UIImage? {
        
        // 1) original
        guard filter != .original else { return image }
        
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
        
        // 그 외 필터는 CIImage 변환
        guard let ciImage = CIImage(data: imageData) else { return nil }
        let originalExtent = ciImage.extent
        
        // 필터 객체
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        let outputExtent = newImage.extent
        
        let finalImage: CIImage
        if outputExtent.size.width != originalExtent.size.width ||
           outputExtent.size.height != originalExtent.size.height {
            
            finalImage = newImage.cropped(to: originalExtent)

        } else {
            finalImage = newImage
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(finalImage, from: originalExtent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    static func applyFilterFromUIImage(_ filter: Filter, to image: UIImage, value: CGFloat) -> UIImage? {
        
        // 1) original
        guard filter != .original else { return image }
        
        guard let imageData = image.jpegData(compressionQuality: 0.6) else { return nil }
        
        // 그 외 필터는 CIImage 변환
        guard let ciImage = CIImage(data: imageData) else { return nil }
        let originalExtent = ciImage.extent
        
        // 필터 객체
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        switch filter.effect {
        case "intensity": ciFilter.setValue(value, forKey: kCIInputIntensityKey)
        case "scale": ciFilter.setValue(value, forKey: kCIInputScaleKey)
        case "noiseLevel": ciFilter.setValue(value, forKey: "inputNoiseLevel")
        case "radius": ciFilter.setValue(value, forKey: kCIInputRadiusKey)
        case "levels": ciFilter.setValue(value, forKey: "inputLevels")
        default: break
        }
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        let outputExtent = newImage.extent
        
        let finalImage: CIImage
        if outputExtent.size.width != originalExtent.size.width ||
           outputExtent.size.height != originalExtent.size.height {
            
            finalImage = newImage.cropped(to: originalExtent)

        } else {
            finalImage = newImage
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(finalImage, from: originalExtent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // 데이터에 필터링
    static func applyFilterFromData(_ filter: Filter, to data: Data) -> UIImage? {
        
        guard filter != .original else { return UIImage(data: data) }
        
        // orientation 메타 정보를 위한 이미지 변환
        guard let originImage = UIImage(data: data) else { return nil }
        
        guard let ciImage = CIImage(data: data) else { return nil }
        // 원본 이미지의 경계 저장
        let originalExtent = ciImage.extent
        
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        // 필터 후 크기가 변경되었는지 확인
        let outputExtent = newImage.extent
        
        // 출력 이미지의 크기가 다른 경우 원본 크기로 조정
        let finalImage: CIImage
        if outputExtent.size.width != originalExtent.size.width ||
           outputExtent.size.height != originalExtent.size.height {
            
            // 원본 이미지 경계로 크롭하거나 확장
            finalImage = newImage.cropped(to: originalExtent)

        } else {
            finalImage = newImage
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(finalImage, from: originalExtent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: originImage.scale, orientation: originImage.imageOrientation)
    }
    
    // 슬라이더로 전달받은 필터 값 
    static func applyFilterFromData(_ filter: Filter, to data: Data, value: CGFloat) -> UIImage? {
        
        // 1) original
        guard filter != .original else { return UIImage(data: data) }
        
        // orientation 메타 정보를 위한 이미지 변환
        guard let originImage = UIImage(data: data) else { return nil }
        
        guard let ciImage = CIImage(data: data) else { return nil }
        // 원본 이미지의 경계 저장
        let originalExtent = ciImage.extent
        
        guard let ciFilter = filter.filter else { return nil }
        
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        switch filter.effect {
        case "intensity": ciFilter.setValue(value, forKey: kCIInputIntensityKey)
        case "scale": ciFilter.setValue(value, forKey: kCIInputScaleKey)
        case "noiseLevel": ciFilter.setValue(value, forKey: "inputNoiseLevel")
        case "radius": ciFilter.setValue(value, forKey: kCIInputRadiusKey)
        case "levels": ciFilter.setValue(value, forKey: "inputLevels")
        default: break
        }
        
        guard let newImage = ciFilter.outputImage else { return nil }
        
        // 필터 후 크기가 변경되었는지 확인
        let outputExtent = newImage.extent
        
        // 출력 이미지의 크기가 다른 경우 원본 크기로 조정
        let finalImage: CIImage
        if outputExtent.size.width != originalExtent.size.width ||
           outputExtent.size.height != originalExtent.size.height {
            
            // 원본 이미지 경계로 크롭하거나 확장
            finalImage = newImage.cropped(to: originalExtent)

        } else {
            finalImage = newImage
        }
        
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(finalImage, from: originalExtent) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: originImage.scale, orientation: originImage.imageOrientation)
    }
}
