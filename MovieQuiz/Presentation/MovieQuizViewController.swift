import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func controlLoadingIndicator(activate: Bool)
    func showNetworkError(message: String)
    func controlEnableButtons(enable: Bool)
    func dehighlightImageBorder()
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var noButton: UIButton!
    
    private var alertPresenter: ResultAlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        controlLoadingIndicator(activate: true)
        alertPresenter = ResultAlertPresenter(delegat: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    // MARK: - Private functions
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
        let message = presenter?.makeResultsMessage() ?? ""
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) {[weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
        }
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.greenYP?.cgColor: UIColor.redYP?.cgColor
    }
    
    func controlEnableButtons(enable: Bool) {
        yesButton.isEnabled = enable
        noButton.isEnabled = enable
    }
    
    func dehighlightImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func controlLoadingIndicator(activate: Bool) {
        activityIndicator.isHidden = !activate
        if activate {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showNetworkError(message: String) {
        controlLoadingIndicator(activate: false)
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.restartGame()
        }
        alertPresenter?.showAlert(model: model)
    }
    
}
