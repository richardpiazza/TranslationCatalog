install:
	swift build -c release
	install .build/release/localizer /usr/local/bin/localizer
