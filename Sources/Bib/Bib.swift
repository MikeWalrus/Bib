import Foundation

public enum Type: String, Codable {
    case article
    case inproceedings

    var container: String {
        switch self {
        case .article:
            return "journaltitle"
        case .inproceedings:
            return "booktitle"
        }
    }
}

public struct Entry: Codable, Equatable {
    let type: Type
    let title: String
    let year: Int
    let containerTitle: String
    let author: [String]
    let url: String?
    let doi: String?
    let page: String?
    let volume: String?

    func toBibtex() -> String {
        var ret: String = ""
        let keyAuthor =
            (author.first?.split(separator: " ").first ?? "unknown")
        let keyTitle = (title.split(separator: " ").first ?? "unknown")
            .lowercased()
        let year = String(year)
        let key = keyAuthor + year + keyTitle
        ret += "@\(type.rawValue){\(key),\n"
        ret += "    title = {\(self.title)},\n"

        let authorList = author.joined(separator: " and ")
        ret += "    author = {\(authorList)},\n"
        ret += "    year = {\(year)},\n"

        ret += "    \(type.container) = {\(containerTitle)},\n"

        if let url = url {
            ret += "    url = {\(url)},\n"
        }
        if let doi = doi {
            ret += "    doi = {\(doi)},\n"
        }
        if let page = page {
            ret += "    pages = {\(page)},\n"
        }
        if let volume = volume {
            ret += "    volume = {\(volume)},\n"
        }
        ret += "}\n"
        return ret
    }

    func toCsvRow() -> String {
        return
            "\"\(type)\",\"\(title)\",\"\(year)\",\"\(containerTitle)\",\"\(author)\",\"\(url ?? "")\",\"\(doi ?? "")\",\"\(page ?? "")\",\"\(volume ?? "")\""
    }

    static func csvHeader() -> String {
        return "Type,Title,Year,ContainerTitle,Author,URL,DOI,Page,Volume"
    }

    func toGbT7714() -> String {
        let author = gbt7714Author()
        let type = gbt7714Type()
        var ret =
            "\(author) \(title) \(type). \(containerTitle), \(year): \(page ?? "")."
        if let url = url {
            ret += " \(url) ."
        }
        if let doi = doi {
            ret += " \(doi) ."
        }
        return ret
    }

    func gbt7714Author() -> String {
        let authors = self.author.prefix(3)
        var ret = authors.map {
            let names = $0.split(separator: " ")
            if names.count <= 1 {
                return $0
            }
            let firstName = names.first!
            let lastName = names.last!
            return lastName + " " + String(firstName.prefix(1))
        }.joined(separator: ", ")
        if author.count > 3 {
            return ret + ", 等"
        }
        ret += "."
        return ret
    }

    func gbt7714Type() -> String {
        let ol = (self.url != nil) ? "/OL" : ""
        switch type {
        case .article:
            return "［J\(ol)］"
        case .inproceedings:
            return "［C\(ol)］"
        }
    }
}

public enum OutputFormat: String, CaseIterable {
    case bibtex = "BibTeX"
    case json = "JSON"
    case csv = "CSV"
    case gbt7714 = "GB/T 7714"
}

public func export(entries: [Entry], to: OutputFormat) -> String {
    switch to {
    case .bibtex:
        return entries.map { $0.toBibtex() }.joined(separator: "\n")
    case .csv:
        return Entry.csvHeader() + "\n"
            + entries.map { $0.toCsvRow() }.joined(separator: "\n")
    case .json:
        return try! String(
            data: JSONEncoder().encode(entries), encoding: .utf8)!
    case .gbt7714:
        return entries.enumerated().map { "［\($0 + 1)］" + $1.toGbT7714() }
            .joined(separator: "\n")
    }
}
