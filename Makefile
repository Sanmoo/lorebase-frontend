.PHONY: test test-coverage analyze check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze

check: analyze test-coverage
