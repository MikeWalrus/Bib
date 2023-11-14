import XCTest

@testable import Bib

final class BibTests: XCTestCase {
    func validateWithBiber(entry: String) throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString
        ).appendingPathExtension("bib")
        try entry.write(to: url, atomically: true, encoding: .utf8)
        defer {
            try! FileManager.default.removeItem(at: url)
        }
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = [
            "biber",
            "--validate-datamodel", "--nolog", "--output-file", "/dev/null",
            "--tool", url.path,
        ]
        let pipe = Pipe()
        task.standardOutput = pipe
        try task.run()
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)!
        if output.contains("ERROR") || output.contains("WARN") {
            XCTFail("Biber validation failed: \(output)\n\nEntry:\n\(entry)")
        }
    }

    func testBibtexArticle() throws {
        let entry = Entry(
            type: .article, title: "Some Title", year: 2023,
            containerTitle: "Some Book", author: ["John Appleseed"],
            url: "www.example.org", doi: nil, page: "1", volume: "1")
        let result = """
            @article{John2023some,
                title = {Some Title},
                author = {John Appleseed},
                year = {2023},
                journaltitle = {Some Book},
                url = {www.example.org},
                pages = {1},
                volume = {1},
            }

            """
        try testBibtex(entry: entry, result: result)
    }

    func testBibTexInproceedings() throws {
        let entry = Entry(
            type: .inproceedings, title: "Some Title", year: 2023,
            containerTitle: "Some Book", author: ["John Appleseed"],
            url: "www.example.org", doi: nil, page: "1", volume: "1")
        let result = """
            @inproceedings{John2023some,
                title = {Some Title},
                author = {John Appleseed},
                year = {2023},
                booktitle = {Some Book},
                url = {www.example.org},
                pages = {1},
                volume = {1},
            }

            """
        try testBibtex(entry: entry, result: result)
    }

    func testBibtex(entry: Entry, result: String) throws {
        let string = entry.toBibtex()
        try validateWithBiber(entry: string)
        XCTAssertEqual(string, result)
    }

    func testJson() throws {
        let entry = Entry(
            type: .article, title: "Some Title", year: 2023,
            containerTitle: "Some Book", author: ["John Appleseed"],
            url: "www.example.org", doi: nil, page: "1", volume: "1")
        let string = export(entries: [entry], to: .json)
        let data = Data(string.utf8)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([Entry].self, from: data)
        XCTAssertEqual(decoded, [entry])
    }
}
