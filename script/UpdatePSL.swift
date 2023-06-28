//
//  DomainParserDownloader.swift
//  DomainParser
//
//  Created by Jason Akakpo on 20/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation


enum ErrorType: Error {
    case notUTF8Convertible(data: Data)
    case fetchingError(details: Error?)
}
enum Result<T> {
    case success(T)
    case error(Error)
}


struct PublicSuffistListFetcher {
    typealias PublicSuffistListClosure = (Result<Data>) -> Void

    static let url = URL(string: "https://publicsuffix.org/list/public_suffix_list.dat")!
    func load(callback: @escaping PublicSuffistListClosure) {
        URLSession.shared.dataTask(with: PublicSuffistListFetcher.url) { (data, _, error) in
            do {
                guard let data = data else {
                    throw ErrorType.fetchingError(details: error)
                }
                try callback(.success(PublicSuffixListNormalizer(data: data).normalize()))
            } catch {
                callback(.error(error))
            }
            }.resume()
    }
}


struct PublicSuffixListNormalizer {
    let data: Data

    init(data: Data) {
        self.data = data
    }

    /// A valid line is a non-empty, non-comment line
    func isLineValid(line: String) -> Bool {
        return !line.isEmpty && !line.starts(with: "//")
    }

    func normalize() throws -> Data {
        guard let stringifiedData = String.init(data: data, encoding: .utf8) else { throw ErrorType.notUTF8Convertible(data: data) }

        //  From `publicsuffix.org/list/` Each line is only read up to the first whitespace; entire lines can also be commented using //.
        var validLinesArray = stringifiedData.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            .compactMap { $0.components(separatedBy: CharacterSet.whitespaces).first }
            /// Filter out useless Lines (Comments or empty ones)
            .filter(isLineValid)

        // The rules with more labels are higher priority. We want them to appear earlier in the list.
        validLinesArray.sort {
            $0.split(separator: ".").count > $1.split(separator: ".").count
        }

        return validLinesArray.joined(separator: "\n").data(using: .utf8)!
    }
}


func showError(error: Error) {
    print("Unexpected Error occured: \(error)")
}


func main() {
    let sema = DispatchSemaphore( value: 0)

    let fileRelativePath = "../DomainParser/DomainParser/Resources/public_suffix_list.dat"
    PublicSuffistListFetcher().load() { result in
        defer {
            sema.signal()
        }
        switch result {
        case let .success(data):
            let fileManager = FileManager.default
            let url = URL.init(fileURLWithPath: fileManager.currentDirectoryPath).appendingPathComponent(fileRelativePath)
            do {
                try data.write(to: url)
                print("Done :)")

            }
            catch { showError(error: error) }
        case let .error(error):
            showError(error: error)
        }
    }
    /// Wait for the Async Task finish
    sema.wait()
}

main()
