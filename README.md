## CloudPayments SDK for iOS 

CloudPayments SDK позволяет интегрировать прием платежей в мобильные приложения для платформы iOS.

### Требования
Для работы CloudPayments SDK необходим iOS версии 13.0 и выше.

### Подключение
Для подключения SDK мы рекомендуем использовать CocoaPods. Добавьте в файл Podfile зависимости:

```
pod 'Cloudpayments', :git =>  "https://gitpub.cloudpayments.ru/integrations/sdk/cloudpayments-ios", :branch => "master"
pod 'CloudpaymentsNetworking', :git =>  "https://gitpub.cloudpayments.ru/integrations/sdk/cloudpayments-ios", :branch => "master"
```

### Структура проекта:

* **demo** - Пример реализации приложения с использованием SDK
* **sdk** - Исходный код SDK

### Возможности CloudPayments SDK:

Вы можете использовать SDK одним из трех способов: 
* использовать стандартную платежную форму Cloudpayments
* реализовать свою платежную форму с использованием функций CloudpaymentsApi без вашего сервера
* реализовать свою платежную форму, сформировать криптограмму и отправить ее на свой сервер

## Инициализация CloudPaymentsSDK

В `AppDelegate.swift` вашего проекта добавьте нотификацию `CloudtipsSDK` о событиях жизненного цикла приложения:

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return true
}

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return true
}
```

### Использование стандартной платёжной формы от CloudPayments:

1. Cоздайте объект PaymentDataPayer и проинициализируйте его, затем создайте объект PaymentData передайте в него объект PaymentDataPayer, сумму платежа, валюту и дополнительные данные. Если хотите иметь возможность оплаты с помощью Apple Pay, передайте также Apple pay merchant id.

```
// Доп. поле, куда передается информация о плательщике. Используйте следующие параметры: FirstName, LastName, MiddleName, Birth, Street, Address, City, Country, Phone, Postcode
let payer = PaymentDataPayer(firstName: "Test", lastName: "Testov", middleName: "Testovich", birth: "1955-02-22", address: "home 6", street: "Testovaya", city: "Moscow", country: "RU", phone: "89991234567", postcode: "12345")
    
// Указывайте дополнительные данные если это необходимо
let jsonData: [String: Any] = ["age":27, "name":"Ivan", "phone":"+79998881122"] // Любые другие данные, которые будут связаны с транзакцией, в том числе инструкции для создания подписки или формирования онлайн-чека должны обёртываться в объект cloudpayments. Мы зарезервировали названия следующих параметров и отображаем их содержимое в реестре операций, выгружаемом в Личном Кабинете: name, firstName, middleName, lastName, nick, phone, address, comment, birthDate.

let paymentData = PaymentData() 
    .setAmount(String(totalAmount)) // Cумма платежа в валюте, максимальное количество не нулевых знаков после запятой: 2
    .setCurrency(.ruble) // Валюта
    .setApplePayMerchantId("") // Apple pay merchant id (Необходимо получить у Apple)
    .setDescription("Корзина цветов") // Описание оплаты в свободной форме
    .setAccountId("111") // Обязательный идентификатор пользователя для создания подписки и получения токена
    .setIpAddress("98.21.123.32") // IP-адрес плательщика
    .setInvoiceId("123") // Номер счета или заказа
    .setEmail("test@cp.ru") // E-mail плательщика, на который будет отправлена квитанция об оплате
    .setPayer(payer) // Информация о плательщике
    .setJsonData(jsonData) // Любые другие данные, которые будут связаны с транзакцией               
```

1.1. Сплитование 

Данный функционал работает только при оплате банковской картой, поэтому при передаче объекта splitsData в PaymentData все остальные способы оплаты будут отключены.

```
let split1 = Split(publicID: "SubMerchantPublicID_1",amount: "5")
let split2 = Split(publicID: "SubMerchantPublicID_2",amount: "6")
                            
let splits = Splits(splits: [split1, split2])

paymentData.setSplits([splits])
```

2. Создайте объект PaymentConfiguration, передайте в него объект PaymentData и ваш **Public_id** из [личного кабинета Cloudpayments](https://merchant.cloudpayments.ru/). Реализуйте протокол PaymentDelegate, чтобы узнать о завершении платежа

```
let configuration = PaymentConfiguration.init(
    publicId: "", // Ваш Public_id из личного кабинета
    paymentData: paymentData, // Информация о платеже
    delegate: self, // Вывод информации о завершении платежа
    uiDelegate: self, // Вывод информации о UI 
    scanner: nil, // Сканер банковских карт
    requireEmail: true, // Обязательный email, (по умолчанию false)
    useDualMessagePayment: true, // Использовать двухстадийную схему проведения платежа, (по умолчанию используется одностадийная схема)
    disableApplePay: false, // Выключить Apple Pay, (по умолчанию Apple Pay включен)
    successRedirectUrl: "" // Ваш deeplink для редиректа из приложения банка после успешной оплаты, (если ничего не передано, по умолчанию используется URL адрес вашего сайта)
    failRedirectUrl: "" //  Ваш deeplink для редиректа из приложения банка после неуспешной оплаты, (если ничего не передано, по умолчанию используется URL адрес вашего сайта)
```
2.1. Для передачи deeplink при использовании CБП и TinkoffPay нужно использовать Universal Links:

2.2. Документация от Apple: [Universal Links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)

2.3. В вашем приложении реализуйте метод application(_:continue:restorationHandler:) в классе вашего AppDelegate для обработки Universal Links

### Использование TinkoffPay в стандартной платёжной форме:

1. Включить TinkoffPay в [личном кабинете Cloudpayments](https://merchant.cloudpayments.ru/).

2. Для определения наличия мобильного приложения Тинькофф на устройстве пользователя, добавьте значение **tinkoffbank** в массив по ключу **LSApplicationQueriesSchemes** в файл **Info.plist** вашего приложения:

```
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tinkoffbank</string>
</array>
```
Благодаря этому SDK сможет корректно определить наличие приложения Тинькофф на устройстве пользователя.

### Использование отдельной кнопки TinkoffPay:

1. Включить TinkoffPay в [личном кабинете Cloudpayments](https://merchant.cloudpayments.ru/).

2. Для определения наличия мобильного приложения Тинькофф на устройстве пользователя, добавьте значение **tinkoffbank** в массив по ключу **LSApplicationQueriesSchemes** в файл **Info.plist** вашего приложения:

```
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>tinkoffbank</string>
</array>
```

3.Создайте объект PaymentTPayView и разместите его

   ``` 
    private lazy var tinkoffView = PaymentTPayView() 
    private lazy var tinkoffLabel = UILabel()
    
    private func setupTinkoffView() {
    
    // делегат
    tinkoffView.delegate = self 

    view.addSubview(tinkoffView)
    tinkoffView.addSubview(tinkoffLabel)

    tinkoffView.backgroundColor = .black
    tinkoffView.layer.cornerRadius = 8

    tinkoffLabel.text = "Тинькофф Pay"
    tinkoffLabel.textColor = .white

    tinkoffView.translatesAutoresizingMaskIntoConstraints = false
    tinkoffLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
    tinkoffView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
    tinkoffView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
    tinkoffView.heightAnchor.constraint(equalToConstant: 50),
    tinkoffView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

    tinkoffLabel.centerXAnchor.constraint(equalTo: tinkoffView.centerXAnchor),
    tinkoffLabel.centerYAnchor.constraint(equalTo: tinkoffView.centerYAnchor)
    ])
    }
   ```
4.Создайте метод с конфигурацией  

    private func addConfiguration() {

    let jsonObject: [String: Any?] = [:]

    func JSONStringify(value: [String: Any?], prettyPrinted:Bool = false) -> String {
    let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
    if JSONSerialization.isValidJSONObject(value) {
    do {
    let data = try JSONSerialization.data(withJSONObject: value, options: options)
    if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
    return string as String
    }
    } catch {

    print("parsing error")
        }
    }
    return ""
    }

    let dataString = JSONStringify(value: jsonObject) 

    let paymentData = PaymentData()
    .setAmount("10")
    .setCurrency("RUB")
    .setDescription("Корзина цветов")
    .setAccountId("111")
    .setInvoiceId("123")
    .setEmail("test@cp.ru")
    .setJsonData(dataString)

    let configuration = PaymentConfiguration(
    publicId: "", // // Ваш Public_id из личного кабинета
    paymentData: paymentData, // Информация о платеже
    successRedirectUrl: "" // Ваш deeplink для редиректа из приложения банка после успешной оплаты, (если ничего не передано, по умолчанию используется URL адрес вашего сайта)
    failRedirectUrl: "" // Ваш deeplink для редиректа из приложения банка после неуспешной оплаты, (если ничего не передано, по умолчанию используется URL адрес вашего сайта)
    useDualMessagePayment: true) // Использовать двухстадийную схему проведения платежа, (по умолчанию используется одностадийная схема)

    tinkoffView.configuration = configuration // передайте конфигурацию в объект PaymentTPayView
    }
    
5.Создайте метод для проверки доступности TinkoffPay  
    
    private func checkTPayView() {
        tinkoffView.getMerchantConfiguration(publicId: "Ваш Public_id") { [ weak self ] result in
            guard let self = self, let result = result else { return }
            // проверка доступности TinkoffPay и её отображение 
            self.tinkoffView.isHidden = !result.isOnButton     
        }
    }

6.Подпишитесь на протокол PaymentTPayDelegate и обработайте результаты

    extension TPayDemoViewController: PaymentTPayDelegate {
    func resultPayment(_ tPay: Cloudpayments.PaymentTPayView, result: Cloudpayments.PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?) {
    switch result {
    case .success:
    print("Оплата прошла успешно")
    case .error:
    print("Ошибка")
    case .close:
    print("Пользователь закрыл платёжную форму TinkoffPay")
    }
    } }
    
### Использование СБП в стандартной платёжной форме: 

Включить СБП через вашего курирующего менеджера.

3. Вызовите форму оплаты внутри своего контроллера

```
PaymentForm.present(with: configuration, from: self)
```

4. Сканер карт

Вы можете подключить любой сканер карт. Для этого нужно реализовать протокол PaymentCardScanner и передать объект, реализующий протокол, при создании PaymentConfiguration. Если протокол не будет реализован, то кнопка сканирования не будет показана

Пример со сканером [CardIO](https://github.com/card-io/card.io-iOS-SDK)

* Создайте контроллер со сканером и верните его в функции протокола PaymentCardScanner
```
extension CartViewController: PaymentCardScanner {
    func startScanner(completion: @escaping (String?, UInt?, UInt?, String?) -> Void) -> UIViewController? {
        self.scannerCompletion = completion
        
        let scanController = CardIOPaymentViewController.init(paymentDelegate: self)
        return scanController
    }
}
```
* После завершения сканирования вызовите замыкание и передайте данные карты
```
extension CartViewController: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        self.scannerCompletion?(cardInfo.cardNumber, cardInfo.expiryMonth, cardInfo.expiryYear, cardInfo.cvv)
        paymentViewController.dismiss(animated: true, completion: nil)
    }
}
```


### Использование вашей платежной формы с использованием функций CloudPaymentsApi:

* **Для использования нового формата криптограммы:**

1. Получите **publicKey** и **keyVersion** с данного [API](https://api.cloudpayments.ru/payments/publickey)
2. Полученные **publicKey** и **keyVersion** передайте в метод создания криптограммы.

3. Cоздайте криптограмму карточных данных

```
// Обязательно проверяйте входящие данные карты (номер, срок действия и cvc код) на корректность, иначе метод создания криптограммы вернет nil.
let cardCryptogramPacket = Card.makeCardCryptogramPacket(cardNumber: cardNumber, expDate: expDate, cvv: cvv, merchantPublicID: "Ваш Public_id", publicKey: "Полученный публичный ключ", keyVersion: "Полученная версия ключа")
```

4. Выполните запрос на проведения платежа. Создайте объект CloudpaymentApi и вызовите метод charge для одностадийного платежа или auth для двухстадийного. Укажите email, на который будет выслана квитанция об оплате.

```
let api = CloudpaymentsApi.init(publicId: Constants.merchantPulicId)
api.auth(cardCryptogramPacket: cardCryptogramPacket, cardHolderName: cardHolderName, email: nil, amount: String(total)) { [weak self] (response, error) in
    if let response = response {
        self?.checkTransactionResponse(transactionResponse: response, completion: completion)
    } else if let error = error {
        completion?(false, error.localizedDescription)
    }
}
```

5. Если необходимо, покажите 3DS форму для подтверждения платежа

```
let data = ThreeDsData.init(transactionId: transactionId, paReq: paReq, acsUrl: acsUrl)
let threeDsProcessor = ThreeDsProcessor()
threeDsProcessor.make3DSPayment(with: data, delegate: self)
```

6. Для получения формы 3DS и получения результатов прохождения 3DS аутентификации реализуйте протокол ThreeDsDelegate.

```
extension CheckoutViewController: ThreeDsDelegate {
    // Вы получаете объект WKWebView, который сами показываете нужным вам способом и в нужном вам месте
    func willPresentWebView(_ webView: WKWebView) {
        self.showThreeDsForm(webView)
    }

    // Для завершения оплаты в выполните метод post3ds CloudpaymentsApi. 
    // threeDsCallbackId - идентификатор, полученный в ответ на запрос на проведение платежа
    func onAuthotizationCompleted(with md: String, paRes: String) {
        hideThreeDs()
        post3ds(transactionId: md, paRes: paRes, threeDsCallbackId: threeDsCallbackId)
    }

    func onAuthorizationFailed(with html: String) {
        hideThreeDs()
        print("error: \(html)")
    }

}
```

#### Оплата с помощью Apple Pay с CloudPaymentsApi

[Об Apple Pay](https://developers.cloudpayments.ru/#apple-pay)

1. Создайте массив объектов PKPaymentSummaryItem используя информацию о товарах выбранных вашим клиентом
```
var paymentItems: [PKPaymentSummaryItem] = []
for product in CartManager.shared.products {
    let paymentItem = PKPaymentSummaryItem.init(label: product.name, amount: NSDecimalNumber(value: Int(product.price)!))
    paymentItems.append(paymentItem)
}
```
2. Укажите ваш Apple Pay ID и допустимые платежные системы
```
let applePayMerchantID = "merchant.com.YOURDOMAIN" // Ваш ID для Apple Pay
let paymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard] // Платежные системы для Apple Pay
```
3. Проверьте, доступны ли пользователю эти платежные системы
```
buttonApplePay.isHidden = !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) // Скройте кнопку Apple Pay если пользователю недоступны указанные вами платежные системы
```
4. Создайте и выполните запрос к Apple Pay
```
let request = PKPaymentRequest()
request.merchantIdentifier = applePayMerchantID
request.supportedNetworks = paymentNetworks
request.merchantCapabilities = PKMerchantCapability.capability3DS // Возможно использование 3DS
request.countryCode = "RU" // Код страны
request.currencyCode = "RUB" // Код валюты
request.paymentSummaryItems = paymentItems
let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
applePayController?.delegate = self
self.present(applePayController!, animated: true, completion: nil)
```
5. Обрабатываем ответ от Apple Pay
```
extension CheckoutViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.success)
        
        // Конвертируйте объект PKPayment в строку криптограммы
        guard let cryptogram = payment.convertToString() else {
            return
        }
               
        // Используйте методы API для выполнения оплаты по криптограмме
        // (charge (для одностадийного платежа) или auth (для двухстадийного))
        //charge(cardCryptogramPacket: cryptogram, cardHolderName: "")
        auth(cardCryptogramPacket: cryptogram, cardHolderName: "")
      
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
```

#### ВАЖНО:

При обработке успешного ответа от Apple Pay, обязательно выполните преобразование объекта PKPayment в криптограмму для передачи в платежное API CloudPayments

```
let cryptogram = payment.convertToString() 
```
После успешного преобразования криптограмму можно использовать для проведения оплаты.

### Другие функции

* Проверка карточного номера на корректность

```
Card.isCardNumberValid(cardNumber)

```

* Проверка срока действия карты

```
Card.isExpDateValid(expDate) // expDate в формате MM/yy

```

* Определение типа платежной системы

```
let cardType: CardType = Card.cardType(from: cardNumberString)
```

* Определение банка эмитента

```
CloudpaymentsApi.getBankInfo(cardNumber: cardNumber) { (info, error) in
    if let error = error {
        print("error: \(error.message)")
    } else {
        if let bankName = info?.bankName {
            print("BankName: \(bankName)")
        } else {
            print("BankName is empty")
        }
        
        if let logoUrl = info?.logoUrl {
            print("LogoUrl: \(logoUrl)")
        } else {
            print("LogoUrl is empty")
        }
    }
}
```

* Шифрование карточных данных и создание криптограммы для отправки на сервер

```
let cardCryptogramPacket = Card.makeCardCryptogramPacket(with: cardNumber, expDate: expDate, cvv: cvv, merchantPublicID: Constants.merchantPulicId)
```

* Шифрование cvv при оплате сохраненной картой и создание криптограммы для отправки на сервер

```
let cvvCryptogramPacket = Card.makeCardCryptogramPacket(with: cvv)
```

* Преобразование PKPayment в строку-криптограмму для отправки на сервер

```
let payment: PKPayment
let cryptogram = payment.convertToString()
```

* Отображение 3DS формы и получении результата 3DS аутентификации

```
let data = ThreeDsData.init(transactionId: transactionId, paReq: paReq, acsUrl: acsUrl)
let threeDsProcessor = ThreeDsProcessor()
threeDsProcessor.make3DSPayment(with: data, delegate: self)

public protocol ThreeDsDelegate: class {
    func willPresentWebView(_ webView: WKWebView)
    func onAuthotizationCompleted(with md: String, paRes: String)
    func onAuthorizationFailed(with html: String)
}
```

### История обновлений:


#### 1.5.2
* Улучшена валидация

* Повышена надежность

#### 1.5.1
* Добавлен режим запуска SDK TinkoffPay

* Добавлена возможность педедать deeplink для перехода из приложения Tinkoff после оплаты

* Отключен YandexPay

#### 1.5.0
* Повышена надежность

#### 1.4.2
* Обновлен YandexPay SDK

* Исправлена передача email при оплате через YandexPay 

#### 1.4.1
* Исправлена передача accountId при оплате через СБП
 
* Отключена переадресация на сайт эквайера из приложения банка после оплаты через СБП

#### 1.4.0
* Добавлен новый способ оплаты: оплата через СБП (см. документацию для получения более подробной информации: https://gitpub.cloudpayments.ru/integrations/sdk/cloudpayments-ios/-/blob/master/README.md)

* Оптимизировано получение параметров шлюза и проверка доступности способов оплаты: теперь экран способов оплаты появляется сразу со всеми подключенными и доступными способами оплаты

* Оптимизирован интерфейс окна Выбор способов оплаты, теперь он работает плавнее

* Добавлена проверка интерент соединения во время запука SDK, теперь пользователь не пройдет дальше по сценарию оплаты если сервер не доступен

* Внесено значительное количество небольших исправлений и улучшений


### Поддержка

По возникающим вопросам технического характера обращайтесь на support@cp.ru
