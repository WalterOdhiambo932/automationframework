
![Logo](https://miro.medium.com/v2/resize:fit:553/1*wnMQPTmEsIq0TiRgfX4hig.png)


# Automation Template using Robot Framework

This is a guide for Test Automation on Robot framework




## Installation

Python: Robot Framework is a Python-based automation framework, so you will need to install Python on your computer. You can download the latest version of Python from the official Python website (https://www.python.org/downloads/).

## WEB Automation Installation prerequisites
Selenium Library: Selenium is a popular web testing framework that is often used in conjunction with Robot Framework for testing web applications. Run the command:- 
```bash
    Web driver: chromedriver for (Chrome Browser users). 
    Download link can be found below
```
https://chromedriver.chromium.org/downloads

Installation of Chrome Driver:

    1. Check the chrome version you are using
    2. Download chrome driver based on your chrome version
    3. For MAC book Users, Copy your chrome driver in the directory
        "/usr/local/bin" so that its automatically added to your path
    4.For Windows Users, '<Python Installation Directory>/Scripts/'

#### WEB Automation Installation 

```bash
    pip install robotframework
    pip install robotframework-seleniumlibrary
  
```

## API Automation Installation 

Postman: Postman is a popular API testing tool that is often used in conjunction with Robot Framework for testing APIs. You can download Postman from the official Postman website (https://www.postman.com/downloads/).

#### API Automation Installation 

```bash
    pip install robotframework  
    pip install robotframework-jsonlibrary
    pip install robotframework-requests
    pip install robotframework-collections
    pip install robotframework-seleniumlibrary
    pip install urllib3
    pip install robotframework-stringformat

```

IDE or Text Editor: You will need an IDE or text editor to write and edit your Robot Framework test scripts. Some popular options include PyCharm, Visual Studio Code, Atom, and Sublime Text.

Git: Git is a version control system that is often used in conjunction with Robot Framework for managing code. You can download Git from the official Git website (https://git-scm.com/downloads).

Virtual Environment (Venv, Pipenv, Virtualenv)

## Mobile Installation prerequisites

Android SDK. Android SDK (Software Development Kit) is a collection of software tools and resources provided by Google that developers use to create Android apps. It includes a set of development tools, such as the Android Debug Bridge (ADB) and Android Emulator, as well as libraries, sample code, and documentation. Download from here:-
```bash
    java 8 preferable from below download link:
```
https://www.oracle.com/ke/java/technologies/javase/javase8-archive-downloads.html

```bash
    Android Studio: 'Download from below download link':
```
https://developer.android.com/studio

```bash
    Android SDK: 'Refer from below link on how to setup':
```
https://developer.android.com/about/versions/14/setup-sdk

Automation Setup Requirements after setting up your prerequisites

```bash
    pip install robotframework
    pip install robotframework-appiumlibrary
  
```
Appium desktop. Appium Desktop is a graphical user interface (GUI) application that provides a set of tools and features for Appium, an open-source test automation framework for mobile applications. https://github.com/appium/appium-desktop/releases

Appium inspector. Appium Inspector is a tool provided by Appium that allows you to inspect the user interface (UI) elements of a mobile application. It is essentially a graphical user interface (GUI) that enables you to explore the hierarchy of UI elements, obtain their properties, and interact with them.  https://github.com/appium/appium-inspector/releases
## Pipeline Deployment

To deploy this project run

```bash
  pipeline {
    agent any
    // agent {
    //     label 'QE'
    // }
    environment {
        Project_Name = 'MPESA_Consumer_App'
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

```


## References

https://safaricom.atlassian.net/wiki/spaces/QS/pages/3165618178/Oauth+2.0+Authorization+Automation+Guide

https://medium.com/geekculture/setting-up-python-environment-in-macos-using-pyenv-and-pipenv-116293da8e72

https://www.pythontutorial.net/python-basics/install-pipenv-windows/

https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/


## Contributors

 - Pauline Momanyi
 - Polycarp Kavoo
 - Justus Gitari
 - Barnaby Kamau

