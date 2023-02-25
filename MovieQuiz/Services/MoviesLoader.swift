
import Foundation

protocol MoviesLoading {
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
  private enum itemsURL: String {
    case baseURL = "https://imdb-api.com"
    case lang = "en"
    case top250 = "Top250Movies"
    case key = "k_2k4aj3em"
  }
  
  // MARK: - NetworkClient
  private let networkClient = NetworkClient()
  
  // MARK: - URL
  private var mostPopularMoviesUrl: URL {
    guard let url = URL(string: "\(itemsURL.baseURL.rawValue)/\(itemsURL.lang.rawValue)/API/\(itemsURL.top250.rawValue)/\(itemsURL.key.rawValue)") else {
      preconditionFailure("Unable to construct mostPopularMoviesUrl")
    }
    return url
  }
  
  func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
    networkClient.fetch(url: mostPopularMoviesUrl) { result in
      switch result {
      case .success(let data):
        do {
          let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
          handler(.success(mostPopularMovies))
        } catch {
          handler(.failure(error))
        }
      case .failure(let error):
        handler(.failure(error))
      }
    }
  }
}
