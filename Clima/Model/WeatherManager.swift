
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weatherManager : WeatherManager , weather : WeatherModel)
    func didFailWithError (error : Error)
}

class WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=97f2a864963df7610b79219ee64c9f8c&units=metric&q="
    var delegate : WeatherManagerDelegate?
    func fetchWeather(cityName : String) {
        let urlString = weatherURL + cityName
        performRequest(with: urlString)
    }
    func fetchWeather(_ lat : CLLocationDegrees,_ lon : CLLocationDegrees) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?appid=97f2a864963df7610b79219ee64c9f8c&units=metric&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString : String) {
        //create a url
        if let url = URL(string: urlString) {
            // create session
            let session = URLSession(configuration: .default)
            
            //give session a task
            let task = session.dataTask(with: url) {
                (data , response , error) -> Void in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    //parsing of data!!
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self , weather : weather)
                    }
                }
            }
            
            //start a task
            
            task.resume()
        }
    }
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, name: name, temp: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
