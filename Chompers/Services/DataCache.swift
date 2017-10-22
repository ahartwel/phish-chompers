//
//  DataCache.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation

fileprivate var sharedCache: DataCache = DataCache()
protocol DataCacheInjector {
    var dataCache: DataCache { get }
}
extension DataCacheInjector {
    var dataCache: DataCache {
        return sharedCache
    }
}

class DataCache {
    #if TESTBUILD
    var defaults: UserDefaults {
        let standard = UserDefaults(suiteName: "testSuite")
        for key in standard!.dictionaryRepresentation().keys {
            standard!.removeObject(forKey: key)
        }
        return standard!
    }
    
    #else
    lazy var defaults: UserDefaults = {
            return UserDefaults.standard
    }()
    #endif
    func cacheResponse<T: Codable>(_ response: T, url: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(response)
            self.defaults.set(data, forKey: url)
        } catch {
            print(error.localizedDescription)
        }
    }

    func loadCachedResponse<T: Codable>(forUrl url: String) -> T? {
        guard let data = self.defaults.data(forKey: url) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let obj = try decoder.decode(T.self, from: data)
            return obj
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
