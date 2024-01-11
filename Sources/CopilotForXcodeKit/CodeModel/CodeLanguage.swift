import Foundation

/// The language of the code.
public enum CodeLanguage: RawRepresentable, Codable, Hashable {
    /// Known language identifier.
    case builtIn(LanguageIdentifier)
    /// Plaintext
    case plaintext
    /// Other language identifier.
    case other(String)

    public var rawValue: String {
        switch self {
        case let .builtIn(language):
            return language.rawValue
        case .plaintext:
            return "plaintext"
        case let .other(language):
            return language
        }
    }

    public var hashValue: Int {
        rawValue.hashValue
    }

    public init?(rawValue: String) {
        if let language = LanguageIdentifier(rawValue: rawValue) {
            self = .builtIn(language)
        } else if rawValue == "txt" || rawValue.isEmpty {
            self = .plaintext
        } else {
            self = .other(rawValue)
        }
    }
}

/// Known language identifiers.
public enum LanguageIdentifier: String, Codable, CaseIterable {
    case abap
    case windowsbat = "bat"
    case bibtex
    case clojure
    case coffeescript
    case c
    case cpp
    case csharp
    case css
    case diff
    case dart
    case dockerfile
    case elixir
    case erlang
    case fsharp
    case gitcommit
    case gitrebase
    case go
    case groovy
    case handlebars
    case html
    case ini
    case java
    case javascript
    case javascriptreact
    case json
    case latex
    case less
    case lua
    case makefile
    case markdown
    case objc = "objective-c"
    case objcpp = "objective-cpp"
    case perl
    case perl6
    case php
    case powershell
    case pug = "jade"
    case python
    case r
    case razor
    case ruby
    case rust
    case scss
    case sass
    case scala
    case shaderlab
    case shellscript
    case sql
    case swift
    case typescript
    case typescriptreact
    case tex
    case vb
    case xml
    case xsl
    case yaml
}

