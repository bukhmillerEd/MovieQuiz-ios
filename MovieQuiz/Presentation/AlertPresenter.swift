import UIKit

class AlertPresenter {
  
  private weak var delegat: UIViewController?
  
  init(delegat: UIViewController?) {
    self.delegat = delegat
  }
  
  func showAlert(model: AlertModel) {
    let alert = UIAlertController(title: model.title,
                                  message: model.message,
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: model.buttonText,
                               style: .default,
                               handler: model.complition)
    alert.addAction(action)
    delegat?.present(alert, animated: true, completion: nil)
  }
  
}
