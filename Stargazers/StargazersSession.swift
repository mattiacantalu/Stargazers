import Foundation

enum StargazersSession {
    static var configuration = MURLConfiguration(service: MURLService(),
                                                 baseUrl: MConstants.URL.base)
    static var wireframe = Wireframe(configuration: configuration)
}
