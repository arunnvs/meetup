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
          apt-get update && apt-get install -y wget gnupg
	        wget -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
	        wget -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
	        echo "deb https://deb.nodesource.com/node_12.x focal main" | tee /etc/apt/sources.list.d/nodesource.list
	        echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
	        apt-get update -qq && apt-get install -y -qq yarn
	        apt-get update -qq && apt-get install -y -qq ruby-full
          php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer && php -r "unlink('composer-setup.php');" 
	        composer self-update 2.3.5
	        yarn cache clean
	        yarn install
	        yarn encore production
          '''
        }
        stage('unit tests') {
          sh '''
#          phpunit_options := $(phpunit_options) --coverage-clover build/reports/coverage.xml --log-junit build/reports/tests.xml
          echo "################### ALL TESTS ###################"
#	        /usr/local/bin/php bin/console cache:clear --env=test
#	        /usr/local/bin/php bin/phpunit $(phpunit_options) tests
          '''
        }
      }
    }

    stage('Build php Image') {
      container('kaniko') {
        stage('Build a php project') {
          sh '''
            /kaniko/executor --context `pwd`  --dockerfile=docker/prod/Dockerfile --destination sarunn/meetup-prod-php:1.0
            /kaniko/executor --context `pwd`  --dockerfile=docker/prod/nginx/Dockerfile --destination sarunn/meetup-prod-app-nginx:1.0
          '''
        }
      }
    }

  }
}
