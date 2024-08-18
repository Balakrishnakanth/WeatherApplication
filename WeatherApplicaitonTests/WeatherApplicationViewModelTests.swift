//
//  WeatherApplicationViewModelTests.swift
//  WeatherApplicaitonTests
//
//  Created by KrishnaKanth B on 8/17/24.
//

import XCTest
import Combine
@testable import WeatherApplicaiton

enum FileName: String {
    case weather_failure
    case weather_latlon
    case weather_search
    case weather_noResults
}

final class WeatherViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        cancellables = []
    }
    
    func test_getWeather_latlon_success() {
        let viewModel = WeatherViewModel(service: MockWeatherService(fileName: .weather_latlon))
        
        let exp = XCTestExpectation(description: "weather lat lon success")
        viewModel.getWeather(lat: 122.34, lon: 122.32)

        viewModel.$state
            .dropFirst()
            .sink(receiveCompletion: { completion in
                switch completion{
                case .finished:
                    break
                case .failure:
                    XCTFail()
                }
            }, receiveValue: { state in
                switch state {
                case .initial, .loading, .noResults:
                    break
                case .loaded:
                    XCTAssertEqual(state, .loaded)
                    XCTAssertEqual(viewModel.weatherList.count, 1)
                    let weather = viewModel.weatherList.first!
                    XCTAssertEqual(weather.name, "Irving")
                    XCTAssertEqual(weather.currentTemp, "57.9°")
                    XCTAssertEqual(weather.iconURLString, "https://openweathermap.org/img/wn/04d@2x.png")
                    exp.fulfill()
                case .error:
                    XCTFail()
                }
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 5)
    }
    
    func test_getWeather_latlon_failure() {
        let viewModel = WeatherViewModel(service: MockWeatherService(fileName: .weather_failure))
        
        let exp = XCTestExpectation(description: "weather lat lon failure")
        viewModel.getWeather(lat: 122.34, lon: 122.32)

        viewModel.$state
            .dropFirst()
            .sink(receiveCompletion: { completion in
                switch completion{
                case .finished:
                    break
                case .failure:
                    XCTFail()
                }
            }, receiveValue: { state in
                switch state {
                case .initial, .loading, .noResults:
                    break
                case .loaded:
                    XCTFail()
                case .error:
                    XCTAssertEqual(state, .error)
                    exp.fulfill()
                }
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 5)
    }
    
    func test_getWeather_search_success() {
        let viewModel = WeatherViewModel(service: MockWeatherService(fileName: .weather_search))
        
        let exp = XCTestExpectation(description: "weather search success")
        viewModel.getWeather("Irving")

        viewModel.$state
            .dropFirst()
            .sink(receiveCompletion: { completion in
                switch completion{
                case .finished:
                    break
                case .failure:
                    XCTFail()
                }
            }, receiveValue: { state in
                switch state {
                case .initial, .loading, .noResults:
                    break
                case .loaded:
                    XCTAssertEqual(state, .loaded)
                    XCTAssertEqual(viewModel.weatherList.count, 1)
                    let weather = viewModel.weatherList.first!
                    XCTAssertEqual(weather.name, "Irving")
                    XCTAssertEqual(weather.currentTemp, "57.9°")
                    XCTAssertEqual(weather.iconURLString, "https://openweathermap.org/img/wn/04d@2x.png")
                    exp.fulfill()
                case .error:
                    XCTFail()
                }
            })
            .store(in: &cancellables)
        wait(for: [exp], timeout: 5)
    }
    
    func test_getWeather_search_for_noLocationFound_case_results_noResults_failure() {
        
        let viewModel = WeatherViewModel(service: MockWeatherService(fileName: .weather_noResults))
        
        let exp = XCTestExpectation(description: "no results found failure")
        
        viewModel.getWeather("eeeeeee")
        
        viewModel.$state
            .sink { _ in
                XCTFail()
            } receiveValue: { state in
                switch state {
                case .initial, .loading, .loaded, .error:
                    break
                case .noResults:
                    XCTAssertEqual(state, .noResults)
                    exp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [exp], timeout: 4)
    }
}

class MockWeatherService: WeatherServiceProtocol {
    var cancellables = Set<AnyCancellable>()
    var fileName: FileName
    init(fileName: FileName) {
        self.fileName = fileName
    }
    
    private func loadMockData(_ file: String) -> URL? {
        return Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")
    }
    
    func fetchWeather(search: String) -> Future<WeatherResponse, Error> {
        return Future {[weak self] promise in
            guard let self = self else { return }
            
            if self.fileName == .weather_noResults {
                promise(.failure(NetworkError.invalidURL("The operation couldn’t be completed.")))
            }
            guard let url = self.loadMockData(self.fileName.rawValue) else { return }
            
            do {
                let data = try Data(contentsOf: url)
                
                let response = try JSONDecoder().decode([Location].self, from: data)
                self.fileName = .weather_latlon
                
                self.fetchWeather(lat: response.first!.lat, lon: response.first!.lon)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let err):
                            promise(.failure(err))
                        }
                    }, receiveValue: { weatherResponse in
                        promise(.success(weatherResponse))
                    })
                    .store(in: &self.cancellables)
            }catch (let err) {
                promise(.failure(err))
            }
        }
    }
    
    func fetchWeather(lat: Double, lon: Double) -> Future<WeatherResponse, Error> {
        return Future {[weak self] promise in
            guard let self = self else { return }
            
            guard let url = self.loadMockData(self.fileName.rawValue) else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let response = try JSONDecoder().decode(WeatherResponse.self, from: data)
                promise(.success(response))
            } catch (let err){
                promise(.failure(err))
            }
        }
    }
}

