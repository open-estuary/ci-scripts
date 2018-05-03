#!/bin/bash -ex
#: Title                  : jenkins_build_v500_start.sh
#: Usage                  : ./local/ci-scripts/build-scripts/jenkins_build_v500_start.sh -p env.properties
#: Author                 : qinsl0106@thundersoft.com
#: Description            : CI中自动编译的jenkins任务脚本，针对v500
# only works on centos

#!/bin/bash

PRE_TOP_DIR=$(cd "`dirname $0`" ; pwd)

#KERNEL_GITADDR="https://github.com/hisilicon/kernel-dev.git"

EXP_KERGIT=${KERNEL_GITADDR}

BUILD_DIR="/home/plinth"

envok=0

#****Check cmd support before running prepare actions for plinth test*****#

#********
#****Start : Clone kernel repo and build it
#********

#cd into the repo
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

if [ -d "${BUILD_DIR}/${tmp}" ];then
	if [ ! -f "${BUILD_DIR}/${tmp}/build.sh" ];then
		rm -r ${BUILD_DIR}/${tmp}
	fi
fi

#copy ira
if [ ! -f "~/.ssh/id_rsa.pub" ];then
	cp ${PRE_TOP_DIR}/id_rsa.pub ~/.ssh/
else
	mv ~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub.bk
	cp ${PRE_TOP_DIR}/id_rsa.pub ~/.ssh/
fi

#checkout if kernel repo is exit or not!
if [ ! -d "${BUILD_DIR}/${tmp}" ];then
	echo "The kernel dir is not exit! Begin to clone repo!"
        #mkdir ${BUILD_DIR}/${tmp}
       	#cd ${BUILD_DIR}
        git clone git@github.com/Luojiaxing1991/kernel-dev.git
	sleep 10
	expect -c '
		send "yes/r"
		exit
	'
#	
#	spawn git clone https://github.com/Luojiaxing1991/kernel-dev.git
#	expect "Username for"
#	send "Luojiaxing1991\r"
#	expect "Password for"
#	send "ljxfyjh1321\r"
#	expect eof
#	exit 0
#	'
	
else
	echo "The kernel repo have been found!"
fi

cd ${BUILD_DIR}/${tmp}

#generate the patch of pmu v2 to make perf support in D05
git stash
git checkout -b svm-4.15 remotes/origin/release-plinth-4.15.0
tmp_patch=`git format-patch -1 b4e84aac21e48fcccc964216be5c7f8530db7b32`

cp ${tmp_patch}  ${BUILD_DIR}/output

#before checkout branch,update the remote branch list
expect -c '
spawn git remote update origin --prune
expect "Username for 'https://github.com':"
send "Luojiaxing1991\r"
expect "Password for 'https://Luojiaxing1991@github.com':"
send "ljxfyjh1321\r"
expect eof
exit 0
'

#git remote update origin --prune

#checkout specified branch and build keinel
git branch | grep ${BRANCH_NAME}
git stash

if [ $? -eq 0 ];then
	#The same name of branch is exit
	#git stash
	git checkout -b tmp_luo origin/${BRANCH_NAME}
	git branch -D ${BRANCH_NAME}
fi

git checkout -b ${BRANCH_NAME} origin/${BRANCH_NAME}
git branch -D tmp_luo

#before any change,patch the PMU patch to support D05
git am --abort
git am ${BUILD_DIR}/output/${tmp_patch}
sleep 20
git branch -D svm-4.15

#before building,change some build cfg

#HNS VLAN build option
sed -i 's/CONFIG_VLAN_8021Q=m/CONFIG_VLAN_8021Q=y/g' arch/arm64/configs/defconfig

#
#sed -i '$a\CONFIG_IXGBE_DCB=y' arch/arm64/configs/plinth-config

cat arch/arm64/configs/defconfig | grep  CONFIG_VLAN_8021Q

echo "Begin to build the kernel!"
bash build.sh ${BOARD_TYPE} > ${BUILD_DIR}/output/ok.log

echo "Finish the kernel build!"

#********
#****END : Clone kernel repo and build it
#********
