pipelineJob('StaticSite-build') {
    displayName('StaticSite Build')
    description('Creates docker image with release on StaticSite repository')
    logRotator {
        daysToKeep(30)
        numToKeep(10)
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/AdvancedCloud/static-site.git')
                        credentials('github_token')
                    }
                    branch('*/main')
                }
                scriptPath('Jenkinsfile')
            }
        }
    }
    triggers{
        githubPush()
    }
}