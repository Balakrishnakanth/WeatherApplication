//
//  WeatherListView.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import SwiftUI

struct WeatherListView: View {
    @State var searchText = ""
    
    @StateObject var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    switch viewModel.state {
                    case .initial:
                        EmptyWeatherListView()
                    case .loading:
                        Text("Loading...")
                            .style(.h1, viewColor: .white)
                    case .loaded:
                        List(viewModel.weatherList) { weather in
                            WeatherCell(weather: weather)
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    case .noResults:
                        ErrorView(title: "\(viewModel.noResultMessage) \(searchText). Please try using a different text")
                    case .error:
                        ErrorView(title: viewModel.errorResultMessage)
                    }
                }
                .padding()
                .navigationTitle(Text("Weather"))
                .onAppear {
                    viewModel.shouldGetDefaultCityWeather()
                }
                
            }
        }
        .searchable(text: $searchText, prompt: "Search for a city/state in USA")
        .onChange(of: searchText, { oldValue, newValue in
            if newValue.isEmpty || viewModel.state == .noResults {
                viewModel.state = .initial
            }
        })
        .onSubmit(of: .search) {
            viewModel.getWeather(searchText)
        }
    }
}

struct WeatherListView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherListView()
    }
}
