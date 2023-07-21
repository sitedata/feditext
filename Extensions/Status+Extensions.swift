// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import Mastodon
import UIKit

extension Status.Visibility {
    var systemImageName: String {
        switch self {
        case .public:
            return "network"
        case .unlisted:
            return "lock.open"
        case .private:
            return "lock"
        case .direct:
            return "envelope"
        case .unknown:
            return "questionmark"
        }
    }

    var systemImageNameForVisibilityIconColors: String {
        switch self {
        case .unlisted:
            return "lock.open.fill"
        case .private:
            return "lock.fill"
        case .direct:
            return "envelope.fill"
        default:
            return systemImageName
        }
    }

    var tintColor: UIColor? {
        switch self {
        case .public:
            return .systemBlue
        case .unlisted:
            return .systemGreen
        case .private:
            return .systemYellow
        case .direct:
            return .systemRed
        case .unknown:
            return nil
        }
    }

    var title: String? {
        switch self {
        case .public:
            return NSLocalizedString("status.visibility.public", comment: "")
        case .unlisted:
            return NSLocalizedString("status.visibility.unlisted", comment: "")
        case .private:
            return NSLocalizedString("status.visibility.private", comment: "")
        case .direct:
            return NSLocalizedString("status.visibility.direct", comment: "")
        case .unknown:
            return nil
        }
    }

    var description: String? {
        switch self {
        case .public:
            return NSLocalizedString("status.visibility.public.description", comment: "")
        case .unlisted:
            return NSLocalizedString("status.visibility.unlisted.description", comment: "")
        case .private:
            return NSLocalizedString("status.visibility.private.description", comment: "")
        case .direct:
            return NSLocalizedString("status.visibility.direct.description", comment: "")
        case .unknown:
            return nil
        }
    }
}
