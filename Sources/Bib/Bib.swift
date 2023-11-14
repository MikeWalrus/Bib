enum Type: String {
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

struct Entry {
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
}

enum OutputFormat: CaseIterable {
    case bibtex
    case json
    case csv
    case gbt7714
}

func export(entry: [Entry], to: OutputFormat) -> String {
    switch to {
    case .bibtex:
        return entry.map { $0.toBibtex() }.joined(separator: "\n")
    default:
        return ""
    }
}
