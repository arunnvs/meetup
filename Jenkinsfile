podTemplate(yaml: '''
              apiVersion: v1
              kind: Pod
              spec:
                volumes:
                - name: docker-socket
                  emptyDir: {}
                containers:
                - name: docker
                  image: docker:19.03.1
                  readinessProbe:
                    exec:
                      command: [sh, -c, "ls -S /var/run/docker.sock"]
                  command:
                  - sleep
                  args:
                  - 99d
                  volumeMounts:
                  - name: docker-socket
                    mountPath: /var/run
                - name: docker-daemon
                  image: docker:19.03.1-dind
                  securityContext:
                    privileged: true
                  volumeMounts:
                  - name: docker-socket
                    mountPath: /var/run
''') {
  node(POD_LABEL) {
      container('docker') {
      stage('Build') {
      git url: 'https://github.com/arunnvs/meetup', branch: 'main'
      sh 'DOCKER_BUILDKIT=1 docker build -t meetup-prod-php -f ./docker/prod/Dockerfile .'
      sh 'ls -al'
      sh 'docker images'
      }
      stage('test'){
         sh '''
         docker ps -a
         docker run -tid --name meetup-app-prod meetup-prod-php
         docker exec -it meetup-app-prod make test
         '''
      }
      }

      }
}

