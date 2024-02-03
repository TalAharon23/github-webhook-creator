pipeline {
    agent any

    parameters {
        string(name: 'aws_region', defaultValue: 'us-east-1', description: 'The AWS region to create all Github webhook logger services in')
        string(name: 'github_repo_name', defaultValue: '', description: 'GitHub repository name to create the webhook on')
        choice(name: 'action', choices: ['Create', 'Destroy'], description: 'Choose whether to create or destroy webhook and all resources')
    }

    environment {
        AWS_ACCESS_KEY_ID       = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_ID    = credentials('AWS_SECRET_ACCESS_ID')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    dir("gh-pr-webhook")
                    {
                        git "https://github.com/TalAharon23/gh-pr-logger.git"
                    }
                }
            }
        }

        stage('Init') {
            steps {
                script {
                    sh 'pwd;cd gh-pr-webhook/ ; terraform init'
                }
            }
        }
        
        stage('Plan') {
            steps {
                sh "pwd;cd gh-pr-webhook/ ; terraform plan -out tfplan"
                sh 'pwd;cd gh-pr-webhook/ ; terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Apply or Destroy') {
            steps {
                withAWSCredentials("aws-jenkins") {
                    script {
                        def action = params.create ? 'apply' : 'destroy'
                        sh "pwd;cd gh-pr-webhook/ ;terraform ${action} -auto-approve -var='aws_region=${params.aws_region}' -var='github_repo_name=${params.github_repo_name}'"
                    }
                }
            }
        }
    }
}

def withAWSCredentials(String credentialsId, Closure body) {
    withCredentials([[
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: credentialsId,
        accessKeyVariable: "AWS_ACCESS_KEY_ID",
        secretKeyVariable: "AWS_SECRET_ACCESS_KEY"
    ]]) {
        body.call()
    }
}