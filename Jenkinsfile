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
    triggers {
        issueCommentTrigger('.*^recheck$.*')
    }
    stages {
        stage('Smoke Tests') {
            when {
                expression { !edgex.isReleaseStream() }
            }
            steps {
                build job: '/edgexfoundry/edgex-taf-pipelines/smoke-test', parameters: [string(name: 'SHA1', value: env.GIT_COMMIT), string(name: 'TEST_ARCH', value: 'All'), string(name: 'WITH_SECURITY', value: 'All')]
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