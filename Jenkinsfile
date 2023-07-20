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
          echo 'deb [trusted=yes] https://repo.symfony.com/apt/ /' | tee /etc/apt/sources.list.d/symfony-cli.list
          
          apt-get update -yqq && apt-get install -y openssl git wget vim libsqlite3-dev libxml2-dev libicu-dev libfreetype6-dev libmcrypt-dev libjpeg62-turbo-dev libpng-dev \
    libzip-dev unzip libonig-dev libcurl4-gnutls-dev libbz2-dev libssl-dev -yqq libmemcached-dev symfony-cli nodejs npm && rm -r /var/lib/apt/lists/* && rm -rf /var/cache/apt/*
          php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
          php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
          php -r "unlink('composer-setup.php');" && \
          npm install -g yarn
          docker-php-ext-install opcache \
          && docker-php-ext-install json \
          && docker-php-ext-install bcmath \
          && docker-php-ext-install xml \
          && docker-php-ext-install zip \
          && docker-php-ext-install bz2 \
          && docker-php-ext-install mbstring \
          && docker-php-ext-install curl \
          && docker-php-ext-configure gd \
          && docker-php-ext-install gd \
          && docker-php-ext-configure intl --enable-intl \
          && docker-php-ext-install intl \
          && pecl install pcov \
          && docker-php-ext-enable pcov
          '''
        }
        stage('unit tests') {
          sh '''
          make test
          '''
        }
      }
    }

    stage('Build Image') {
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
