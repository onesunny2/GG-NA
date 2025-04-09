//
//  Filter.swift
//  GGNA
//
//  Created by Lee Wonsun on 3/30/25.
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

enum Filter: String, CaseIterable, Codable {
    case original
    case bloom
    case gloom
    case photoEffectChrome
    case photoEffectFade
    case photoEffectInstant
    case photoEffectMono
    case photoEffectNoir
    case photoEffectProcess
    case comicEffect
    case depthOfField
    case pixellate
    case noiseReduction
    case motionBlur
    case boxBlur
    case discBlur
    case colorPosterize
    case photoEffectTransfer
    case sepiaTone
    case colorInvert
    case xRay
    
    var type: String {
        return self.rawValue
    }
    
    var filter: CIFilter? {
        switch self {
        case .original: return nil
        case .bloom: return CIFilter.bloom()
        case .gloom: return CIFilter.gloom()
        case .photoEffectChrome: return CIFilter.photoEffectChrome()
        case .photoEffectFade: return CIFilter.photoEffectFade()
        case .photoEffectInstant: return CIFilter.photoEffectInstant()
        case .photoEffectMono: return CIFilter.photoEffectMono()
        case .photoEffectNoir: return CIFilter.photoEffectNoir()
        case .photoEffectProcess: return CIFilter.photoEffectProcess()
        case .comicEffect: return CIFilter.comicEffect()
        case .depthOfField: return CIFilter.depthOfField()
        case .pixellate: return CIFilter.pixellate()
        case .noiseReduction: return CIFilter.noiseReduction()
        case .motionBlur: return CIFilter.motionBlur()
        case .boxBlur: return CIFilter.boxBlur()
        case .discBlur: return CIFilter.discBlur()
        case .colorPosterize: return CIFilter.colorPosterize()
        case .photoEffectTransfer: return CIFilter.photoEffectTransfer()
        case .sepiaTone: return CIFilter.sepiaTone()
        case .colorInvert: return CIFilter.colorInvert()
        case .xRay: return CIFilter.xRay()
        }
    }
    
    var koreanName: String {
        switch self {
        case .original: return "오리지널"
        case .bloom: return "블룸"
        case .gloom: return "글룸"
        case .photoEffectChrome: return "크롬 효과"
        case .photoEffectFade: return "페이드 효과"
        case .photoEffectInstant: return "인스턴트 효과"
        case .photoEffectMono: return "모노 효과"
        case .photoEffectNoir: return "누아르 효과"
        case .photoEffectProcess: return "프로세스 효과"
        case .comicEffect: return "만화 효과"
        case .depthOfField: return "심도 효과"
        case .pixellate: return "픽셀화"
        case .noiseReduction: return "노이즈 감소"
        case .motionBlur: return "모션 블러"
        case .boxBlur: return "박스 블러"
        case .discBlur: return "원형 블러"
        case .colorPosterize: return "색상 포스터화"
        case .photoEffectTransfer: return "전환 효과"
        case .sepiaTone: return "세피아 톤"
        case .colorInvert: return "색상 반전"
        case .xRay: return "X-Ray 효과"
        }
    }
    
    var effect: String? {
        switch self {
        case .original: nil
        case .bloom: "intensity"
        case .gloom: "intensity"
        case .photoEffectChrome: nil
        case .photoEffectFade: nil
        case .photoEffectInstant: nil
        case .photoEffectMono: nil
        case .photoEffectNoir: nil
        case .photoEffectProcess: nil
        case .comicEffect: nil
        case .depthOfField: nil
        case .pixellate: "scale"
        case .noiseReduction: "noiseLevel"
        case .motionBlur: "radius"
        case .boxBlur: "radius"
        case .discBlur: "radius"
        case .colorPosterize: "levels"
        case .photoEffectTransfer: nil
        case .sepiaTone: "intensity"
        case .colorInvert: nil
        case .xRay: nil
        }
    }
}
