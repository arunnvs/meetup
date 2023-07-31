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

      - name: docker
        image: docker:latest
        command:
        - cat 
        tty: true
        volumeMounts:
        - mountPath: /var/run/docker.sock
          name: docker-sock
        volumes:
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock

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
      container('docker') {
        stage('Build a php project') {
          sh '''
          docker build -t meetup-prod-php -f ./docker/prod/Dockerfile 
          '''
        }
}
}
}
}
