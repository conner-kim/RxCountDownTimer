//
//  ViewController.swift
//  RxSwiftCountDown
//
//  Created by Conner on 2023/01/04.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var pause: UIButton!
    @IBOutlet weak var stop: UIButton!
    
    private var disposeBag = DisposeBag()
    private var countDownTimer = CountDownTimer(second: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.start
            .rx
            .tap
            .asDriver()
            .drive(
                onNext: {[weak self] in
                    
                    guard let self = self else {
                        return
                    }
                    self.countDownTimer.start()
                })
            .disposed(by: self.disposeBag)
        
        self.pause
            .rx
            .tap
            .asDriver()
            .drive(
                onNext: {[weak self] in
                    
                    guard let self = self else {
                        return
                    }
                    self.countDownTimer.pause()
                })
            .disposed(by: self.disposeBag)
        
        self.stop
            .rx
            .tap
            .asDriver()
            .drive(
                onNext: {[weak self] in
                    
                    guard let self = self else {
                        return
                    }
                    self.countDownTimer.stop()
                })
            .disposed(by: self.disposeBag)
        
        countDownTimer
            .currentTime
            .subscribe(onNext: {[weak self] currentTime in
                
                guard let self = self else {
                    return
                }
                
                self.timerLabel.text = currentTime
            })
            .disposed(by: self.disposeBag)
        
        countDownTimer
            .timerStatus
            .filter {
                $0 == .complete
            }
            .map { _ -> String in
                return "완료!!"
            }
            .subscribe(self.timerLabel.rx.text)
            .disposed(by: self.disposeBag)
    }
}

