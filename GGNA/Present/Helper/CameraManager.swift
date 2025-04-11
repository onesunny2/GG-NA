//
//  CameraManager.swift
//  GGNA
//
//  Created by Lee Wonsun on 4/10/25.
//

import UIKit
import AVFoundation
import CoreImage
import RxCocoa
import RxSwift

final class CameraManager: NSObject {
    
    private let disposeBag = DisposeBag()
    
    private var captureSession = AVCaptureSession()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private var videoDataInput: AVCaptureDeviceInput?
    private var capturedImage: CIImage?
    private var videoView: VideoView?
    
    private var position: AVCaptureDevice.Position = .back
    private var positionRelay = BehaviorRelay<AVCaptureDevice.Position>(value: .back)
    
    override init() {
        super.init()
        bindDevicePosition()
    }
    
    // MARK: 촬영한 이미지 변환
    func takePhoto(scale: CGFloat = 1.0, orientation: UIImage.Orientation = .right) -> Data? {
        
        guard let ciImage = capturedImage else { return nil }
        captureSession.stopRunning()
        
        guard let pngData = ImageFilterManager.context.pngRepresentation(
            of: ciImage,
            format: CIFormat.RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        ) else { return nil }
        
        return pngData
    }
    
    // MARK: 세션 시작
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            captureSession.startRunning()
        }
    }
    
    // MARK: 카메라 위치 전환
    func changeDevicePotision() {
        position = (position == .back) ? .front : .back
        positionRelay.accept(position)
    }
}

extension CameraManager {
    
    // MARK: 기본 카메라 설정
    func setupCamera(preset: AVCaptureSession.Preset = .photo, view: VideoView) {
        self.captureSession.sessionPreset = preset
        
        do {
            try setDeviceInput(position: .back)
            setupOutput()
            videoView = view
            startSession()
        } catch {
            print("Camera Set Error: \(error)")
        }
    }
    
    // MARK: 비디오 데이터 출력 설정
    private func setupOutput() {
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        guard captureSession.canAddOutput(videoDataOutput) else { return }
        captureSession.addOutput(videoDataOutput)
    }
    
    // MARK: 입력장치(카메라) 설정
    private func setDeviceInput(position: AVCaptureDevice.Position) throws {
        
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: position
        ) else { return }
        
        let newInput = try AVCaptureDeviceInput(device: camera)
        
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
        }
        
        if let input = videoDataInput {
            captureSession.removeInput(input)
        }
        
        videoDataInput = newInput
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
        }
    }
    
    // MARK: 카메라 위치 변화 추적
    private func bindDevicePosition() {
        positionRelay
            .asDriver()
            .drive(with: self) { owner, position in
                do {
                    try owner.setDeviceInput(position: position)
                } catch {
                    print("Device Set Error: \(error)")
                }
            }
            .disposed(by: disposeBag)
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: 카메라의 새 프레임이 캡쳐될 때 호출할 메서드
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let rotated = ciImage.transformed(by: Transform.rotate90.affine)
        let flipped = flipImageWhenFront(rotated)
        capturedImage = flipped
        
        let cgImage = ImageFilterManager.context.createCGImage(flipped, from: flipped.extent)
        
        videoView?.renderCGImage(cgImage)
    }
    
    private func flipImageWhenFront(_ image: CIImage) -> CIImage {
        let transform = Transform.horizontalFlip.affine
        return (position == .front) ? image.transformed(by: transform) : image
    }
}

extension CameraManager {
    enum Transform {
        case rotate90
        case horizontalFlip
        
        var affine: CGAffineTransform {
            switch self {
            case .rotate90:
                CGAffineTransform(rotationAngle: -.pi / 2)
            case .horizontalFlip:
                CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
}
