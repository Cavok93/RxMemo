//
//  MemoComposeViewController.swift
//  RxMemo
//
//  Created by 심정섭 on 2021/08/06.
//

import UIKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

class MemoComposeViewController: UIViewController, ViewModelBindableType {

    var viewModel: MemoComposeViewModel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func bindViewModel() {
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        
        viewModel.initialText
            .drive(contentTextView.rx.text)
            .disposed(by: rx.disposeBag)
        
        
        cancelButton.rx.action = viewModel.cancelAction
        
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .withLatestFrom(contentTextView.rx.text.orEmpty)
            .bind(to: viewModel.saveAction.inputs)
            .disposed(by: rx.disposeBag)
        
        
        
        
        
        
        let willShowObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0  }
        
        
        let willHideObservable = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { noti -> CGFloat in 0  }
        
        let keyboardObservable = Observable.merge(willShowObservable, willHideObservable)
            .share()
        
        
            keyboardObservable
                .toContentInset(of: contentTextView)
                .bind(to: contentTextView.rx.contentInset)
                .disposed(by: rx.disposeBag)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        contentTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
}


extension ObservableType where Element == CGFloat {
    func toContentInset(of textView: UITextView) -> Observable<UIEdgeInsets> {
        return map { height in
            var inset = textView.contentInset
            var scrollInset = textView.scrollIndicatorInsets
            scrollInset.bottom = height
            inset.bottom =  height
            return inset
            
        }
    }
    
}


extension Reactive where Base: UITextView {
    var contentInset: Binder<UIEdgeInsets> {
        return Binder(self.base)  { textView, inset in
            textView.contentInset = inset
            textView.scrollIndicatorInsets = inset
        }
    }
}
