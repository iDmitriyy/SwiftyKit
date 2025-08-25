
<p align="left">
<img src="https://img.shields.io/badge/platforms-iOS%2C%20macOS%2C%20watchOS%2C%20tvOS%2C%20visionOS-lightgrey.svg">
<img src="https://img.shields.io/badge/Licence-MIT-green">
</p>

library is yet in early stage of development
> *For stage of the active development minimal requirements are iOS17 / MacOS 14. Deployment target will be decreased later with backward compatibility shims.*

## Motivation:
This package is the result of development different projects. Features are added to swift are awesome. However, sometimes we can’t wait for next Swift version, update to new Xcode version or bump deployment target IRL.
When features are added to STL, they will be deprecated.

Some examples:
- MonotonicUptime. In iOS 15 and later there is Clock.Instant, but before that time MonotonicUptime persented in this library can be used.
- NonEmpty collections and Ordered collections. At some moment in future non-empty collections can be expressed natively by improved swift generics. But for now we can use advantages of NonEmpty to create better API. The same is about SwiftCollections library.

Any feedback is appreciated, MRs are welocome.

## Design principles:
All API is provided with usage examples.
Package is separated into small modules. You can pick up pieces you want and make your own umbrella. You can additionally add your own modules and add needed API.
