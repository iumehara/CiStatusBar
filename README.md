# CI Status Bar

CI Status Bar is a MacOS menu bar app that displays the status of your CI builds.

### Tests
Run all tests with:

`make test`

Run target-specific tests with:

`make test-unit` for all basic Swift tests in the `UnitTests` target

`make test-view` for the SwiftUI tests using ViewInspector in the `ViewTests` target

`make test-e2e` for the end-to-end happy path test in the `E2ETests` target