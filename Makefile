.PHONY: test test-coverage analyze check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi

check: analyze test-coverage
