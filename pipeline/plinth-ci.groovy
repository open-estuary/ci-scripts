def clone2local(giturl, branchname, localdir) {
    def exists = fileExists localdir
    if (!exists){
        new File(localdir).mkdir()
    }
    dir (localdir) {
        checkout([$class: 'GitSCM', branches: [[name: branchname]],
                extensions: [[$class: 'CloneOption', timeout: 120]], gitTool: 'Default',
                userRemoteConfigs: [[url: giturl]]
            ])
    }
}

def getGitBranchName() {
    return scm.branches[0].name
}

def getGitUrl() {
    return scm.getUserRemoteConfigs()[0].getUrl()
}

node ('ci-compile'){


    stage('Build Preparation') { // for display purposes
        clone2local(getGitUrl(), getGitBranchName(), './local/ci-scripts')

        // prepare variables.
        sh 'env'

        // save the properties
        sh 'echo "" > env.properties'

        // save jenkins enviroment properties.
        sh "echo BUILD_URL=\\\"${BUILD_URL}\\\" >> env.properties"

        // save jenkins parameters.
	if (env.KERNEL_GITADDR) {
            sh "echo KERNEL_GITADDR=\\\"${KERNEL_GITADDR}\\\" >> env.properties"
        }
	if (env.BRANCH_NAME) {
            sh "echo BRANCH_NAME=\\\"${BRANCH_NAME}\\\" >> env.properties"
        }
	if (env.BOARD_TYPE) {
            sh "echo BOARD_TYPE=\\\"${BOARD_TYPE}\\\" >> env.properties"
        }
        if (env.TREE_NAME) {
            sh "echo TREE_NAME=\\\"${TREE_NAME}\\\" >> env.properties"
        }
        if (env.BOOT_PLAN) {
            sh "echo BOOT_PLAN=\\\"${BOOT_PLAN}\\\" >> env.properties"
        }

        if (env.SHELL_PLATFORM) {
            sh "echo SHELL_PLATFORM=\\\"${SHELL_PLATFORM}\\\" >> env.properties"
        }
        if (env.SHELL_DISTRO) {
            sh "echo SHELL_DISTRO=\\\"${SHELL_DISTRO}\\\" >> env.properties"
        }

        if (env.TEST_REPO) {
            sh "echo TEST_REPO=\\\"${TEST_REPO}\\\" >> env.properties"
        }
        if (env.TEST_PLAN) {
            sh "echo TEST_PLAN=\\\"${TEST_PLAN}\\\" >> env.properties"
        }
        if (env.TEST_SCOPE) {
            sh "echo TEST_SCOPE=\\\"${TEST_SCOPE}\\\" >> env.properties"
        }
        if (env.TEST_LEVEL) {
            sh "echo TEST_LEVEL=\\\"${TEST_LEVEL}\\\" >> env.properties"
        }

        if (env.SUCCESS_MAIL_LIST) {
            sh "echo SUCCESS_MAIL_LIST=\\\"${SUCCESS_MAIL_LIST}\\\" >> env.properties"
        }
        if (env.SUCCESS_MAIL_CC_LIST) {
            sh "echo SUCCESS_MAIL_CC_LIST=\\\"${SUCCESS_MAIL_CC_LIST}\\\" >> env.properties"
        }
        if (env.FAILED_MAIL_LIST) {
            sh "echo FAILED_MAIL_LIST=\\\"${FAILED_MAIL_LIST}\\\" >> env.properties"
        }
        if (env.FAILED_MAIL_CC_LIST) {
            sh "echo FAILED_MAIL_CC_LIST=\\\"${FAILED_MAIL_CC_LIST}\\\" >> env.properties"
        }

        if (env.DEBUG) {
            sh "echo DEBUG=\\\"${DEBUG}\\\" >> env.properties"
        }
    }
    // load functions
    def functions = load "./local/ci-scripts/pipeline/functions.groovy"


    def build_result = 0
    stage('Build') {
        build_result = sh script: "./local/ci-scripts/build-scripts/plinth_build.sh", returnStatus: true
    }
    echo "build_result : ${build_result}"
    if (build_result == 0) {
        echo "build success"
    } else {
        echo "build failed"
        functions.send_mail()
        currentBuild.result = 'FAILURE'
        return
    }

    def test_result = 0	
    stage('Test') {
	test_result = sh script: "./local/ci-scripts/test-scripts/plinth_boot_start.sh -p env.properties 2>&1" , returnStatus: true
	}

}

