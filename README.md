[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/kronenthaler/syntaxis/branch-check/master?logo=github&style=flat-square)](https://github.com/kronenthaler/syntaxis/actions?query=workflow%3Abranch-check)
[![Codacy branch coverage](https://img.shields.io/codacy/coverage/bf3a88799e974cf6b93b09794f80868d?logo=codacy&style=flat-square)](https://www.codacy.com/app/kronenthaler/syntaxis?utm_source=github.com&utm_medium=referral&utm_content=kronenthaler/pbxproj&utm_campaign=badger)
[![Codacy grade](https://img.shields.io/codacy/grade/bf3a88799e974cf6b93b09794f80868d?logo=codacy&style=flat-square)](https://www.codacy.com/app/kronenthaler/syntaxis?utm_source=github.com&utm_medium=referral&utm_content=kronenthaler/syntaxis&utm_campaign=badger)
![Cocoapods](https://img.shields.io/cocoapods/v/Syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/Syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)
[![Cocoapods](https://img.shields.io/cocoapods/l/Syntaxis?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjgiIHByZXNlcnZlQXNwZWN0UmF0aW89InhNaWRZTWlkIiB2aWV3Qm94PSIwIDAgMTc3IDEyMiI+PGRlZnMvPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0tMS0xaDE3N3YxMjJILTF6Ii8+PGc+PGcgZmlsbD0iI0ZGRiI+PHBhdGggZD0iTTExNSA3NGMtNCAyMS0yMiAzOC01MCAzOC0zMyAwLTU0LTI0LTU0LTUyQzExIDMzIDMxIDggNjUgOGMyOSAwIDQ3IDE4IDQ5IDQxSDkwYy0yLTEyLTExLTIxLTI1LTIxLTE5IDAtMzAgMTUtMzAgMzIgMCAxOCAxMiAzMiAzMCAzMiAxMyAwIDIyLTggMjUtMThoMjV6TTE0MyAxMGwtMTUgNiAxOCA0My0xOCA0MyAxNSA3IDEyLTI5IDktMjEtMjEtNDl6Ii8+PC9nPjwvZz48L3N2Zz4=)](LICENSE)

# Syntaxis

A functional parsing library based on parser combinators

## Installation

*Note: Currently it only supports installation via Cocoapods.* 

Simply add this pod to your `Podfile`

```ruby
pod 'Syntaxis'
```

## Getting started

For a complete documentation about what is available and how to use it check the [documentation folder](Docs/index.md).

## Contributing

This project welcomes any contributions. This project will try a different approach to deal with issues/bugs.

Since this library is intended to be used by developers, it will be very easy for you to report issues in the form of a failing unit test in a MR. 

This have few benefits in the long run:

* Having a failing unit test gives the contributors a reproducible baseline of the issue
* By merging the unit tests in the code base we guarantee that, that bug doesn't reappear inadvertently in the future.

## License

This project is licensed under the MIT license. For more details check [here](LICENSE)