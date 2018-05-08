#!/bin/bash -ex
#: Title                  : jenkins_build_v500_start.sh
#: Usage                  : ./local/ci-scripts/build-scripts/jenkins_build_v500_start.sh -p env.properties
#: Author                 : qinsl0106@thundersoft.com
#: Description            : CI中自动编译的jenkins任务脚本，针对v500
# only works on centos

#!/bin/bash

#PRE_TOP_DIR=$(cd "`dirname $0`" ; pwd)


#record the path of parent script,we need to return this dir after build is over
CUR_TOP_DIR=`pwd`


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
cat .git/config | grep 'github.com'
if [ x"$1" == x"${o}" ];then
	sed -i 's/github.com/Luojiaxing1991:ljxfyjh1321@github.com/g' .git/config
fi

#url = https://github.com/hisilicon/kernel-dev.git

ls -a

#generate the patch of pmu v2 to make perf support in D05
#git stash
#git checkout -b svm-4.15 remotes/origin/release-plinth-4.15.0
#tmp_patch=`git format-patch -1 b4e84aac21e48fcccc964216be5c7f8530db7b32`

#cp ${tmp_patch}  ${BUILD_DIR}/output

#before checkout branch,update the remote branch list
#expect -c '
#spawn git remote update origin --prune
#expect "Username for 'https://github.com':"
#send "Luojiaxing1991\r"
#expect "Password for 'https://Luojiaxing1991@github.com':"
#send "ljxfyjh1321\r"
#expect eof
#exit 0
#'



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

#git branch -D tmp_luo

#before any change,patch the PMU patch to support D05
#git am --abort
#git am ${BUILD_DIR}/output/${tmp_patch}
#sleep 20
#git branch -D svm-4.15

#before building,change some build cfg

#HNS VLAN build option
#sed -i 's/CONFIG_VLAN_8021Q=m/CONFIG_VLAN_8021Q=y/g' arch/arm64/configs/defconfig

#
#sed -i '$a\CONFIG_IXGBE_DCB=y' arch/arm64/configs/plinth-config

#cat arch/arm64/configs/defconfig | grep  CONFIG_VLAN_8021Q

echo "Begin to build the kernel!"
#cp ${BUILD_DIR}/output/build.sh .

bash build.sh ${BOARD_TYPE} > ${BUILD_DIR}/output/ok.log

git stash
git checkout mybranch
git branch -D ${BRANCH_NAME}

echo "Finish the kernel build!"

cd ${CUR_TOP_DIR}

#********
#****END : Clone kernel repo and build it
#********
