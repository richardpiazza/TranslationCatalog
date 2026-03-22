@testable import TranslationCatalog

extension Project {
    static let project1 = Project(
        id: .project1,
        name: "Bakeshop",
        expressions: [
            .expression1,
            .expression2,
        ]
    )
    static let project2 = Project(
        id: .project2,
        name: "Shopclass",
        expressions: [
            .expression1,
            .expression2,
            .expression3,
        ]
    )
    static let project3 = Project(
        id: .project3,
        name: "Classmate",
        expressions: [
            .expression1,
            .expression5,
        ]
    )
}
