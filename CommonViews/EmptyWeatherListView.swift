//
//  EmptyWeatherListView.swift
//  WeatherApplicaiton
//
//  Created by KrishnaKanth B on 8/17/24.
//

import SwiftUI

struct EmptyWeatherListView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Search for a city/state in USA")
                .style(.h2, viewColor: .white)
                .minimumScaleFactor(0.5)
                .padding()
        }
    }
}

struct EmptyWeatherListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyWeatherListView()
    }
}
