TESTS = test/*.js

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
			--require should \
			--reporter list \
			--slow 20 \
			--growl \
			$(TESTS)
.PHONY: test

# Compile all coffee to js
comp:
	coffee --compile --output views/lib/ views/src/ && coffee -c server.coffee