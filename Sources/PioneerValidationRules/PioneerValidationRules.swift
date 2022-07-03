//
//  PioneerValidationRules.swift
//  PioneerValidationRules
//
//  Created by d-exclaimation on 11:55.
//

import Pioneer
import Vapor
import class Foundation.JSONDecoder
import struct GraphQL.Source
import enum GraphQL.Map

/// Validation Rule in for Pioneer context builder
public typealias ValidationRule = @Sendable (GraphQLRequest) async throws -> Void

/// Pioneer HTTP Context builder format
public typealias HTTPContextBuilder<Context> = @Sendable (Request, Response) async throws -> Context

/// Pioneer WebSocket Context builder format
public typealias WSContextBuilder<Context> = @Sendable (Request, ConnectionParams, GraphQLRequest) async throws -> Context

/// Create a context builder with validation rules
/// - Parameters:
///   - validationRules: Validation rules
///   - contextBuilder: Continuing the context builder
/// - Returns: A context builder
public func withValidation<Context>(
    with validationRules: [ValidationRule] ,
    _ contextBuilder: @escaping HTTPContextBuilder<Context>
) -> HTTPContextBuilder<Context> {
    return { @Sendable req, res async throws in
        let gql = try req.graphql
        for rule in validationRules {
            try await rule(gql)
        }
        return try await contextBuilder(req, res)
    }  
}

/// Create a websocket context builder with validation rules
/// - Parameters:
///   - validationRules: Validation rules
///   - contextBuilder: Continuing the websocket context builder
/// - Returns: A websocket context builder
public func withWebSocketValidation<Context>(
    with validationRules: [ValidationRule] ,
    _ contextBuilder: @escaping WSContextBuilder<Context>
) -> WSContextBuilder<Context> {
    return { @Sendable req, params, gql async throws in
        let gql = try req.graphql
        for rule in validationRules {
            try await rule(gql)
        }
        return try await contextBuilder(req, params, gql)
    }  
}
