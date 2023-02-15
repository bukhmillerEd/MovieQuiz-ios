import Foundation

class QuestionFactory: QuestionFactoryProtocol {
  
  private lazy var  randomIndices = Set(0..<movies.count)
  private var movies: [MostPopularMovie] = []
  weak var delegate: QuestionFactoryDelegate?
  private let moviesLoader: MoviesLoading
  
  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }
  
  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      guard let index = self.randomIndices.randomElement() else {
        self.delegate?.didReceiveNextQuestion(question: nil)
        return
      }
      self.randomIndices.remove(index)
      if self.randomIndices.isEmpty {
        self.randomIndices = Set(0..<self.movies.count)
      }
      guard let movie = self.movies[safe: index] else { return }
      var imageData = Data()
      do {
        imageData = try Data(contentsOf: movie.resizedImageURL)
      } catch {
        print("Failed to load image")
      }
      let rating = Float(movie.rating) ?? 0
      let text = "Рейтинг этого фильма больше чем 7?"
      let correctAnswer = rating > 7
      let question = QuizQuestion(image: imageData,
                                  text: text,
                                  correctAnswer: correctAnswer)
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
  
  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success(let mostPopularMovies):
          self.movies = mostPopularMovies.items
          self.delegate?.didLoadDataFromServer()
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error) 
        }
      }
    }
  }
  
}