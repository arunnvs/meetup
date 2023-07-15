podTemplate(yaml: '''
    apiVersion: v1
    kind: Pod
    spec:
      containers:
      - name: php
        image: php:7.4-fpm
        command:
        - apt-get
        args:
        - update
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
          composer install
          '''
        }
      }
    }

    stage('Build php Image') {
      container('kaniko') {
        stage('Build a php project') {
          sh '''
            /kaniko/executor --context `pwd` --destination sarunn/hello-kaniko:1.0
          '''
        }
      }
    }

  }
}
