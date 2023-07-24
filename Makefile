
PHP_BIN ?= php

phpunit_options := $(phpunit_options) --coverage-clover build/reports/coverage.xml --log-junit build/reports/tests.xml

composer:
	composer install

test:
	echo "################### ALL TESTS ###################"
	$(PHP_BIN) bin/console cache:clear --env=test
	$(PHP_BIN) bin/phpunit $(phpunit_options) tests


install-software-libraries:
	echo "################### Install Software ###################"
	wget -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
	wget -O - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://deb.nodesource.com/node_12.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list
	echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	sudo apt-get update -qq && sudo apt-get install -y -qq yarn
	sudo apt-get update -qq && sudo apt-get install -y -qq ruby-full
	sudo composer self-update 2.3.5
	echo "################### Install Libraries ###################"
	make composer
	yarn cache clean
	yarn install
	yarn encore production
	
