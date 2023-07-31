// Copyright © 2020 Metabolist. All rights reserved.

import Combine
import DB
import Foundation
import Mastodon
import MastodonAPI

public enum Navigation {
    case url(URL)
    case collection(CollectionService)
    case profile(ProfileService)
    case notification(NotificationService)
    case searchScope(SearchScope)
    case webfingerStart
    case webfingerEnd
    case authenticatedWebView(AuthenticatedWebViewService, URL)
}

public struct NavigationService {
    private let environment: AppEnvironment
    private let mastodonAPIClient: MastodonAPIClient
    private let contentDatabase: ContentDatabase
    private let status: Status?

    public init(
        environment: AppEnvironment,
        mastodonAPIClient: MastodonAPIClient,
        contentDatabase: ContentDatabase,
        status: Status? = nil
    ) {
        self.environment = environment
        self.mastodonAPIClient = mastodonAPIClient
        self.contentDatabase = contentDatabase
        self.status = status
    }
}

public extension NavigationService {
    /// Set `shouldWebfinger` to `true` when we know the URL should resolve to some activity or actor,
    /// like when resolving a mentioned user.
    func item(url: URL, shouldWebfinger: Bool = false) -> AnyPublisher<Navigation, Never> {
        if let tag = tag(url: url) {
            return Just(
                .collection(
                    TimelineService(
                        timeline: .tag(tag),
                        environment: environment,
                        mastodonAPIClient: mastodonAPIClient,
                        contentDatabase: contentDatabase)))
                .eraseToAnyPublisher()
        } else if let accountId = accountId(url: url) {
            return Just(.profile(profileService(id: accountId))).eraseToAnyPublisher()
        } else if mastodonAPIClient.instanceURL.host == url.host, let statusId = url.statusId {
            return Just(.collection(contextService(id: statusId))).eraseToAnyPublisher()
        }

        if shouldWebfinger || url.shouldWebfinger {
            return webfinger(url: url)
        } else {
            return Just(.url(url)).eraseToAnyPublisher()
        }
    }

    func contextService(id: Status.Id) -> ContextService {
        ContextService(id: id, environment: environment,
                       mastodonAPIClient: mastodonAPIClient,
                       contentDatabase: contentDatabase)
    }

    func profileService(id: Account.Id) -> ProfileService {
        ProfileService(id: id,
                       environment: environment,
                       mastodonAPIClient: mastodonAPIClient,
                       contentDatabase: contentDatabase)
    }

    func profileService(
        account: Account,
        relationship: Relationship? = nil,
        familiarFollowers: [Account] = []
    ) -> ProfileService {
        ProfileService(account: account,
                       relationship: relationship,
                       familiarFollowers: familiarFollowers,
                       environment: environment,
                       mastodonAPIClient: mastodonAPIClient,
                       contentDatabase: contentDatabase)
    }

    func statusService(status: Status) -> StatusService {
        StatusService(environment: environment,
                      status: status,
                      mastodonAPIClient: mastodonAPIClient,
                      contentDatabase: contentDatabase)
    }

    func accountService(account: Account) -> AccountService {
        AccountService(account: account,
                       environment: environment,
                       mastodonAPIClient: mastodonAPIClient,
                       contentDatabase: contentDatabase)
    }

    func familiarFollowersService(familiarFollowers: [Account]) -> FixedAccountListService {
        FixedAccountListService(
            accounts: familiarFollowers,
            accountConfiguration: .withNote,
            environment: environment,
            mastodonAPIClient: mastodonAPIClient,
            contentDatabase: contentDatabase,
            titleComponents: ["account-list.title.familiar-followers"]
        )
    }

    func loadMoreService(loadMore: LoadMore) -> LoadMoreService {
        LoadMoreService(loadMore: loadMore, mastodonAPIClient: mastodonAPIClient, contentDatabase: contentDatabase)
    }

    func notificationService(notification: MastodonNotification) -> NotificationService {
        NotificationService(
            notification: notification,
            environment: environment,
            mastodonAPIClient: mastodonAPIClient,
            contentDatabase: contentDatabase)
    }

    func multiNotificationService(
        notifications: [MastodonNotification],
        notificationType: MastodonNotification.NotificationType,
        date: Date
    ) -> MultiNotificationService {
        MultiNotificationService(
            notificationServices: notifications.map { notification in
                notificationService(notification: notification)
            },
            notificationType: notificationType,
            date: date,
            environment: environment,
            mastodonAPIClient: mastodonAPIClient,
            contentDatabase: contentDatabase
        )
    }

    func conversationService(conversation: Conversation) -> ConversationService {
        ConversationService(
            conversation: conversation,
            environment: environment,
            mastodonAPIClient: mastodonAPIClient,
            contentDatabase: contentDatabase)
    }

    func announcementService(announcement: Announcement) -> AnnouncementService {
        AnnouncementService(announcement: announcement,
                            environment: environment,
                            mastodonAPIClient: mastodonAPIClient,
                            contentDatabase: contentDatabase)
    }

    func timelineService(timeline: Timeline) -> TimelineService {
        TimelineService(timeline: timeline,
                        environment: environment,
                        mastodonAPIClient: mastodonAPIClient,
                        contentDatabase: contentDatabase)
    }

    /// Open a report in the web interface.
    func report(id: Report.Id) -> Navigation {
        return .authenticatedWebView(
            AuthenticatedWebViewService(environment: environment),
            mastodonAPIClient.instanceURL.appendingPathComponents("admin", "reports", id)
        )
    }

    /// Edit the user's public profile in the web interface.
    func editProfile() -> Navigation? {
        let url: URL
        switch mastodonAPIClient.apiCapabilities.flavor {
        case nil:
            return nil
        case .mastodon, .glitch, .hometown:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("settings", "profile")
        case .pleroma, .akkoma:
            // Akkoma's web UI doesn't support deep linking to settings.
            return nil
        case .gotosocial:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("settings", "user", "profile")
        case .calckey, .firefish:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("settings", "profile")
        }

        return .authenticatedWebView(
            AuthenticatedWebViewService(environment: environment),
            url
        )
    }

    /// Edit the user's account settings (password, etc.) in the web interface.
    func accountSettings() -> Navigation? {
        let url: URL
        switch mastodonAPIClient.apiCapabilities.flavor {
        case nil:
            return nil
        case .mastodon, .glitch, .hometown:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("auth", "edit")
        case .pleroma, .akkoma:
            // Akkoma's web UI doesn't support deep linking to settings.
            return nil
        case .gotosocial:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("settings", "user", "settings")
        case .calckey, .firefish:
            url = mastodonAPIClient.instanceURL.appendingPathComponents("settings", "security")
        }

        return .authenticatedWebView(
            AuthenticatedWebViewService(environment: environment),
            url
        )
    }
}

private extension NavigationService {
    func tag(url: URL) -> String? {
        if status?.tags.first(where: { $0.url.url?.path.lowercased() == url.path.lowercased() }) != nil {
            return url.lastPathComponent
        } else if
            mastodonAPIClient.instanceURL.host == url.host {
            return url.tag
        }

        return nil
    }

    func accountId(url: URL) -> String? {
        if let mentionId = status?.mentions.first(where: {
            $0.url.url?.path.lowercased() == url.path.lowercased()
        })?.id {
            return mentionId
        } else if
            mastodonAPIClient.instanceURL.host == url.host {
            return url.accountId
        }

        return nil
    }

    func webfinger(url: URL) -> AnyPublisher<Navigation, Never> {
        let navigationSubject = PassthroughSubject<Navigation, Never>()

        let request = mastodonAPIClient.request(ResultsEndpoint.search(.init(query: url.absoluteString)))
            .handleEvents(
                receiveSubscription: { _ in navigationSubject.send(.webfingerStart) },
                receiveCompletion: { _ in navigationSubject.send(.webfingerEnd) })
            .map { results -> Navigation in
                if let tag = results.hashtags.first {
                    return .collection(
                        TimelineService(
                            timeline: .tag(tag.name),
                            environment: environment,
                            mastodonAPIClient: mastodonAPIClient,
                            contentDatabase: contentDatabase))
                } else if let account = results.accounts.first {
                    return .profile(profileService(account: account))
                } else if let status = results.statuses.first {
                    return .collection(contextService(id: status.id))
                } else {
                    return .url(url)
                }
            }
            .replaceError(with: .url(url))

        return navigationSubject.merge(with: request).eraseToAnyPublisher()
    }
}

private extension URL {
    var isAccountURL: Bool {
        (pathComponents.count == 2 && pathComponents[1].starts(with: "@"))
            || (pathComponents.count == 3 && pathComponents[0...1] == ["/", "users"])
    }

    var accountId: Account.Id? {
        if let accountId = pathComponents.last, pathComponents == ["/", "web", "accounts", accountId] {
            return accountId
        }

        return nil
    }

    var statusId: Status.Id? {
        guard let statusId = pathComponents.last else { return nil }

        if pathComponents.count == 3, pathComponents[1].starts(with: "@") {
            return statusId
        } else if pathComponents == ["/", "web", "statuses", statusId] {
            return statusId
        }

        return nil
    }

    var tag: String? {
        if let tag = pathComponents.last, pathComponents == ["/", "tags", tag] {
            return tag
        }

        return nil
    }

    var shouldWebfinger: Bool {
        isAccountURL || accountId != nil || statusId != nil || tag != nil
    }
}
