test-unit:
	xcodebuild -project cistatusbar.xcodeproj -scheme UnitTests test

test-view:
	xcodebuild -project cistatusbar.xcodeproj -scheme ViewTests test

test-e2e:
	xcodebuild -project cistatusbar.xcodeproj -scheme E2ETests test

test: test-unit test-view test-e2e
