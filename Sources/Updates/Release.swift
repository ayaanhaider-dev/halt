import Foundation

/// The part of GitHub's release answer that Halt uses.
struct Release: Decodable {
    let tag: String
    let page: URL

    enum CodingKeys: String, CodingKey {
        case tag = "tag_name"
        case page = "html_url"
    }

    var version: String { tag.hasPrefix("v") ? String(tag.dropFirst()) : tag }
    var isTrusted: Bool { page.absoluteString.hasPrefix("https://github.com/ayaanhaider-dev/halt/") }
}

func isNewer(_ version: String, than current: String) -> Bool {
    version.compare(current, options: .numeric) == .orderedDescending
}
