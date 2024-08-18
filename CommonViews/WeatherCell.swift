//
//  WeatherCell.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import SwiftUI

/// This view is responsible for showing the weather data for a city

struct WeatherCell: View {
    let weather: WeatherInfo
    
    var body: some View {
        VStack(spacing: 35) {
            cityWeather
            averageWeather
        }
        .background(Color.clear)
    }
    
    var cityWeather: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(weather.name)
                    .style(.h2)
                Text(weather.time)
                    .style(.small)
            }
            Spacer()
            Text(weather.currentTemp)
                .style(.h2)
        }
        .background(Color.clear)

    }
    
    var averageWeather: some View {
        HStack {
                Text(weather.description)
                .style(.small)
            AsyncImage(url: URL(string: weather.iconURLString)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            } placeholder: {
                Image(systemName:"cloud.sun")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }

            Spacer()
            Text("H: \(weather.tempHigh) L: \(weather.tempLow)")
                .style(.small_bold)
        }
        .background(Color.clear)
    }
}

struct WeatherCell_Previews: PreviewProvider {
    static var previews: some View {
        WeatherCell(weather: WeatherInfo.mock)
    }
}
