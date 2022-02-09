pipeline {
    agent {
        label 'centos7-docker-4c-2g' 
    }
    options {
        timestamps()
        quietPeriod(5) // wait a few seconds before starting to aggregate builds...??
        durabilityHint 'PERFORMANCE_OPTIMIZED'
        timeout(360)
    }
    parameters {
        booleanParam defaultValue: false, description: 'Archive 3rd Party Images', name: 'ARCHIVE'
    }
    triggers {
        issueCommentTrigger('.*^recheck$.*')
    }
    stages {
        stage('Smoke Tests') {
            when {
                expression { !edgex.isReleaseStream() && !params.ARCHIVE }
            }
            steps {
                build job: '/edgexfoundry/edgex-taf-pipelines/smoke-test', parameters: [string(name: 'SHA1', value: env.GIT_COMMIT), string(name: 'TEST_ARCH', value: 'All'), string(name: 'WITH_SECURITY', value: 'All')]
            }
        }

        stage('Archive 3rd Party Images') {
            when {
                expression { params.ARCHIVE }
            }
            steps {
                edgeXDockerLogin(settingsFile: 'ci-build-images-settings')
                bootstrapBuildX()

                script {
                    def images = sh(script: "grep image docker-compose.yml | grep -v edgexfoundry | awk '{print \$2}'", returnStdout: true).trim()
                    images.split('\n').each { image ->
                        sh "echo -e 'FROM ${image}' | docker buildx build --platform 'linux/amd64,linux/arm64' -t nexus3.edgexfoundry.org:10002/archive/${image} --push -"
                    }
                }
            }
        }
    }
    post {
        always {
            edgeXInfraPublish()
        }
        cleanup {
            cleanWs()
        }
    }
}

def bootstrapBuildX() {
    sh 'docker buildx ls'
    sh 'docker buildx create --name edgex-builder --platform linux/amd64,linux/arm64 --use'
    sh 'docker buildx inspect --bootstrap'
    sh 'docker buildx ls'
}