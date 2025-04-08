//
//  Filter.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

enum Filter: String, CaseIterable {
    case original
    case colorInvert
    case colorPosterize
    case maskToAlpha
    case photoEffectChrome
    case photoEffectFade
    case photoEffectInstant
    case photoEffectMono
    case photoEffectNoir
    case photoEffectProcess
    case photoEffectTransfer
    case sepiaTone
    case xRay
    
    var type: String {
        return self.rawValue
    }
    
    var filter: CIFilter? {
        switch self {
        case .original: return nil
        case .colorInvert: return CIFilter.colorInvert()
        case .colorPosterize: return CIFilter.colorPosterize()
        case .maskToAlpha: return CIFilter.maskToAlpha()
        case .photoEffectChrome: return CIFilter.photoEffectChrome()
        case .photoEffectFade: return CIFilter.photoEffectFade()
        case .photoEffectInstant: return CIFilter.photoEffectInstant()
        case .photoEffectMono: return CIFilter.photoEffectMono()
        case .photoEffectNoir: return CIFilter.photoEffectNoir()
        case .photoEffectProcess: return CIFilter.photoEffectProcess()
        case .photoEffectTransfer: return CIFilter.photoEffectTransfer()
        case .sepiaTone: return CIFilter.sepiaTone()
        case .xRay: return CIFilter.xRay()
        }
    }
    
    var koreanName: String {
        switch self {
        case .original: return "오리지널"
        case .colorInvert: return "색상 반전"
        case .colorPosterize: return "색상 포스터화"
        case .maskToAlpha: return "마스크 투명화"
        case .photoEffectChrome: return "크롬 효과"
        case .photoEffectFade: return "페이드 효과"
        case .photoEffectInstant: return "인스턴트 효과"
        case .photoEffectMono: return "모노 효과"
        case .photoEffectNoir: return "누아르 효과"
        case .photoEffectProcess: return "프로세스 효과"
        case .photoEffectTransfer: return "전환 효과"
        case .sepiaTone: return "세피아 톤"
        case .xRay: return "X-Ray 효과"
        }
    }
}
