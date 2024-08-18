//
//  WeatherServices.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL(_ urlString: String)
    
    var description: String {
        switch self {
        case .invalidURL:
            return "invalid URL"
        }
    }
}

/// The WeatherServiceProtocol is  to define the methods that are required to be implemented by the WeatherServices class
///- fetchWeather(search: String): To retrive weather data for a given search string
///- fetchWeather(lat: Double, lon: Double): To retieve the weather data for a given latitude and longitude
protocol WeatherServiceProtocol {
    func fetchWeather(search: String) -> Future<WeatherResponse, Error>
    func fetchWeather(lat: Double, lon: Double) -> Future<WeatherResponse, Error>
}

final class WeatherService: WeatherServiceProtocol {
    struct Constants {
        static let geoBaseURL = "https://api.openweathermap.org/geo/1.0/direct"
        static let weatherBaseURL = "https://api.openweathermap.org/data/2.5/weather"
    }
    
    private var cancellables = Set<AnyCancellable>()
    var location: Location?
    
    //lat lon API- https://api.openweathermap.org/data/2.5/weather?lat=37.7656076&lon=-122.2415655&appid=AppId
    func fetchWeather(lat: Double, lon: Double) -> Future<WeatherResponse, Error> {
        return Future { promise in
            let weatherURLString = "\(Constants.weatherBaseURL)?lat=\(lat)&lon=\(lon)&appid=\(AppConstants.apiKey)"
            guard let weatherURL = URL(string: weatherURLString) else {
                promise(.failure(NetworkError.invalidURL(weatherURLString)))
                return
            }
            URLSession.shared.dataTaskPublisher(for: weatherURL)
                .map { $0.data }
                .decode(type: WeatherResponse.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        promise(.failure(err))
                    case .finished:
                        break
                    }
                } receiveValue: { weatherResponse in
                    promise(.success(weatherResponse))
                }
                .store(in: &self.cancellables)
        }
    }
    
    //Geo API- https://api.openweathermap.org/geo/1.0/direct?q=Irving,TX,usa&limit=5&appid=AppId
    private func fetchGeoLocation( _search: String) -> Future<Location, Error> {
        return Future { promise in
            let encodedSearch = _search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let geoURLString = "\(Constants.geoBaseURL)?q=\(encodedSearch)&limit=1&appid=\(AppConstants.apiKey)"
            guard let geoURL = URL(string: geoURLString) else {
                promise(.failure(NetworkError.invalidURL(geoURLString)))
                return
            }
            URLSession.shared.dataTaskPublisher(for: geoURL)
                .map { $0.data }
                .decode(type: [Location].self, decoder: JSONDecoder())
                .compactMap { $0.first }
                .sink {[weak self] completion in
                    switch completion {
                    case .failure(let err):
                        promise(.failure(err))
                    case .finished:
                        if self?.location == nil {
                            promise(.failure(NetworkError.invalidURL("Invalid location")))
                        }
                        break
                    }
                } receiveValue: {[weak self] location in
                    self?.location = location
                    promise(.success(location))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func fetchWeather(search: String) -> Future<WeatherResponse, Error> {
        location = nil
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.fetchGeoLocation(_search: search)
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        promise(.failure(err))
                    case .finished:
                        break
                    }
                } receiveValue: { location in
                    self.fetchWeather(lat: location.lat, lon: location.lon)
                        .sink { completion in
                            switch completion {
                            case .failure(let err):
                                promise(.failure(err))
                            case .finished:
                                if self.location == nil {
                                    promise(.failure(NetworkError.invalidURL("Invalid location")))
                                }
                                break
                            }
                        } receiveValue: { weatherResponse in
                            promise(.success(weatherResponse))
                        }
                        .store(in: &self.cancellables)
                }
                .store(in: &self.cancellables)
        }
    }
}
