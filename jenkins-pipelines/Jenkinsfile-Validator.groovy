#!/usr/bin/env groovy

/**
 * Jenkinsfile for Validator
 */

// Load librarys
@Library('notification') n
@Library('validator') v

// Add trigger
def triggers = []
def startedByTimer = false
def startedByUser = false
//triggers << pollSCM('H/5 * * * *')
echo 'DEBUG - Branchname=' + env.BRANCH_NAME
if (env.BRANCH_NAME.startsWith('PR-')) {
  echo 'DEBUG - This is a pull-request, i wont generate a nightly trigger for it.'
} else {
  echo 'DEBUG - This is not a pull-request i generate a nightly trigger now.'
  triggers << cron('H H(7-9) * * *')
}
startedByTimer = isJobStartedByTimer()
startedByUser = isJobStartedByUser()

// Set properties & description
properties (
  [
    parameters (
      [
        choice(name: 'loglevel', choices: 'info\nwarn\ndebug', defaultValue: 'info'),
        choice(name: 'kitchenoutput', choices: 'jenkins\nhumanreadable', defaultValue: 'jenkins'),
        string(name: 'kitchenverifydelay', defaultValue: '300')
      ]
    ),
    buildDiscarder (
      logRotator (
        artifactDaysToKeepStr: '10',
        artifactNumToKeepStr: '10',
        daysToKeepStr: '10',
        numToKeepStr: '10'
      )
    ),
    disableConcurrentBuilds(),
    pipelineTriggers(triggers),
  ]
)
currentBuild.description = "Cookbook $env.BRANCH_NAME Validator"

// Build
timestamps {
  node('cloud-ubuntu-slave') {
    withEnv(["CI=" + params.kitchenoutput]) {
      sshagent(['80425d2a-2908-4419-b6e5-a154e54aefbd']) {
        try {
          stage ('Clean Workspace & Checkout') {
            deleteDir()

            // Checkout data from predefinised scm by scan job
            checkout([
              $class: 'GitSCM',
              branches: scm.branches,
              extensions: scm.extensions + [[$class: 'CleanCheckout']],
              userRemoteConfigs: scm.userRemoteConfigs
            ])

            // Get the commit ID
            git_commit = sh 'git rev-parse --verify HEAD'
            echo "Current commit ID: ${git_commit}"

            bitbucketStatusNotify(buildState: 'INPROGRESS')
          }

          // Remove any lock file
          sh 'rm -f Gemfile.lock'
          sh 'rm -f Berksfile.lock'

          // Some Debug output
          echo 'DEBUG - currentBuild.result=' + currentBuild.result
          echo 'DEBUG - env.BRANCH_NAME=' + env.BRANCH_NAME
          echo 'DEBUG - startedByTimer=' + startedByTimer
          echo 'DEBUG - env.BUILD_CAUSE=' + env.BUILD_CAUSE

          // Bundle install
          stage ('Bundle install') {
            ansiColor('xterm') {
              sh 'bundle install'
            }
          }

          // Rubocop
          stage ('Rubocop stylecheck') {
            try {
              ansiColor('xterm') {
                sh '''
                  bundle exec rubocop \
                  -c .rubocop.yml \
                  -r $(bundle show rubocop-junit-formatter)/lib/rubocop/formatter/junit_formatter.rb \
                  --format RuboCop::Formatter::JUnitFormatter --out rubocop-reports/rubocop_report.xml \
                  --format progress \
                  --format html --out rubocop-reports/rubocop_report.html || true
                '''
              }
            } finally {
              // Archive rubocop data
              archiveArtifacts('rubocop-reports/*')

              // Analyze xml reports and generate jenkins results
              junit 'rubocop-reports/rubocop_report.xml'

              // Publish html report for rubocop
              publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'rubocop-reports',
                reportFiles: 'rubocop_report.html',
                reportName: "Rubocop Report"
              ])
            }
          }

          // Foodcritic
          stage ('Foodcritic stylecheck') {
            try {
              ansiColor('xterm') {
                withEnv(['FOODCRITIC_JUNIT_OUTPUT_DIR=foodcritic-reports']) {
                  sh 'bundle exec foodcritic -f any -C . | bundle exec foodcritic-junit'
                }
              }
            } finally {
              // Archive foodcritic junit xml
              archiveArtifacts('foodcritic-reports/*')

              // Analyze xml reports and generate jenkins results
              junit 'foodcritic-reports/foodcritic-report.xml'
            }
          }

          try {
            // Collect list of kitchen-tests
            platforms = sh(
              script: 'kitchen list -b',
              returnStdout: true
              ).trim()
            platformslist = platforms.split("\n")

            for(int i = 0; i < platformslist.size(); i++) {
              echo "Found kitchen: " + platformslist[i]
            }

            // Cleanup any old kitchen
            sh 'rm -fr .kitchen/'

            // Run kitchen test for each line of result
            for(int i = 0; i < platformslist.size(); i++) {
              echo "DEBUG -- Found kitchen: " + platformslist[i]
              stage('Kitchen converge: ' + platformslist[i]) {
                ansiColor('xterm') {
                  sh 'kitchen converge --color --no-log-overwrite --log-level ' + params.loglevel + ' ' + platformslist[i]
                }
              }
            }
            stage('Kitchen delay') {
              ansiColor('xterm') {
                sh 'sleep ' + params.kitchenverifydelay
              }
            }
            for(int i = 0; i < platformslist.size(); i++) {
              stage('Kitchen verify: ' + platformslist[i]) {
                ansiColor('xterm') {
                  sh 'kitchen verify --color --no-log-overwrite --log-level ' + params.loglevel + ' ' + platformslist[i]
                }
              }
              stage('Kitchen destroy: ' + platformslist[i]) {
                ansiColor('xterm') {
                  sh 'kitchen destroy --color --no-log-overwrite --log-level ' + params.loglevel + ' ' + platformslist[i]
                }
              }
            }
          } finally {
            ansiColor('xterm') {
              sh 'kitchen destroy --color --no-log-overwrite --log-level ' + params.loglevel
            }
            // Archive kitchen logs & reports
            archiveArtifacts('.kitchen/logs/*')
            archiveArtifacts('kitchen-reports/*')

            if (env.CI == 'jenkins') {
              // Analyze xml reports and generate jenkins results
              junit 'kitchen-reports/*.xml'
            }
          }

          // Bump version
          stage ('Bump version') {
            if (env.BRANCH_NAME == 'master' && !startedByTimer && !startedByUser) {
              echo 'Increasing version'
              bumpVersion()
            }
          }

          // Send successfull message
          sendNotifications(buildStatus: currentBuild.result, sendMail: false)
          bitbucketStatusNotify(buildState: 'SUCCESSFUL')
        } catch (err) {
          // Send error message
          currentBuild.result = "FAILURE"
          sendNotifications(buildStatus: currentBuild.result, sendMail: false)
          bitbucketStatusNotify(buildState: 'FAILED')
          throw err
        }
      }
    }
  }
}
