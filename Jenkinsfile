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
      environment {     
        DOCKERHUB_CREDENTIALS= credentials('dockerhub')     
      } 
      stage('Build') {
      git url: 'https://github.com/arunnvs/meetup', branch: 'main'
      sh 'DOCKER_BUILDKIT=1 docker build -t meetup-prod-php:${BUILD_NUMBER} -f ./docker/prod/Dockerfile .'
      sh 'ls -al'
      sh 'docker images'
      }
      stage('test'){
         sh '''
         docker ps -a
         docker run -tid --name meetup-app-prod meetup-prod-php
#         docker exec -i meetup-app-prod composer install
#         docker exec -i meetup-app-prod make test
#         docker exec -i meetup-app-prod ls -al
         docker images         
         '''
      }
      stage('Build'){
        sh '''
        docker build -t meetup-prod-php:${BUILD_NUMBER} -f ./docker/prod/Dockerfile .
        docker images
        '''
      }
      stage('Login to Docker Hub &  Push Image') {
           withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerKey', usernameVariable: 'dockerUser')]) {
            // avoid using credentials in groovy string interpolation
            sh label: 'Login to docker registry', script: '''
            docker login --username $dockerUser --password $dockerKey '''

            sh 'docker push sarunn/meetup-prod-php:${BUILD_NUMBER}'
 
            // do something while being logged in
            sh label: 'Logout from docker registry', script: '''
                docker logout
            '''
      }
      }
      
    
    }
  }
  }
