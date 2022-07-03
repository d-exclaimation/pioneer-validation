import XCTest
import Pioneer
@testable import PioneerValidationRules

final class PioneerValidationRulesTests: XCTestCase {
    func testDepthLimitNotPass() async throws {
        let query = """
        query {
            user(name: "Vincent") {
                id
                name
                items {
                    id
                    owner {
                        id
                        name
                        items {
                            id
                            owner {
                                id
                                name
                                items {
                                    id
                                    owner {
                                        id
                                        name
                                        items {
                                            id
                                            owner {
                                                id
                                                name
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        let gql = try query.asGraphQLQuery()
        for i in 1...8 {
            do {
                try await DepthLimit(maxDepth: i).validate(gql)
                XCTFail("Query should not pass the validation rule")
                return
            } catch {
            }
        }
    }

    func testDepthLimitPass() async throws {
        let query = """
        query {
            user(name: "Vincent") {
                id
                name
                items {
                    id
                    owner {
                        id
                        name
                        items {
                            id
                            owner {
                                id
                                name
                                items {
                                    id
                                    owner {
                                        id
                                        name
                                        items {
                                            id
                                            owner {
                                                id
                                                name
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        let gql = try query.asGraphQLQuery()
        for i in 9...15 {
            try await DepthLimit(maxDepth: i).validate(gql)
        }
    }
    

    func testDepthLimitIntrospection() async throws {
        let query = """
        query IntrospectionQuery {
          __schema {
            queryType { name }
            mutationType { name }
            subscriptionType { name }
            types {
              ...FullType
            }
            directives {
              name
              description
              args {
                ...InputValue
              }
              onOperation
              onFragment
              onField
            }
          }
        }
        fragment FullType on __Type {
            kind
            name
            description
            fields(includeDeprecated: true) {
              name
              description
              args {
                ...InputValue
              }
              type {
                ...TypeRef
              }
              isDeprecated
              deprecationReason
            }
            inputFields {
              ...InputValue
            }
            interfaces {
              ...TypeRef
            }
            enumValues(includeDeprecated: true) {
              name
              description
              isDeprecated
              deprecationReason
            }
            possibleTypes {
              ...TypeRef
            }
          }     

          fragment InputValue on __InputValue {
            name
            description
            type { ...TypeRef }
            defaultValue
          }

          fragment TypeRef on __Type {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                }
              }
            }
        }
        """
        let gql = try query.asGraphQLQuery()
        try await DepthLimit(maxDepth: 1).validate(gql)
    }
}

extension String {
    enum Parsing: Error {
        case notJsonCompatible
    }

    func asGraphQLQuery() throws -> GraphQLRequest {
        let queryJson = try JSONEncoder().encode(self)
        let queryEncoded = String(data: queryJson, encoding: .utf8) 
        let json = """
        {
            "query": \(queryEncoded ?? "null")
        }
        """
        guard let data = json.data(using: .utf8) else {
            throw Parsing.notJsonCompatible
        }
        
        return try JSONDecoder().decode(GraphQLRequest.self, from: data)
    }
}
