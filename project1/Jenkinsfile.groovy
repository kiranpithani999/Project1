pipeline {
agent { label 'node1'}

```
parameters {
    choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform Action')
    string(name: 'CONFIRM_DESTROY', defaultValue: '', description: 'Type YES to allow destroy')
}

stages {

    stage('Checkout') {
        steps {
            git branch: 'master',
                url: 'https://github.com/kiranpithani999/Project1/tree/master/project1/Terraform'
        }
    }

    stage('Terraform Init') {
        steps {
            sh 'terraform init'
        }
    }

    stage('Terraform Validate') {
        steps {
            sh 'terraform validate'
        }
    }

    stage('Terraform Plan') {
        when { expression { params.ACTION == 'plan' } }
        steps {
            sh 'terraform plan'
        }
    }

    stage('Terraform Apply') {
        when { expression { params.ACTION == 'apply' } }
        steps {
            sh 'terraform apply -auto-approve'
        }
    }

    stage('Terraform Destroy') {
        when {
            allOf {
                expression { params.ACTION == 'destroy' }
                expression { params.CONFIRM_DESTROY == 'NO' }
            }
        }
        steps {
            sh 'terraform destroy -auto-approve'
        }
    }

    stage('Destroy Blocked') {
        when {
            allOf {
                expression { params.ACTION == 'destroy' }
                expression { params.CONFIRM_DESTROY != 'YES' }
            }
        }
        steps {
            echo "Destroy blocked — type YES in CONFIRM_DESTROY"
        }
    }
}

post {
    success {
        echo "Infrastructure created successfully"
    }
    failure {
        echo "Terraform infra creation failed"
    }
}
```

}
