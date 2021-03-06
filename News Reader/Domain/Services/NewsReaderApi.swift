import Foundation

/// Abstract class
class NewsReaderApi : ObservableObject {
    @Published
    var isAuthenticated = false

    internal init() {}

    func getArticles(
        onlyLikedArticles: Bool = false,
        onSuccess: @escaping (ArticleBatch) -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {}
    
    func getArticlesById(
        id: Int,
        onSuccess: @escaping (ArticleBatch) -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {}

    func login(
        username: String,
        password: String,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {}

    func register(
        username: String,
        password: String,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {}

    func getImage(
        ofImageUrl imageUrl: URL,
        onSuccess: @escaping (Data) -> Void,
        onFailure: @escaping (RequestError) -> Void
    ) {}

    func logout() {}
}
