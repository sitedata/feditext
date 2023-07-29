// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import HTTP
import Mastodon

/// - https://docs.joinmastodon.org/methods/reports/
/// - https://api.pleroma.social/#tag/Reports
public enum ReportEndpoint {
    case create(Elements)
}

public extension ReportEndpoint {
    struct Elements {
        public let accountId: Account.Id
        public var statusIds = Set<Status.Id>()
        public var comment = ""
        public var forward = false
        public var category: Report.Category?
        public var ruleIDs = Set<Rule.Id>()

        public init(accountId: Account.Id) {
            self.accountId = accountId
        }
    }
}

extension ReportEndpoint: Endpoint {
    public typealias ResultType = Report

    public var context: [String] {
        defaultContext + ["reports"]
    }

    public var pathComponentsInContext: [String] {
        []
    }

    public var jsonBody: [String: Any]? {
        switch self {
        case let .create(creation):
            var params: [String: Any] = ["account_id": creation.accountId]

            if !creation.statusIds.isEmpty {
                params["status_ids"] = Array(creation.statusIds)
            }

            if !creation.comment.isEmpty {
                params["comment"] = creation.comment
            }

            if creation.forward {
                params["forward"] = creation.forward
            }

            params["category"] = creation.category?.rawValue

            if !creation.ruleIDs.isEmpty {
                params["rule_ids"] = Array(creation.ruleIDs)
            }

            return params
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .create:
            return .post
        }
    }

    public var requires: APICapabilityRequirements? {
        switch self {
        case let .create(elements):
            switch elements.category {
            case .none:
                return nil
            case .unknown:
                return [:]
            case .other:
                return .mastodonForks("3.5.0") | [
                    .mastodon: "3.5.0",
                    .hometown: "3.5.0",
                    .gotosocial: .assumeAvailable
                ]
            case .spam, .violation:
                return .mastodonForks("3.5.0")
            case .legal:
                return .mastodonForks("4.2.0")
            }
        }
    }
}
