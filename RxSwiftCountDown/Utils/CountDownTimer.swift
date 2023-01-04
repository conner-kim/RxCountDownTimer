//
//  CountDownTimer.swift
//  RxSwiftCountDown
//
//  Created by Conner on 2023/01/04.
//

import Foundation
import RxSwift
import RxRelay

enum CountDownTimerFormat {
    case hhmmss
    case mmss
}

enum CountDownTimerStatus {
    case start
    case pause
    case stop
    case complete
    case error
}

final class CountDownTimer {
    private var initSecond: Int = 0
    private var currentSecond: Int = 0
    private var format: CountDownTimerFormat = .mmss
    
    private var disposeBag = DisposeBag()
    
    public var currentTime = BehaviorRelay<String>(value: "00:00")
    public var timerStatus = BehaviorRelay<CountDownTimerStatus>(value: .pause)
    
    init(second: Int, format: CountDownTimerFormat = .mmss) {
        self.initSecond = second
        self.currentSecond = second
        self.format = format
    }
    
    deinit {
        self.stop()
    }
    
    public func start() {
        
        guard self.timerStatus.value != .start else {
            return
        }
        
        let totalTime = currentSecond
        self.timerStatus.accept(.start)
        
        Observable<Int>
            .timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.asyncInstance)
            .take(totalTime + 1)
            .subscribe(
                onNext: { [weak self] passTime in
                    
                    guard let self = self else {
                        return
                    }
                
                    let newSecond = totalTime - passTime
                    self.currentSecond = newSecond
                    self.currentTime.accept(self.secontsToTime(newSecond))
                },
                onError: { [weak self] error in
                    
                    guard let self = self else {
                        return
                    }
                    self.timerStatus.accept(.error)
                },
                onCompleted: {[weak self] in

                    guard let self = self else {
                        return
                    }
                    
                    self.currentSecond = self.initSecond
                    self.timerStatus.accept(.complete)
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    public func stop() {
        self.disposeBag = DisposeBag()
        self.currentSecond = self.initSecond
        self.currentTime.accept(self.secontsToTime(0))
        self.timerStatus.accept(.stop)
    }
    
    public func pause() {
        self.disposeBag = DisposeBag()
        self.timerStatus.accept(.pause)
    }
    
    func secontsToTime(_ seconds: Int) -> String {
        switch self.format {
        case .hhmmss:
            return String(format: "%02d:%02d:%02d", (seconds / 3600), (seconds % 3600) / 60, (seconds % 3600) % 60)
        case .mmss:
            return String(format: "%02d:%02d", (seconds % 3600) / 60, (seconds % 3600) % 60)
        }
    }

}
