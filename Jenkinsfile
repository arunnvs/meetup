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
      sh 'echo $PWD'
      sh 'echo $JENKINS_NAME'
      sh 'echo $JENKINS_AGENT_WORKDIR'
      sh 'DOCKER_BUILDKIT=1 docker build -t sarunn/meetup-prod-php:${BUILD_NUMBER} -f ./docker/prod/Dockerfile .'
      sh 'ls -al'
      sh 'docker images'
      sh 'echo $PWD'
      sh 'echo $JENKINS_NAME'
      sh 'echo $JENKINS_AGENT_WORKDIR'
      }
      stage('Run test'){
         sh '''
         docker run -tid --name meetup-app-prod sarunn/meetup-prod-php:${BUILD_NUMBER} -v /mnt/workspace/dood:/code
         docker ps -a
         docker exec meetup-app-prod composer install
         docker exec meetup-app-prod make test
         docker exec meetup-app-prod ls -al
         docker images
         docker stop $(docker ps -a -q)
         docker rm $(docker ps -a -q)
         docker rmi $(docker images -q)
         docker images
         ls -al
        '''
      }
      stage('Build PHP image'){
        sh '''
        docker build -t sarunn/meetup-prod-php:${BUILD_NUMBER} -f ./docker/prod/Dockerfile .
        docker images
        '''
      }
      stage('Build Nginx image'){
        sh '''
        docker build -t sarunn/meetup-prod-nginx:${BUILD_NUMBER} -f ./docker/prod/nginx/Dockerfile .
        docker images
        '''
      }
      stage('Login to Docker Hub &  Push Image') {
           withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerKey', usernameVariable: 'dockerUser')]) {
            // avoid using credentials in groovy string interpolation
            sh label: 'Login to docker registry', script: '''
            docker login --username $dockerUser --password $dockerKey '''
            sh 'docker push sarunn/meetup-prod-php:${BUILD_NUMBER}'
            sh 'docker push sarunn/meetup-prod-nginx:${BUILD_NUMBER}'
            // do something while being logged in
            sh label: 'Logout from docker registry', script: '''
                docker logout
            '''
      }
      }
      stage('clone manifests'){
        git url:'https://github.com/arunnvs/infra', branch: 'main'
        sh 'pwd'
        sh 'ls'

      }
      stage('update mainifests'){
        sh '''
        cd meetup
        pwd
        update_tag.sh ${BUILD_NUMBER}
        '''
      }

      
    
    }
  }
  }
