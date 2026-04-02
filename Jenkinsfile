pipeline {
    agent any
    
    // Defines variables used throughout the pipeline
    environment {
        AWS_REGION     = 'eu-west-2'
        CLUSTER_NAME   = 'slack-notified-eks-cluster'
        ECR_REPO       = 'sample-app-repo'
        IMAGE_TAG      = "${env.BUILD_ID}"
        
        // Standalone AWS CLI path
        PATH = "C:\\Users\\USER\\Desktop\\aws-cicd-project\\aws-cli-standalone\\Amazon\\AWSCLIV2;${env.PATH}"
        
        // Ensure you have these credentials configured in Jenkins Credentials Manager
        AWS_CREDENTIALS_ID = 'aws-credentials' // AWS Credential type
        SLACK_WEBHOOK_CREDENTIAL_ID = 'slack-webhook-url' // Secret Text type
    }

    stages {
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    // Binds the AWS Credentials so Terraform can use them
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: "${AWS_CREDENTIALS_ID}"
                    ]]) {
                        bat 'terraform init -upgrade'
                        bat 'terraform apply -auto-approve'
                        
                        script {
                            // Extract outputs dynamically so they can be securely passed to subsequent stages
                            env.ECR_REGISTRY = bat(script: '@terraform output -raw ecr_repository_url', returnStdout: true).trim()
                        }
                    }
                }
            }
            post {
                success {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"✅ *Terraform Provisioning* successful (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
                failure {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"❌ *Terraform Provisioning* failed (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
            }
        }
        
        stage('Build Container Image') {
            steps {
                bat "docker build -t ${env.ECR_REGISTRY}:${IMAGE_TAG} ."
            }
            post {
                success {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"✅ *Build Image* successful (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
                failure {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"❌ *Build Image* failed (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
            }
        }
        
        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    // Extract domain from registry URL to login
                    bat """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_REGISTRY}
                        docker push ${env.ECR_REGISTRY}:${IMAGE_TAG}
                    """
                }
            }
            post {
                success {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"✅ *Push to ECR* successful (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
                failure {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"❌ *Push to ECR* failed (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "${AWS_CREDENTIALS_ID}"
                ]]) {
                    bat "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}"
                    
                    // PowerShell equivalent of sed -i
                    powershell "(Get-Content k8s/deployment.yaml) -replace 'REPOSITORY_URI:IMAGE_TAG', '${env.ECR_REGISTRY}:${IMAGE_TAG}' | Set-Content k8s/deployment.yaml"
                    
                    bat "kubectl apply -f k8s/"
                }
            }
            post {
                success {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"🚀 *Deploy to EKS* successful! New app version is live. (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
                failure {
                    withCredentials([string(credentialsId: "${SLACK_WEBHOOK_CREDENTIAL_ID}", variable: 'SLACK_WEBHOOK')]) {
                        bat "curl -X POST -H \"Content-type: application/json\" --data \"{\\\"text\\\":\\\"🚨 *Deploy to EKS* failed (Build #${env.BUILD_ID})\\\"}\" %SLACK_WEBHOOK%"
                    }
                }
            }
        }
    }
}
