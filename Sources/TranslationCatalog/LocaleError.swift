public enum LocaleError: Error {
    case languageCode(_ identifier: String)
    case script(_ identifier: String)
    case region(_ identifier: String)
}
