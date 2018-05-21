//
//  LoginViewController.swift
//  LoginTest
//
//  Created by Тимур Насыров on 16.05.2018.
//  Copyright © 2018 Тимур Насыров. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class LoginViewController: UIViewController {
    
    // алиас для более короткой записи преобразования json
    typealias jsonDict = Dictionary<String, AnyObject>

    @IBOutlet weak var emailTitledTextField: TitledTextField!
    @IBOutlet weak var passwordTitledTextField: TitledTextField!
    @IBOutlet weak var loginButtonBackgroundView: UIView!
    @IBOutlet weak var bottomConstraintForKeyboard: NSLayoutConstraint!
    
    // кастомный индикатор загрузки
    var activityIndicator: FullsizeActivityIndicator!
    // эта переменная нужна, чтобы не установить observer повтороно, это может произойти, если пользователь начнет свайпить на предыдущий VC в Navigation Controller, но вернется в этот VC, не отпуская палец
    private var isKeyboardObserverSet = false
    // ленивый DateFormatter: создается один раз и только при надобности
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Добавляем закругленные края к view, в котором располагается кнопка. Я не стал выделять кнопку в отельный класс для экономии времени, но лучше сделать это, если в реальном проекте такая кнопка встречается несколько раз
        loginButtonBackgroundView.clipsToBounds = true
        loginButtonBackgroundView.layer.cornerRadius = loginButtonBackgroundView.frame.height/2
        
        // Добавляем обработчик на нажатие кнопки "Забыли пароль". Self оставим unowned, потому что эта функция гарантированно может быть вызвана только в том случае, когда этот LoginViewController сущетсвует.
        passwordTitledTextField.onButtonTouch = { [unowned self] in
            self.createAndShowSingleButtonAlert(title: "Очень жаль", message: "Вспоминайте")
        }
        passwordTitledTextField.textField.isSecureTextEntry = true
        
        activityIndicator = FullsizeActivityIndicator(forView: view)
    }
    
    // Добавление и удаление обсерверов на события появления/скрытия клавиатуры
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isKeyboardObserverSet {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
            isKeyboardObserverSet = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        isKeyboardObserverSet = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTouched(_ sender: Any) {
        let isMailValid = validateEmail(emailTitledTextField.textField.text ?? "")
        let isPasswordValid = validatePassword(passwordTitledTextField.textField.text ?? "")
        
        if isMailValid && isPasswordValid {
            activityIndicator.start()
            showWeather()
        } else {
            let text: String
            if isMailValid && !isPasswordValid {
                text = "Некорректный пароль"
            } else if !isMailValid && isPasswordValid {
                text = "Некорректный email"
            } else {
                text = "Некорректны email и пароль"
            }
            createAndShowSingleButtonAlert(title: "Ошибка", message: text)
        }
    }
    
    @IBAction func createAccountButtonTouched(_ sender: Any) {
        createAndShowSingleButtonAlert(title: nil, message: "Вы нажимаете, но ничего не происходит...", buttonText: "🙁")
    }
    
    /**
     Проверка пароля на корректность
     
     - returns:
     Возвращает true если email и пароль корректны. Иначе false.
     
     - parameters:
        - password: строка для проверки
     */
    private func validatePassword(_ password: String) -> Bool {
        return password.count >= 6 && password != password.uppercased() && password != password.lowercased() && password.rangeOfCharacter(from: .decimalDigits) != nil
    }
    
    /**
     Проверка email на корректность
     
     - returns:
     Возвращает true если заданная строка является корректным email. Иначе false.
     
     - parameters:
        - testStr: строка для проверки
     */
    private func validateEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    /**
     Отобразить Alert с одной кнопкой
     
     - parameters:
        - title: заголовок
        - message: тело
        - buttonText: текст кнопки (по умолчанию "Ok")
     */
    private func createAndShowSingleButtonAlert(title: String?, message: String?, buttonText: String = "Ok") {
        let loginAlertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        loginAlertView.addAction(UIAlertAction(title: buttonText, style: .cancel))
        present(loginAlertView, animated: true)
    }

    @objc private func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        // высота клавиатуры
        let k = (i[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        // нижняя граница экрана
        var bottom: CGFloat
        if #available(iOS 11.0, *) {
            bottom = view.safeAreaInsets.bottom
        } else {
            bottom = bottomLayoutGuide.length
        }
        bottomConstraintForKeyboard.constant = k - bottom
        // время анимация появления клавиатуры (чтобы view анимировался синхронно)
        let s: TimeInterval = (i[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraintForKeyboard.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }
    
    // Далее идет моя попытка хотя бы частично разобраться с RxSwift за выходные, прошу не судить строго :)
    let disposeBag = DisposeBag()
    
    private func weatherObservable() -> Observable<String?> {
        // Получаем погоду с openweathermap.org с помощью Alamofire
        let weatherUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Moscow&appid=4accf32adb1325a1c38fb1cadf058573")!
        return Observable.create { observer in
            let request = Alamofire.request(weatherUrl).responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let responseValue):
                    // парсинг результата из JSON:
                    if let dict = responseValue as? jsonDict,
                        let main = dict["main"] as? jsonDict,
                        let temp = main["temp"] as? Double,
                        let weatherArray = dict["weather"] as? [jsonDict],
                        let weather = weatherArray[0]["main"] as? String,
                        let name = dict["name"] as? String,
                        let sys = dict["sys"] as? jsonDict,
                        let country = sys["country"] as? String,
                        let dt = dict["dt"] as? Double
                    {
                        let tempString = String(format: "%.0f °C", temp - 273.15)
                        let location = "\(name), \(country)"
                        let date = Date(timeIntervalSince1970: dt)
                        let weatherResultString = "\(self.dateFormatter.string(from: date))\n\(location)\n\(weather)\n\(tempString)"
                        
                        observer.onNext(weatherResultString)
                    } else {
                        observer.onError(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey : "Ошибка обработки ответа сервера"]))
                    }
                    
                    observer.onCompleted()
                    
                case .failure(let error):
                    observer.onError(error)
                }
            });
            return Disposables.create(with: request.cancel)
        }
    }
    
    private func showWeather() {
        // Запрашиваем погоду с помощью RxSwift (просто для примера)
        weatherObservable()
            .retry(5) // 5 попыток
            .timeout(3, scheduler: MainScheduler.instance) // с интервалом 3 секунды
            .subscribe(
                onNext: { weatherResultString in
                    self.createAndShowSingleButtonAlert(title: "Погода", message: weatherResultString)
                },
                onError: { error in
                    print(error)
                    self.createAndShowSingleButtonAlert(title: "Ошибка", message: "Возникла ошибка: \(error.localizedDescription)")
                },
                onCompleted: {
                    print("Completed")
                },
                onDisposed: {
                    print("Disposed")
                    self.activityIndicator.stop()
                }
            )
            .disposed(by: disposeBag)
    }
}
