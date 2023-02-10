fileprivate let text = "Рейтинг этого фильма больше чем 6?"

class QuestionFactory: QuestionFactoryProtocol {

  private let questions: [QuizQuestion] = [
    QuizQuestion(
      image: "The Godfather",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "The Dark Knight",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "Kill Bill",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "The Avengers",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "Deadpool",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "The Green Knight",
      text: text,
      correctAnswer: true),
    QuizQuestion(
      image: "Old",
      text: text,
      correctAnswer: false),
    QuizQuestion(
      image: "The Ice Age Adventures of Buck Wild",
      text: text,
      correctAnswer: false),
    QuizQuestion(
      image: "Tesla",
      text: text,
      correctAnswer: false),
    QuizQuestion(
      image: "Vivarium",
      text: text,
      correctAnswer: false)
  ]
  
  private lazy var  randomIndices = Set(0..<questions.count)
  
  weak var delegate: QuestionFactoryDelegate?
  
  init(delegate: QuestionFactoryDelegate) {
      self.delegate = delegate
  }
  
  func requestNextQuestion() {
    guard let index = randomIndices.randomElement() else {
      delegate?.didReceiveNextQuestion(question: nil)
      return
    }
    randomIndices.remove(index)
    if randomIndices.isEmpty {
      randomIndices = Set(0..<questions.count)
    }
    let question = questions[safe: index]
    delegate?.didReceiveNextQuestion(question: question)
  }
}
