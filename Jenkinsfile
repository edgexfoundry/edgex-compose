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
        stage('Prep') {
            steps {
                sh 'env | sort'
                println '============================================='
                sh "echo I AM ARCHIVE from Jenkins Env: [${env.ARCHIVE}]"
                sh "echo I AM ARCHIVE from Params: [${params.ARCHIVE}]"
                sh 'echo I AM ARCHIVE from shell: [$ARCHIVE]'
            }
        }
        stage('Smoke Tests') {
            when {
                expression { !edgex.isReleaseStream() && env.ARCHIVE == 'false' }
            }
            steps {
                sh 'echo running smoke tests'
                //build job: '/edgexfoundry/edgex-taf-pipelines/smoke-test', parameters: [string(name: 'SHA1', value: env.GIT_COMMIT), string(name: 'TEST_ARCH', value: 'All'), string(name: 'WITH_SECURITY', value: 'All')]
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