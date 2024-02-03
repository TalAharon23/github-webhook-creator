pipeline {
    agent any

    tools {
        terraform 'Terraform-1.7.2'
    }


    parameters {
        string(name: 'aws_region', defaultValue: 'us-east-1', description: 'The AWS region to create all Github webhook logger services in')
        string(name: 'github_repo_name', defaultValue: '', description: 'GitHub repository name to create the webhook on')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Choose whether to create or destroy webhook and all resources')
    }

    environment {
        TF_PATH = "/var/jenkins_home/tools/org.jenkinsci.plugins.terraform.TerraformInstallation/Terraform-1.7.2/terraform"
    }

    stages {
        stage('Init') {
            steps {
                withAWSCredentials("aws-jenkins") {
                    script {
                        sh 'pwd; ls'
                        sh "${TF_PATH} init -reconfigure"
                    }
                }
            }
        }
        
        stage('Plan') {
            steps {
                withAWSCredentials("aws-jenkins") {
                sh "${TF_PATH} plan -var='aws_region=${params.aws_region}' -var='github_repo_name=${params.github_repo_name}'"
                }
            }
        }

        stage('Apply or Destroy') {
            steps {
                withAWSCredentials("aws-jenkins") {
                    script {
                        sh "${TF_PATH} ${action} -auto-approve -var='aws_region=${params.aws_region}' -var='github_repo_name=${params.github_repo_name}'"
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