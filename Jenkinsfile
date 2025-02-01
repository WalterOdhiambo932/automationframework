
pipeline {
    agent any
    // agent {
    //     label 'QE'
    // }
    environment {
        Project_Name = 'Test App'
        Automation_Type = 'Mobile'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                script {
                    // Cleanup before starting the stage
                    cleanWs()
                }
            }
        }
        stage('Clone Repository') {
            steps {
                script {
                    final scmVars = checkout(scm)
                    env.BRANCH_NAME = scmVars.GIT_BRANCH
                    env.SHORT_COMMIT = "${scmVars.GIT_COMMIT[0..7]}"
                    env.GIT_REPO_NAME = scmVars.GIT_URL.replaceFirst(/^.*\/([^\/]+?).git$/, '$1')
                }
            }
        }

        stage('Robot Test Setup') {
            steps {
                script {
                    sh "pip install robotframework~=4.1.3"
                    sh "pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org webdrivermanager"
                    sh "pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --upgrade pip"
                    sh "pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org robotframework-seleniumlibrary"
                    sh "pip install pdfkit jinja2  wkhtmltopdf"
                    sh "pip install robotframework-jsonlibrary"
                    sh "pip install robotframework-jsonvalidator"
                    sh "pip install robotframework-requests"
                   
                }
            }
        }
      
        stage ('Run Test') {
            steps {
                
                script {
                    try { 
                    sh "pwd && ls" 
                    sh "cd $WORKSPACE/Tests/${Automation_Type} && python3 -m robot consumer_login.robot" 
                    
                    } catch (Exception e) { 
                        echo "Test execution  failed   with error: ${e}" 
                        
                        currentBuild.result = 'FAILURE' 
                    }
                    
                }
            }

            post { 
                always { 
                    sh 'echo "Test execution completed"' 
                } 
            }         
        }

        stage('Print Report') {
            steps {
                script {
                    sh 'sudo yum install -y wkhtmltopdf mutt xorg-x11-server-Xvfb' // install wkhtmltopdf and mutt
                    sh 'xvfb-run -a wkhtmltopdf $WORKSPACE/Tests/${Automation_Type}/log.html $WORKSPACE/Tests/${Automation_Type}/log.pdf' // convert log.html to log.pdf 
                    sh 'xvfb-run -a wkhtmltopdf $WORKSPACE/Tests/${Automation_Type}/report.html $WORKSPACE/Tests/${Automation_Type}/report.pdf' // convert report.html to report.pdf
                }
            }
        }
        stage('Store Report and Report URL') {
            steps {
                script {
                    sh 'sudo yum install -y  poppler-utils' // install poppler-utils
                    sh 'pdfunite $WORKSPACE/Tests/${Automation_Type}/report.pdf $WORKSPACE/Tests/${Automation_Type}/log.pdf  $WORKSPACE/Tests/${Automation_Type}/proj_results.pdf'
                    archiveArtifacts artifacts: 'Tests/${Automation_Type}/proj_results.pdf'
                    echo "Report URL : ${BUILD_URL}artifact/Tests/${Automation_Type}/proj_results.pdf"
                }
            }
        }
    }
}






