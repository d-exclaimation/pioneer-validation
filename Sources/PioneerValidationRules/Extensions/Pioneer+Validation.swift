//
//  Pioneer+Validation.swift
//  PioneerValidationRules
//
//  Created by d-exclaimation on 16:10.
//

import Pioneer
import class Vapor.Request
import class Vapor.Response
import class GraphQL.GraphQLSchema

public extension Pioneer {
    /// - Parameters:
    ///   - schema: GraphQL schema used to execute operations
    ///   - resolver: Resolver used by the GraphQL schema
    ///   - contextBuilder: Context builder from request
    ///   - httpStrategy: HTTP strategy
    ///   - websocketProtocol: Websocket sub-protocol
    ///   - introspection: Allowing introspection
    ///   - playground: Allowing playground
    ///   - validationRules: Validation ruleset for each request
    ///   - keepAlive: Keep alive internal in nanosecond, default to 12.5 sec, nil for disable
    init(
        schema: GraphQLSchema,
        resolver: Resolver,
        contextBuilder: @escaping @Sendable (Request, Response) async throws -> Context,
        httpStrategy: HTTPStrategy = .queryOnlyGet,
        websocketProtocol: WebsocketProtocol = .graphqlWs,
        introspection: Bool = true,
        playground: IDE = .graphiql,
        validationRules: [ValidationRule],
        keepAlive: UInt64? = 12_500_000_000
    ) {
        self.init(
            schema: schema,
            resolver: resolver,
            contextBuilder: withValidation(with: validationRules, contextBuilder),
            httpStrategy: httpStrategy,
            websocketProtocol: websocketProtocol,
            introspection: introspection,
            playground: playground,
            keepAlive: keepAlive
        )
    }

    /// - Parameters:
    ///   - schema: GraphQL schema used to execute operations
    ///   - resolver: Resolver used by the GraphQL schema
    ///   - contextBuilder: Context builder from request
    ///   - httpStrategy: HTTP strategy
    ///   - websocketContextBuilder: Context builder for the websocket
    ///   - websocketProtocol: Websocket sub-protocol
    ///   - introspection: Allowing introspection
    ///   - playground: Allowing playground
    ///   - validationRules: Validation ruleset for each request
    ///   - keepAlive: Keep alive internal in nanosecond, default to 12.5 sec, nil for disable
    init(
        schema: GraphQLSchema,
        resolver: Resolver,
        contextBuilder: @escaping @Sendable (Request, Response) async throws -> Context,
        httpStrategy: HTTPStrategy = .queryOnlyGet,
        websocketContextBuilder: @escaping @Sendable (Request, ConnectionParams, GraphQLRequest) async throws -> Context,
        websocketProtocol: WebsocketProtocol = .graphqlWs,
        introspection: Bool = true,
        playground: IDE = .graphiql,
        validationRules: [ValidationRule],
        keepAlive: UInt64? = 12_500_000_000
    ) {
        self.init(
            schema: schema,
            resolver: resolver,
            contextBuilder: withValidation(with: validationRules, contextBuilder),
            httpStrategy: httpStrategy,
            websocketContextBuilder: withWebSocketValidation(with: validationRules, websocketContextBuilder),
            websocketProtocol: websocketProtocol,
            introspection: introspection,
            playground: playground,
            keepAlive: keepAlive
        )
    }
}