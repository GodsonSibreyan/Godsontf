pipeline {
    agent {
        node {
            label 'master'
        }
    }

    stages {
        stage('Terraform Destroy') {
            steps {
                script {
			      instance="${params.Terraform_Destroy}"
                  if ("$instance" == "Yes"){
                sh 'terraform destroy -auto-approve'
                sh label: '', script: '''rm -rf ${WORKSPACE}/*'''
                }
                else{
                    sh 'echo "Run on with same code!!!"'
                }
                }
            }
        }
        stage('terraform clone') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/DjangoWithDiff.Env']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'fc4bb03e-e514-4d74-ab74-e8c85cc6568d', url: 'https://github.com/GodsonSibreyan/Godsontf.git']]])
            }
        }
        stage('Success Message'){
            steps {
               script {
			      instance="${params.Environment}"
			          if ("$instance" == "SingleServer"){
                            sh "rm -rf MultiServer_with_MySQL MultiServer_with_RDS MultiServer_with_ASGALB"
                            sh "mv ${WORKSPACE}/SingleServer/* ${WORKSPACE}"
                            sh 'echo "Everything is Perfect, Go Ahead for SingleServer!!!"'
                      }
					  else if ("$instance" == "MultiServer_with_MySQL"){
                            sh "rm -rf MultiServer_with_RDS MultiServer_with_ASGALB SingleServer"
                            sh "mv ${WORKSPACE}/MultiServer_with_MySQL/* ${WORKSPACE}"
		                    sh 'echo "Everything is Perfect, Go Ahead for MultiServer_with_MySQL!!!"'
		              }
                      else if ("$instance" == "MultiServer_with_RDS"){
                            sh "rm -rf SingleServer MultiServer_with_MySQL MultiServer_with_ASGALB"
                            sh "mv ${WORKSPACE}/MultiServer_with_RDS/* ${WORKSPACE}"
		                    sh 'echo "Everything is Perfect, Go Ahead for MultiServer_with_RDS!!!"'
		              }
                      else if ("$instance" == "MultiServer_with_ASGALB"){
                            sh "rm -rf SingleServer MultiServer_with_MySQL MultiServer_with_RDS"
                            sh "mv ${WORKSPACE}/MultiServer_with_ASGALB/* ${WORKSPACE}"
		                    sh label: '', script: ''' sed -i \"s/2/$Autoscaling_Max_Value/g\" ${WORKSPACE}/variables.tf
                            sed -i \"s/1/$Autoscaling_Min_Value/g\" ${WORKSPACE}/variables.tf
                            '''
		                    sh 'echo "Everything is Perfect, Go Ahead for MultiServer_with_ASGALB!!!"'
		              }
		              else {
		                  sh 'echo "Something went Wrong!!!"'
		              }
                }
                  }
            }
        stage('Parameters'){
            steps {
                sh label: '', script: ''' sed -i \"s/user/$Access_key/g\" ${WORKSPACE}/variables.tf
                sed -i \"s/password/$Secret_key/g\" ${WORKSPACE}/variables.tf
                sed -i \"s/t2.micro/$Instance_type/g\" ${WORKSPACE}/variables.tf
                sed -i \"s/10/$Instance_size/g\" ${WORKSPACE}/variables.tf
                '''
                }
            }
             
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
         stage('terraform apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        } 
        stage("git checkout") {
	     steps {
		    checkout([$class: 'GitSCM', branches: [[name: '*/branchPy']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'djangocodebase']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'fc4bb03e-e514-4d74-ab74-e8c85cc6568d', url: 'https://github.com/GodsonSibreyan/Godsontf.git']]])
           }
        }
		
        stage('SonarQube analysis') {
	     steps {
	       script {
           scannerHome = tool 'sonarqube';
           withSonarQubeEnv('sonarqube') {
		   sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=zippyops:django -Dsonar.projectName=django -Dsonar.projectVersion=1.0 -Dsonar.projectBaseDir=${WORKSPACE}/djangocodebase -Dsonar.sources=${WORKSPACE}/djangocodebase"
            }
	      }
		}
	    }
        stage("Sonarqube Quality Gate") {
	     steps {
	      script { 
            sleep(30)
            qg = waitForQualityGate() 
		    }
           }
        }
	    stage("Dependency Check") {
		 steps {
	      script {  
			dependencycheck additionalArguments: '', odcInstallation: 'Dependency'
			dependencyCheckPublisher pattern: ''
        }
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/dependency-check-report.xml', onlyIfSuccessful: true
        sleep 900
		    
		}
        } 
        stage('ClamAV') {
	    parallel {
	      stage('Scan') {
	        steps {
	         script {
                build job: 'DjangoMultiChoice_Clamav', wait: false
             } 
	        }
	      }
	    }
        }
        stage('Deployment'){
            steps {
               script {
			      instance="${params.Environment}"
			          if ("$instance" == "SingleServer"){
                            sh label: '', script: '''pubIP=$(<publicip)
                            echo "$pubIP"
                            ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
                            git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
                            sleep 5
                            sudo /bin/su - root
                            sleep 5
                            cd /home/ec2-user/Godsontf
                            mysql --defaults-extra-file=mysql zippyops < zippyops.sql
                            chmod 755 manage.py
                            python manage.py migrate
                            nohup ./manage.py runserver 0.0.0.0:8000 &
                            sleep 10
                            exit
                            sleep 5
                            exit
							EOF'''
                            sh 'echo "Application Deployed, Go Ahead for VAPT,OWASP,LinkChecker,SpeedTest!!!"'
                      }
					  else if ("$instance" == "MultiServer_with_MySQL"){
                            sh label: '', script: '''pubIP=$(<publicip)
                            echo "$pubIP"
						    endpoint=$(<endpoint)
						    echo "$endpoint"
						    ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
						    git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
						    sleep 5
						    sudo /bin/su - root
						    sleep 5
						    cd /home/ec2-user/Godsontf
                            sed -i \"s/localhost/$endpoint/g\" /home/ec2-user/Godsontf/python_webapp_django/settings.py
                            mysql --defaults-extra-file=mysql -h $endpoint --database zippyops < zippyops.sql
						    chmod 755 manage.py
                            python manage.py migrate
                            nohup ./manage.py runserver 0.0.0.0:8000 &
                            sleep 10
                            exit
                            sleep 5
                            exit
						    EOF
                            '''
		                    sh 'echo "Application Deployed, Go Ahead for VAPT,OWASP,LinkChecker,SpeedTest!!!"'
		              }
                      else if ("$instance" == "MultiServer_with_RDS"){
                            sh label: '', script: '''pubIP=$(<publicip)
                            echo "$pubIP"
						    endpoint=$(<endpoint)
						    echo "$endpoint"
						    ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
						    git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
						    sleep 5
						    sudo /bin/su - root
						    sleep 5
						    cd /home/ec2-user/Godsontf
                            sed -i \"s/localhost/$endpoint/g\" /home/ec2-user/Godsontf/python_webapp_django/settings.py
                            mysql --defaults-extra-file=mysql -h $endpoint --database zippyops < zippyops.sql
						    chmod 755 manage.py
                            python manage.py migrate
                            nohup ./manage.py runserver 0.0.0.0:8000 &
                            sleep 10
                            exit
                            sleep 5
                            exit
						    EOF
                            '''
		                    sh 'echo "Application Deployed, Go Ahead for VAPT,OWASP,LinkChecker,SpeedTest!!!"'
		              }
                      else if ("$instance" == "MultiServer_with_ASGALB"){
		                    sh 'echo "Application Deployed, Go Ahead for VAPT,OWASP,LinkChecker,SpeedTest!!!"'
		              }
		              else {
		                    sh 'echo "Something went Wrong!!!"'
		              }
                }
                  }
            }
        stage('VAPT') {
            steps {
                 sh label: '', script: '''pubIP=$(<publicip)
                 echo "$pubIP"
                 ssh -tt root@192.168.5.14 << SSH_EOF
                 echo "open vas server"
                 nohup ./code16.py $pubIP &
                 sleep 5
                 exit
                 SSH_EOF 
                 '''
            }
        }
        stage('OWASP'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   mkdir -p $WORKSPACE/out
                   chmod 777 $WORKSPACE/out
                   rm -f $WORKSPACE/out/*.*
                   sudo docker run --rm --network=host -v /var/lib/jenkins/workspace/DjangoMultiChoice/out:/zap/wrk/:rw -t owasp/zap2docker-live zap-baseline.py -t http://$pubIP:8000 -m 5 -d -r Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html -x Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.xml || true
                   '''
                   archiveArtifacts artifacts: 'out/*.html'
		    }
        } 
        stage('linkChecker'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   date
                   sudo docker run --rm --network=host ktbartholomew/link-checker --concurrency 30 --threshold 0.05 http://$pubIP:8000 > $WORKSPACE/brokenlink_${BUILD_ID}.html || true
                   date
                   '''
                   archiveArtifacts artifacts: '**/brokenlink_${BUILD_ID}.html'
                   }
        }
        stage('SpeedTest') {
	      steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
		           cp -r /var/lib/jenkins/speedtest/budget.json  ${WORKSPACE}
                   sudo docker run --rm --network=host -v ${WORKSPACE}:/sitespeed.io sitespeedio/sitespeed.io http://$pubIP:8000 --outputFolder junitoutput --budget.configPath budget.json --budget.output junit -b chrome -n 1  || true
		  '''
		  archiveArtifacts artifacts: 'junitoutput/**/*'
		  }
	    }
    }
	post {
        always {
        publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive/junitoutput',
              reportFiles: 'index.html',
              reportName: 'Dev_speedtest'
			  ]
        publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive',
              reportFiles: 'brokenlink_${BUILD_ID}.html',
              reportName: 'Dev_linkcheck'
              ]
		publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive/out',
              reportFiles: 'Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html',
              reportName: 'Dev_owasp'
              ]
         sh label: '', script: '''pubIP=$(<publicip)
                   echo "http://$pubIP:8000" '''
        }
    }
}

