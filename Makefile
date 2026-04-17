.PHONY: test test-js test-python test-qml

test: test-js test-python test-qml

test-js:
	npm install && npm test

test-python:
	python3 -m unittest discover tests/python

test-qml:
	qmltestrunner tests/qml/tst_timeUtils.qml
