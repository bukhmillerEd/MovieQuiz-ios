import UIKit

class ResultAlertPresenter {
  
  private weak var delegate: UIViewController?
  
  init(delegat: UIViewController?) {
    self.delegate = delegat
  }
  
  func showAlert(model: AlertModel) {
    let alert = UIAlertController(title: model.title,
                                  message: model.message,
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: model.buttonText,
                               style: .default,
                               handler: model.complition)
    alert.addAction(action)
    delegate?.present(alert, animated: true, completion: nil)
  }
  
}
