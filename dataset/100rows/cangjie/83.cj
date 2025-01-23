package opds_cj.config

import encoding.url.URL

public class baseConfig {
    public static let database: String = "./data/Komga/database.sqlite"
    public static func getFileURL(rawURL: String): String {
        var url = URL.parse(rawURL)
        return url.path //.replace("/books", "./data/Komga/books")
    }
}