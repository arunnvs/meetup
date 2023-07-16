podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: php
        image: php:7.4-fpm
        command:
        - sleep
        args:
        - 99d
      - name: kaniko
        image: gcr.io/kaniko-project/executor:debug
        command:
        - sleep
        args:
        - 9999999
        volumeMounts:
        - name: kaniko-secret
          mountPath: /kaniko/.docker
      restartPolicy: Never
      volumes:
      - name: kaniko-secret
        secret:
            secretName: dockercred
            items:
              - key: .dockerconfigjson
                path: config.json
''') {
  node(POD_LABEL) {
    stage('Get a php project') {
      git url: 'https://github.com/arunnvs/meetup', branch: 'main'
      container('php') {
        stage('Build a php project') {
          sh '''
	        wget -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
	        wget -O - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	        echo "deb https://deb.nodesource.com/node_12.x focal main" | sudo tee /etc/apt/sources.list.d/nodesource.list
	        echo "deb http://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	        sudo apt-get update -qq && sudo apt-get install -y -qq yarn
	        sudo apt-get update -qq && sudo apt-get install -y -qq ruby-full
	        sudo composer self-update 2.3.5
	        make composer
	        yarn cache clean
	        yarn install
	        yarn encore production
          composer install
          '''
        }
        stage('unit tests') {
          sh '''
          PHP_BIN = $(which php)
          phpunit_options := $(phpunit_options) --coverage-clover build/reports/coverage.xml --log-junit build/reports/tests.xml
          echo "################### ALL TESTS ###################"
	        $(PHP_BIN) bin/console cache:clear --env=test
	        $(PHP_BIN) bin/phpunit $(phpunit_options) tests
          '''
        }
      }
    }

    stage('Build php Image') {
      container('kaniko') {
        stage('Build a php project') {
          sh '''
            /kaniko/executor --context `pwd`  --dockerfile=docker/prod/ --destination sarunn/hello-kaniko:1.0
          '''
        }
      }
    }

  }
}
