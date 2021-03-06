import Foundation
import Combine

final class ApiRequestHandler {
    private static var INSTANCE: ApiRequestHandler? = nil

    private var cancellable: AnyCancellable?

    private var scheduled: [() -> Void] = []

    private init() {}

    static func getInstance() -> ApiRequestHandler {
        let instance = self.INSTANCE ?? ApiRequestHandler()
        self.INSTANCE = instance
        return instance
    }

    func execute<ResponseType : Decodable>(
        request: URLRequest,
        onSuccess: @escaping (ResponseType) -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {
        scheduled.append({
            [unowned self] in
            self.cancellable = URLSession.shared.dataTaskPublisher(for: request)
                .map { $0.data }
                .decode(type: ResponseType.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (result) in
                    self.scheduled.removeFirst()
                    self.scheduled.first?()
                    switch result {
                    case .finished: break
                    case .failure(let error): onFailure(ApiRequestHandler.mapErrorToRequestError(error))
                    }
                }) { response in
                    onSuccess(response)
                }
        })

        if(scheduled.count == 1){
            scheduled.first?()
        }
    }

    func getImage(
        ofImageUrl imageUrl: URL,
        onSuccess: @escaping (Data) -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {
        let urlRequest = URLRequest(url: imageUrl)

        scheduled.append({
            [unowned self] in
            self.cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
                .map { $0.data }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { result in
                    self.scheduled.removeFirst()
                    self.scheduled.first?()
                    switch result {
                    case .finished: break
                    case .failure(let error): onFailure(ApiRequestHandler.mapErrorToRequestError(error))
                    }
                }) { response in
                    onSuccess(response)
                }
        })

        if(scheduled.count == 1){
            scheduled.first?()
        }
    }

    private static func mapErrorToRequestError(_ error: Error) -> RequestError {
        switch error {
        case let urlError as URLError:
            return .urlError(urlError)
        case let decodingError as DecodingError:
            return .decodingError(decodingError)
        default:
            return .genericError(error)
        }
    }
}
