//
//  FilterParameter.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/9/25.
//

import Foundation

struct FilterParameter {
    let key: String
    let defaultValue: CGFloat
    let minValue: CGFloat
    let maxValue: CGFloat
    let currentValue: CGFloat
}

extension Filter {
    
    var parameter: FilterParameter? {
        switch self {
        case .original, .photoEffectChrome, .photoEffectFade, .photoEffectInstant,
                .photoEffectMono, .photoEffectNoir, .photoEffectProcess, .comicEffect,
                .depthOfField, .colorInvert, .xRay, .photoEffectTransfer: return nil
        case .bloom, .gloom:
            return FilterParameter(key: self.effect ?? "", defaultValue: 0.5, minValue: 0.0, maxValue: 1.0, currentValue: 0.5)
        case .pixellate:
            return FilterParameter(key: self.effect ?? "", defaultValue: 8.0, minValue: 1.0, maxValue: 100.0, currentValue: 8.0)
            
        case .noiseReduction:
            return FilterParameter(key: self.effect ?? "", defaultValue: 0.02, minValue: 0.0, maxValue: 0.1, currentValue: 0.02)
            
        case .motionBlur, .boxBlur:
            return FilterParameter(key: self.effect ?? "", defaultValue: 10.0, minValue: 0.0, maxValue: 100.0, currentValue: 10.0)
            
        case .discBlur:
            return FilterParameter(key: self.effect ?? "", defaultValue: 8.0, minValue: 0.0, maxValue: 100.0, currentValue: 8.0)
            
        case .colorPosterize:
            return FilterParameter(key: self.effect ?? "", defaultValue: 6.0, minValue: 2.0, maxValue: 30.0, currentValue: 6.0)
            
        case .sepiaTone:
            return FilterParameter(key: self.effect ?? "", defaultValue: 1.0, minValue: 0.0, maxValue: 1.0, currentValue: 1.0)
        }
    }
}
