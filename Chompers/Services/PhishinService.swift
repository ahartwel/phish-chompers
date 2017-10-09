//
//  PhishinService.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//
import Foundation
import Moya
import PromiseKit

fileprivate var sharedService: PhishInService = PhishInService()
protocol ServiceInjector {
    var service: PhishInService { get }
}
extension ServiceInjector {
    var service: PhishInService {
        return sharedService
    }
}

enum PhishServiceDefinition: TargetType {

    case getYears
    case showsByYear(year: String)
    case eras
    case show(id: Int)
    
    var baseURL: URL {
        return URL(string: "http://phish.in/api/v1/")!
    }
    
    var path: String {
        switch self {
        case .getYears:
            return "years"
        case .showsByYear(let year):
            return "years/\(year)"
        case .eras:
            return "eras"
        case .show(let id):
            return "shows/\(id)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        switch self {
            case .getYears:
                return "{\"success\":true,\"total_entries\":1,\"total_pages\":1,\"page\":1,\"data\":[\"1983-1987\",\"1988\",\"1989\",\"1990\",\"1991\",\"1992\",\"1993\",\"1994\",\"1995\",\"1996\",\"1997\",\"1998\",\"1999\",\"2000\",\"2002\",\"2003\",\"2004\",\"2009\",\"2010\",\"2011\",\"2012\",\"2013\",\"2014\",\"2015\",\"2016\",\"2017\"]}".data(using: .utf8) ?? Data()
            case .showsByYear:
                return "{\"success\":true,\"total_entries\":1,\"total_pages\":1,\"page\":1,\"data\":[{\"id\":1706,\"date\":\"2000-05-15\",\"duration\":5993013,\"incomplete\":false,\"missing\":false,\"sbd\":true,\"remastered\":false,\"tour_id\":88,\"venue_id\":616,\"likes_count\":2,\"taper_notes\":\"\",\"updated_at\":\"2014-08-02T01:51:50Z\",\"venue_name\":\"Sonic Studios\",\"location\":\"Philadelphia, PA\"}]}".data(using: .utf8) ?? Data()
            case .eras:
                return "{\"success\":true,\"total_entries\":1,\"total_pages\":1,\"page\":1,\"data\":{\"1.0\":[\"1983-1987\",\"1988\",\"1989\",\"1990\",\"1991\",\"1992\",\"1993\",\"1994\",\"1995\",\"1996\",\"1997\",\"1998\",\"1999\",\"2000\"],\"2.0\":[\"2002\",\"2003\",\"2004\"],\"3.0\":[\"2009\",\"2010\",\"2011\",\"2012\",\"2013\",\"2014\",\"2015\",\"2016\",\"2017\"]}}".data(using: .utf8) ?? Data()
            case .show:
                return "{\"success\":true,\"total_entries\":1,\"total_pages\":1,\"page\":1,\"data\":{\"id\":1706,\"date\":\"2000-05-15\",\"duration\":5993013,\"incomplete\":false,\"missing\":false,\"sbd\":true,\"remastered\":false,\"tags\":[\"SBD\"],\"tour_id\":88,\"venue\":{\"id\":616,\"name\":\"Sonic Studios\",\"past_names\":null,\"latitude\":39.952335,\"longitude\":-75.163789,\"shows_count\":1,\"location\":\"Philadelphia, PA\",\"slug\":\"sonic-studios\",\"updated_at\":\"2013-03-24T03:19:07Z\"},\"taper_notes\":\"\",\"likes_count\":2,\"tracks\":[{\"id\":27969,\"title\":\"First Tube\",\"position\":1,\"duration\":397819,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":1,\"slug\":\"first-tube\",\"mp3\":\"https://phish.in/audio/000/027/969/27969.mp3\",\"song_ids\":[255],\"updated_at\":\"2014-01-26T07:09:25Z\"},{\"id\":27970,\"title\":\"Farmhouse\",\"position\":2,\"duration\":353802,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"farmhouse\",\"mp3\":\"https://phish.in/audio/000/027/970/27970.mp3\",\"song_ids\":[244],\"updated_at\":\"2014-01-26T07:09:25Z\"},{\"id\":27971,\"title\":\"Twist\",\"position\":3,\"duration\":398237,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"twist\",\"mp3\":\"https://phish.in/audio/000/027/971/27971.mp3\",\"song_ids\":[806],\"updated_at\":\"2014-01-26T07:09:25Z\"},{\"id\":27972,\"title\":\"Heavy Things\",\"position\":4,\"duration\":270994,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"heavy-things\",\"mp3\":\"https://phish.in/audio/000/027/972/27972.mp3\",\"song_ids\":[337],\"updated_at\":\"2014-01-26T07:09:25Z\"},{\"id\":27973,\"title\":\"Back on the Train\",\"position\":5,\"duration\":297378,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"back-on-the-train\",\"mp3\":\"https://phish.in/audio/000/027/973/27973.mp3\",\"song_ids\":[61],\"updated_at\":\"2014-01-26T07:09:26Z\"},{\"id\":27974,\"title\":\"Piper\",\"position\":6,\"duration\":416940,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":1,\"slug\":\"piper\",\"mp3\":\"https://phish.in/audio/000/027/974/27974.mp3\",\"song_ids\":[593],\"updated_at\":\"2014-01-26T07:09:26Z\"},{\"id\":27975,\"title\":\"The Inlaw Josie Wales\",\"position\":7,\"duration\":166139,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"the-inlaw-josie-wales\",\"mp3\":\"https://phish.in/audio/000/027/975/27975.mp3\",\"song_ids\":[402],\"updated_at\":\"2014-01-26T07:09:26Z\"},{\"id\":27976,\"title\":\"Bug\",\"position\":8,\"duration\":440111,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"bug\",\"mp3\":\"https://phish.in/audio/000/027/976/27976.mp3\",\"song_ids\":[121],\"updated_at\":\"2014-01-26T07:09:26Z\"},{\"id\":27977,\"title\":\"Gotta Jibboo\",\"position\":9,\"duration\":595435,\"set\":\"1\",\"set_name\":\"Set 1\",\"likes_count\":0,\"slug\":\"gotta-jibboo\",\"mp3\":\"https://phish.in/audio/000/027/977/27977.mp3\",\"song_ids\":[308],\"updated_at\":\"2014-01-26T07:21:41Z\"},{\"id\":27978,\"title\":\"First Tube\",\"position\":10,\"duration\":411272,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"first-tube-2\",\"mp3\":\"https://phish.in/audio/000/027/978/27978.mp3\",\"song_ids\":[255],\"updated_at\":\"2014-07-15T04:45:27Z\"},{\"id\":27979,\"title\":\"Dirt\",\"position\":11,\"duration\":290220,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"dirt\",\"mp3\":\"https://phish.in/audio/000/027/979/27979.mp3\",\"song_ids\":[203],\"updated_at\":\"2014-01-26T07:21:41Z\"},{\"id\":27980,\"title\":\"Interview\",\"position\":12,\"duration\":222851,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"interview\",\"mp3\":\"https://phish.in/audio/000/027/980/27980.mp3\",\"song_ids\":[891],\"updated_at\":\"2014-01-26T07:21:41Z\"},{\"id\":27981,\"title\":\"Back on the Train\",\"position\":13,\"duration\":314410,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"back-on-the-train-2\",\"mp3\":\"https://phish.in/audio/000/027/981/27981.mp3\",\"song_ids\":[61],\"updated_at\":\"2014-07-15T04:45:27Z\"},{\"id\":27982,\"title\":\"Piper\",\"position\":14,\"duration\":407171,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"piper-2\",\"mp3\":\"https://phish.in/audio/000/027/982/27982.mp3\",\"song_ids\":[593],\"updated_at\":\"2014-07-15T04:45:27Z\"},{\"id\":27983,\"title\":\"The Inlaw Josie Wales\",\"position\":15,\"duration\":172826,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"the-inlaw-josie-wales-2\",\"mp3\":\"https://phish.in/audio/000/027/983/27983.mp3\",\"song_ids\":[402],\"updated_at\":\"2014-07-15T04:45:27Z\"},{\"id\":27984,\"title\":\"Interview\",\"position\":16,\"duration\":198087,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"interview-2\",\"mp3\":\"https://phish.in/audio/000/027/984/27984.mp3\",\"song_ids\":[891],\"updated_at\":\"2014-07-15T04:45:27Z\"},{\"id\":27985,\"title\":\"Gotta Jibboo\",\"position\":17,\"duration\":639321,\"set\":\"2\",\"set_name\":\"Set 2\",\"likes_count\":0,\"slug\":\"gotta-jibboo-2\",\"mp3\":\"https://phish.in/audio/000/027/985/27985.mp3\",\"song_ids\":[308],\"updated_at\":\"2014-07-15T04:45:27Z\"}],\"updated_at\":\"2014-08-02T01:51:50Z\"}}".data(using: .utf8) ?? Data()
            
        }
    }
    
    var task: Moya.Task {
        return Moya.Task.requestPlain
    }
    
}




class PhishInService: DataCacheInjector {
    let provider: MoyaProvider<PhishServiceDefinition>
    
    
    init(provider: MoyaProvider<PhishServiceDefinition> = MoyaProvider<PhishServiceDefinition>()) {
        self.provider = provider
        
    }
    
    
    static func createTestService() -> PhishInService {
        let provider = MoyaProvider<PhishServiceDefinition>(stubClosure: { _ in
            return StubBehavior.immediate
        })
        let service = PhishInService(provider: provider)
        return service
    }
   
    
    func getYears() -> Promise<[Year]> {
        return self.makeRequest(.getYears).then { (yearResponse: YearsResponse) -> [Year] in
            return yearResponse.data
        }
    }
    
    func getShows(fromYear year: Year) -> Promise<[Show]> {
        return self.makeRequest(.showsByYear(year: year)).then { (response: ShowsResponse) -> [Show] in
            return response.data
        }
    }
    
    func getEras() -> Promise<Eras> {
        return self.makeRequest(.eras).then { (response: EraResponse) -> Eras in
            return response.data
        }
    }
    
    func getShow(byId id: Int) -> Promise<Show> {
        return self.makeRequest(.show(id: id)).then { (response: ShowResponse) -> Show in
            return response.data
        }
    }
    
    
    private func makeRequest<T: Codable>(_ type: PhishServiceDefinition) -> Promise<T> {
        let (promise, fulfill, reject) = Promise<T>.pending()
        
        let cacheUrl = type.path
        if let response: T = self.dataCache.loadCachedResponse(forUrl: cacheUrl) {
            fulfill(response)
        }
        self.provider.request(type, completion: { result -> Void in
            switch result {
            case .success(let resp):
                let data = resp.data
                let jsonDecoder = JSONDecoder()
                let formatter = DateFormatter()
                jsonDecoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(formatter)
                do {
                    let response = try jsonDecoder.decode(T.self, from: data)
                    if !promise.isFulfilled {
                        fulfill(response)
                    }
                    self.dataCache.cacheResponse(response, url: cacheUrl)
                } catch {
                    reject(error)
                }
                
            case .failure(let error):
                reject(error)
            }
            
        })
        
        return promise
    }
    
}
