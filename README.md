# NYTKit

`NYTKit` is a Swift Package designed to encapsulate shared business logic, data models, networking, caching, and filtering logic across both SwiftUI and UIKit NYTimes clients. This modular approach enables reusability, testability, and faster iteration cycles across platforms.

---

## Features

- **Modular SPM Architecture**: Shareable across SwiftUI and UIKit targets.
- **Typed API Integration**: Uses modern async/await with typed endpoint management.
- **Smart Caching System**:
  - `ResponseCache`: JSON-based response cache with a stale-while-revalidate strategy.
  - `ImageCache`: In-memory image caching to reduce repeated downloads and improve scrolling performance.
- **Offline-Aware Architecture**:
  - Integrated `NetworkMonitor` to gracefully handle connectivity status and fallback to cached data.
- **Robust Filtering**:
  - Custom `MostPopularFilter` abstraction to support NYT API's dynamic filters (period, endpoint type, etc.).
- **Complete Unit Test Coverage**:
  - Over 95% coverage across networking, filtering, and caching layers.

---

## Modules Overview

### 1. API Layer

- `Endpoint.swift`: Base protocol for defining NYT API endpoints.
- `NYTEndpoint.swift`: Enum-backed endpoints for viewed, emailed, and shared articles.
- `NetworkClient.swift`: Abstracted async network layer with robust error handling.

### 2. Caching Layer

- `CacheEntry.swift`: Generic wrapper that includes a creation timestamp.
- `ResponseCache.swift`: In-memory cache with `Date`-based expiration.
- `ImageCache.swift`: Simple singleton-based image cache (NSCache-backed).

### 3. Repository

- `NYTArticlesRepository.swift`: Implements `ArticlesRepository` and serves fresh or cached article data.
- Uses `AsyncThrowingStream` to stream cached data immediately and update with fresh data asynchronously.

### 4. Models

- `ArticleAPIResponse.swift`: NYT API response wrapper.
- `MostPopularFilter.swift`: Filter abstraction (period, endpoint, section, share type).

### 5. Support Utilities

- `APIEnvironment.swift`: Protocol for switching between development and production environments.
- `AppConstants.swift`: Shared constants across app modules (titles, images, error messages).
- `NetworkMonitor.swift`: NWPathMonitor-backed connectivity tracker.
- `ViewState.swift`: View model state machine for SwiftUI and UIKit interoperability.

---

## Testing

This package is extensively tested with:

- Mock URLSession injections.
- Cached/stale response scenarios.
- Offline behavior simulation.
- Enum-based endpoint encoding.
- Custom filter serialization.

**Coverage:** ~95% of the business logic and side-effect-heavy paths are covered via `swift test`.

---

## Usage

### Add via SPM

```swift
.package(url: "https://github.com/abhi8905/NYTKit", from: "1.0.0")
