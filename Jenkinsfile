pipeline {
    agent any

    tools {
        terraform 'Terraform-1.7.2'
    }


    parameters {
        string(name: 'aws_region', defaultValue: 'us-east-1', description: 'The AWS region to create all Github webhook logger services in')
        string(name: 'github_repo_name', defaultValue: '', description: 'GitHub repository name to create the webhook on')
        choice(name: 'action', choices: ['Create', 'Destroy'], description: 'Choose whether to create or destroy webhook and all resources')
    }

    environment {
        PATH = "/var/jenkins_home/tools/org.jenkinsci.plugins.terraform.TerraformInstallation/Terraform-1.7.2/terraform"
    }

    stages {
        // stage('Checkout') {
        //     steps {
        //         script {
        //             dir("gh-pr-webhook")
        //             {
        //                 sh "git clone https://${env.GITHUB_TOKEN}@github.com/TalAharon23/gh-pr-logger.git"
        //             }
        //         }
        //     }
        // }

        stage('Init') {
            steps {
                withAWSCredentials("aws-jenkins") {
                    script {
                        sh 'pwd; ls'
                        sh ' init -reconfigure'
                        // sh 'pwd;cd gh-pr-webhook/ ; terraform init -reconfigure  '
                    }
                }
            }
        }
        
        stage('Plan') {
            steps {
                withAWSCredentials("aws-jenkins") {
                sh "terraform plan"
                }
            }
        }

        stage('Apply or Destroy') {
            steps {
                withAWSCredentials("aws-jenkins") {
                    script {
                        def action = params.create ? 'apply' : 'destroy'
                        sh "terraform ${action} -auto-approve -var='aws_region=${params.aws_region}' -var='github_repo_name=${params.github_repo_name}'"
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