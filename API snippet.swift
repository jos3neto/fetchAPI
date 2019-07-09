//
//  API snippet.swift
//  
//
//  Created by Jose on 9/7/19.
//

import Foundation

//Define specific errors.
enum NetworkingError: Error
{
	case connectionError
	case clientError
	case serverError
	case nilData
	case deserializationError
}

//Create typealias using Swift 5's new Result type.
typealias Handler = (Result<Dictionary<String,String>, NetworkingError>) -> Void

//Define method to fetch quotes from API.
func fetchQuote(completionHandler: @escaping Handler)
{
	let url = URL(string: "http://api.forismatic.com/api/1.0/?method=getQuote&lang=en&format=json")!
	let task = URLSession.shared.dataTask(with: url)
	{ data, response, error in
		if error != nil
		{
			completionHandler(.failure(.connectionError))
			return
		}
		guard let response = response as? HTTPURLResponse else
		{
			completionHandler(.failure(.serverError))
			return
		}
		if (400...599).contains(response.statusCode)
		{
			if (400...499).contains(response.statusCode)
			{
				completionHandler(.failure(.clientError))
			} else
			{
				completionHandler(.failure(.serverError))
			}
			return
		}
		guard let data = data else
		{
			completionHandler(.failure(.nilData))
			return
		}
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String,String> else
		{
			completionHandler(.failure(.deserializationError))
			return
		}
		completionHandler(.success(jsonObject))
	}
	task.resume()
}

//Call method to fetch quotes and print.
fetchQuote
	{ result in
		switch result
		{
		case .success(let quote):
			print(quote["quoteText"]!)
			print(quote["quoteAuthor"]!)
		case .failure(let error):
			print(error)
		}
}
