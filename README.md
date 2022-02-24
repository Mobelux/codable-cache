# CodableCache

CodableCache is lightweight caching libary to persist instances of types conforming to `Encodable`. By default it caches data to disk in the form of JSON blobs and supports time-to-live to help prevent stale caches.  

## 📱 Requirements

Swift 5.5x toolchain with Swift Package Manager, iOS 13

## 🖥 Installation

### 📦 Swift Package Manager (recommended)

Add `CodableCache` to your `Packages.swift` file:

```swift
.package(url: "https://github.com/Mobelux/codable-cache.git", from: "2.0.0"),
```

## ⚙️ Usage

### Intialize `CodableCache` with a `Cache`:

```swift
let diskCache = try DiskCache(storageType: .temporary(nil))
let codableCache = CodableCache(diskCache)
```

Since CodableCache is initialized with [Cache](https://github.com/Mobelux/DiskCache/blob/main/Sources/DiskCache/Cache.swift), any conforming type could be used as the backing cache storage.

### Cache data:

```swift
try await codableCache.cache(object: searchResults, key: "recent-searches")
```

A time-to-live can be specified with units of seconds, minutes, hours, days, or forever. If a `ttl` is not specified, it defaults to 1 day.

```swift
try await codableCache.cache(object: searchResults, key: "recent-searches", ttl: .hour(12))
```

### Get cached data:

```swift
let searchResults: [SearchResult]? = await codableCache.object(key: "recent-searches")
```

If no data has been cached for `key`, nil is returned. If the `ttl` has expired, nil will also be returned.

### Delete cached data:

```swift
try await codableCache.delete(objectWith: "recent-searches")
```

Note: if data has not been cached with the given key, an error will be thrown. The code of this error will be `NSFileReadNoSuchFileError`

### Delete all data:

```swift
try await codableCache.deleteAll()
```

### Property Wrapper

Included is the property wrapper `CodableCaching`. It can be used to easily cache a single value.

```swift
@CodableCaching(
    key: "recent-searches",
    ttl: .default)
var searchResults: [SearchResult]?

func addToCache(_ searches: [SearchResult]?) async {
    await $searchResults.set(searches)
}

func fetchFromCache() async {
    self.results = await $searchResults.get()
}

func deleteCache() async {
    await $searchResults.set(nil)
}
```

## License

CodableCache is released under MIT licensing.

