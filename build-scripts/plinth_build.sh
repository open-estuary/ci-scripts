#!/bin/bash -ex
#: Title                  : jenkins_build_v500_start.sh
#: Usage                  : ./local/ci-scripts/build-scripts/jenkins_build_v500_start.sh -p env.properties
#: Author                 : qinsl0106@thundersoft.com
#: Description            : CI中自动编译的jenkins任务脚本，针对v500
# only works on centos

#!/bin/bash
#record the path of parent script,we need to return this dir after build is over
CUR_TOP_DIR=`pwd`
CI_SCRIPTS_DIR=${CUR_TOP_DIR}/local/ci-scripts/

function parse_params() {
    pushd ${CI_SCRIPTS_DIR}
	
	pwd
	
    : ${SHELL_PLATFORM:=`python configs/parameter_parser.py -f config_plinth.yaml -s Build -k Platform`}
#    : ${ALL_SHELL_PLATFORM:=`python configs/parameter_parser.py -f config.yaml -s Build -k Platform`}
#    : ${SHELL_DISTRO:=`python configs/parameter_parser.py -f config.yaml -s Build -k Distro`}
#    : ${ALL_SHELL_DISTRO:=`python configs/parameter_parser.py -f config.yaml -s Build -k Distro`}

#    : ${BOOT_PLAN:=`python configs/parameter_parser.py -f config.yaml -s Jenkins -k Boot`}

#    : ${TEST_PLAN:=`python configs/parameter_parser.py -f config.yaml -s Test -k Plan`}
#    : ${TEST_SCOPE:=`python configs/parameter_parser.py -f config.yaml -s Test -k Scope`}
#    : ${TEST_REPO:=`python configs/parameter_parser.py -f config.yaml -s Test -k Repo`}
#    : ${TEST_LEVEL:=`python configs/parameter_parser.py -f config.yaml -s Test -k Level`}

#    : ${LAVA_SERVER:=`python configs/parameter_parser.py -f config.yaml -s LAVA -k lavaserver`}
#    : ${LAVA_USER:=`python configs/parameter_parser.py -f config.yaml -s LAVA -k lavauser`}
#    : ${LAVA_STREAM:=`python configs/parameter_parser.py -f config.yaml -s LAVA -k lavastream`}
#    : ${LAVA_TOKEN:=`python configs/parameter_parser.py -f config.yaml -s LAVA -k TOKEN`}

#    : ${FTP_SERVER:=`python configs/parameter_parser.py -f config.yaml -s Ftpinfo -k ftpserver`}
    : ${FTP_DIR:=`python configs/parameter_parser.py -f config_plinth.yaml -s Ftpinfo -k FTP_DIR`}
    : ${FTPSERVER_DISPLAY_URL:=`python configs/parameter_parser.py -f config_plinth.yaml -s Ftpinfo -k FTPSERVER_DISPLAY_URL`}

#    : ${ARCH_MAP:=`python configs/parameter_parser.py -f config.yaml -s Arch`}

    : ${SUCCESS_MAIL_LIST:=`python configs/parameter_parser.py -f config_plinth.yaml -s Mail -k SUCCESS_LIST`}
    : ${SUCCESS_MAIL_CC_LIST:=`python configs/parameter_parser.py -f config_plinth.yaml -s Mail -k SUCCESS_CC_LIST`}
    : ${FAILED_MAIL_LIST:=`python configs/parameter_parser.py -f config_plinth.yaml -s Mail -k FAILED_LIST`}
    : ${FAILED_MAIL_CC_LIST:=`python configs/parameter_parser.py -f config_plinth.yaml -s Mail -k FAILED_CC_LIST`}

    : ${BUILD_REPORT_DIR:=`python configs/parameter_parser.py -f config_plinth.yaml -s REPORT -k BUILD_DIR`}
	: ${IMAGE_DIR:=`python configs/parameter_parser.py -f config_plinth.yaml -s Kernel_dev -k Image_dir`}
	
    popd    # restore current work directory
}

function generate_failed_mail(){
    echo "${FAILED_MAIL_LIST}" > ${CUR_TOP_DIR}/MAIL_LIST.txt
    echo "${FAILED_MAIL_CC_LIST}" > ${CUR_TOP_DIR}/MAIL_CC_LIST.txt
    echo "Estuary CI Build - ${GIT_DESCRIBE} - Failed" > ${CUR_TOP_DIR}/MAIL_SUBJECT.txt
    cat > ${CUR_TOP_DIR}/MAIL_CONTENT.txt <<EOF
( This mail is send by Jenkins automatically, don't reply )<br>
Project Name: ${TREE_NAME}<br>
Version: ${GIT_DESCRIBE}<br>
Build Status: failed<br>
Build Log Address: ${BUILD_URL}console<br>
Build Project Address: $BUILD_URL<br>
Build and Generated Binaries Address: NONE<br>
<br>
The build is failed unexpectly. Please check the log and fix it.<br>
Build report Address: ${FTPSERVER_DISPLAY_URL}/${TREE_NAME}/${BUILD_REPORT_DIR}<br>
<br>
EOF
}


function generate_success_mail(){
    echo "${SUCCESS_MAIL_LIST}" > ${CUR_TOP_DIR}/MAIL_LIST.txt
    echo "${SUCCESS_MAIL_CC_LIST}" > ${CUR_TOP_DIR}/MAIL_CC_LIST.txt
    echo "Estuary CI - ${GIT_DESCRIBE} - Result" > ${CUR_TOP_DIR}/MAIL_SUBJECT.txt
    cat > ${CUR_TOP_DIR}/MAIL_CONTENT.txt <<EOF
( This mail is send by Jenkins automatically, don't reply )<br>
Project Name: ${TREE_NAME}<br>
Version: ${GIT_DESCRIBE}<br>
Build Status: success<br>
Build Log Address: ${BUILD_URL}console<br>
Build Project Address: $BUILD_URL<br>
Build report Address: ${FTPSERVER_DISPLAY_URL}/${TREE_NAME}/${BUILD_REPORT_DIR}<br>
EOF
}
#PRE_TOP_DIR=$(cd "`dirname $0`" ; pwd)
parse_params

#The CI Build use VM to run build job,
#so I should used relational path to find the build git 
PRE_TOP_DIR=$0
PRE_TOP_DIR=`echo ${PRE_TOP_DIR%/*}`

#The local path which to locate my kernel code
BUILD_DIR="/home/plinth"

#build result variable
envok=0


#********
#****Start : Clone kernel repo and build it
#********

#get the name of git,the name is used to find the dir
tmp=`echo ${KERNEL_GITADDR} | awk -F'.' '{print $2}' | awk -F'/' '{print $NF}'`
echo "The name of kernel repo is "$tmp

#checkout if build repo is exit or not!
if [ ! -d "${BUILD_DIR}" ];then
	mkdir ${BUILD_DIR}
fi

#checkout if build dir output dir is exit or not!
if [ ! -d "${BUILD_DIR}/output" ];then
	mkdir ${BUILD_DIR}/output
fi

generate_failed_mail

#rm -rf ${BUILD_DIR}/${tmp}

ls -a ${BUILD_DIR}

#ls -a ${BUILD_DIR}/${tmp}

#Enter the current scripts's dir
cd ${PRE_TOP_DIR}
cp fetchbranch.sh ${BUILD_DIR}
#checkout if kernel repo is exit or not!
if [ ! -d "${BUILD_DIR}/${tmp}" ];then
	echo "The kernel dir is not exit!"
        #mkdir ${BUILD_DIR}/${tmp}
       	#cd ${BUILD_DIR}
        #git clone git@github.com:hisilicon/kernel-dev.git
	#sleep 10
	#pushd ${BUILD_DIR}

	cp gitclone.sh ${BUILD_DIR}
#	cp fetchbranch.sh ${BUILD_DIR}
	cd ${BUILD_DIR}
	pwd
	./gitclone.sh ${KERNEL_GITADDR}	
else
	echo "The kernel repo have been found!"
#	exit 0
fi

cp build.sh ${BUILD_DIR}/output

#enter the kernel code dir
cd ${BUILD_DIR}/${tmp}

#cp ${BUILD_DIR}/fetchbranch.sh .

#./fetchbranch.sh
o="url = https://github.com/hisilicon/kernel-dev.git"
#a="url = https://Luojiaxing1991:ljxfyjh1321@github.com/hisilicon/kernel-dev.git"
tmp_url=`cat .git/config | grep 'github.com/'`
if [ x"${tmp_url}" == x"${o}" ];then
	sed -i 's/github.com/Luojiaxing1991:ljxfyjh1321@github.com/g' .git/config
fi

git remote update origin --prune

#checkout specified branch and build keinel
git stash

#git branch | grep ${BRANCH_NAME} 2>&1


#if [ $? -eq 0 ];then
	#The same name of branch is exit
	#git stash
#	git checkout -b tmp_luo origin/${BRANCH_NAME}
#	git branch -D ${BRANCH_NAME}
#fi
git branch

#git checkout -b mybranch origin/release-plinth-4.16.1
git checkout -b ${BRANCH_NAME} remotes/origin/${BRANCH_NAME}


git pull


#git branch -D tmp_luo

#before any change,patch the PMU patch to support D05
#git am --abort
#git am ${BUILD_DIR}/output/${tmp_patch}
#sleep 20
#git branch -D svm-4.15

#before building,change some build cfg

#HNS3 build into kernel option
#sed -i 's/CONFIG_HNS3=m/CONFIG_HNS3=y/g' arch/arm64/configs/plinth-config
#sed -i 's/CONFIG_HNS3_HCLGE=m/CONFIG_HNS3_HCLGE=y/g' arch/arm64/configs/plinth-config
#sed -i 's/CONFIG_HNS3_ENET=m/CONFIG_HNS3_ENET=y/g' arch/arm64/configs/plinth-config

[ ! -f  'arch/arm64/configs/defconfig' ] && echo " " > arch/arm64/configs/defconfig 

sed -i 's/CONFIG_HNS3=m/CONFIG_HNS3=y/g' arch/arm64/configs/defconfig
sed -i 's/CONFIG_HNS3_HCLGE=m/CONFIG_HNS3_HCLGE=y/g' arch/arm64/configs/defconfig
sed -i 's/CONFIG_HNS3_ENET=m/CONFIG_HNS3_ENET=y/g' arch/arm64/configs/defconfig



#HNS VLAN build option
sed -i 's/CONFIG_VLAN_8021Q=m/CONFIG_VLAN_8021Q=y/g' arch/arm64/configs/defconfig



echo "Begin to build the kernel!"
#cp ${BUILD_DIR}/output/build.sh .
#ls -l ${IMAGE_DIR}

DATE=`date +%Y-%m-%d`

bash build.sh ${BOARD_TYPE} > ${BUILD_DIR}/output/build_${BRANCH_NAME}_${DATE}.log
ls -l ${IMAGE_DIR}

cat .config

echo "Finish Build Image"


##########
##Copy the Image to FTP document##
##########
[ ! -d ${FTP_DIR}/${TREE_NAME} ] && mkdir ${FTP_DIR}/${TREE_NAME}

[ ! -d ${FTP_DIR}/${TREE_NAME}/${GIT_DESCRIBE}/${SHELL_PLATFORM}-arm64 ] && mkdir -p ${FTP_DIR}/${TREE_NAME}/${GIT_DESCRIBE}/${SHELL_PLATFORM}-arm64

[ ! -d ${FTP_DIR}/${TREE_NAME}/${BUILD_REPORT_DIR} ] && mkdir ${FTP_DIR}/${TREE_NAME}/${BUILD_REPORT_DIR}

cp ${IMAGE_DIR} ${FTP_DIR}/${TREE_NAME}/${GIT_DESCRIBE}/${SHELL_PLATFORM}-arm64/Image_${SHELL_PLATFORM}

#cp ${IMAGE_DIR} /root/estuary/tftp_nfs_data/plinth/Image

cp ${BUILD_DIR}/output/build_${BRANCH_NAME}_${DATE}.log ${FTP_DIR}/${TREE_NAME}/${BUILD_REPORT_DIR}

echo "Finish the kernel build!"


git stash
git checkout test
git branch -D ${BRANCH_NAME}

generate_success_mail

cd ${CUR_TOP_DIR}

#********
#****END : Clone kernel repo and build it
#********
