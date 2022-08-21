#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'

checkroot(){
	[[ $EUID -ne 0 ]] && echo -e "${RED}请使用 root 用户运行本脚本！${PLAIN}" && exit 1
}

checksystem() {
	if [ -f /etc/redhat-release ]; then
	    release="centos"
	elif cat /etc/issue | grep -Eqi "debian"; then
	    release="debian"
	elif cat /etc/issue | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	elif cat /proc/version | grep -Eqi "debian"; then
	    release="debian"
	elif cat /proc/version | grep -Eqi "ubuntu"; then
	    release="ubuntu"
	elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
	    release="centos"
	fi
}

checkpython() {
	if  [ ! -e '/usr/bin/python' ]; then
	        echo "正在安装 Python"
	            if [ "${release}" == "centos" ]; then
	            		yum update > /dev/null 2>&1
	                    yum -y install python > /dev/null 2>&1
	                    yum -y install python39 > /dev/null 2>&1
	                    if  [ ! -e '/usr/bin/python' ]; then
	                        ln -s /usr/bin/python3 /usr/bin/python
	                    fi
	                else
	                	apt-get update > /dev/null 2>&1
	                    apt-get -y install python > /dev/null 2>&1
	                fi
	        
	fi
}

checkcurl() {
	if  [ ! -e '/usr/bin/curl' ]; then
	        echo "正在安装 Curl"
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install curl > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install curl > /dev/null 2>&1
	            fi
	fi
}

checkwget() {
	if  [ ! -e '/usr/bin/wget' ]; then
	        echo "正在安装 Wget"
	            if [ "${release}" == "centos" ]; then
	                yum update > /dev/null 2>&1
	                yum -y install wget > /dev/null 2>&1
	            else
	                apt-get update > /dev/null 2>&1
	                apt-get -y install wget > /dev/null 2>&1
	            fi
	fi
}


checkspeedtest() {
	if  [ ! -e './speedtest-cli/speedtest' ]; then
		echo "正在安装 Speedtest-cli"
		# 安装v1.2.0版本
		wget --no-check-certificate -qO speedtest.tgz https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-$(uname -m).tgz
	fi
	mkdir -p speedtest-cli && tar zxvf speedtest.tgz -C ./speedtest-cli/ > /dev/null 2>&1 && chmod a+rx ./speedtest-cli/speedtest
}

speed_test(){
	speedLog="./speedtest.log"
	true > $speedLog
		speedtest-cli/speedtest -p no -s $1 --accept-license > $speedLog 2>&1
		is_upload=$(cat $speedLog | grep 'Upload')
		if [[ ${is_upload} ]]; then
	        local REDownload=$(cat $speedLog | awk -F ' ' '/Download/{print $3}')
	        local reupload=$(cat $speedLog | awk -F ' ' '/Upload/{print $3}')
	        local relatency=$(cat $speedLog | awk -F ' ' '/Idle/{print $3}')
	        
			local nodeID=$1
			local nodeLocation=$2
			local nodeISP=$3
			
			strnodeLocation="${nodeLocation}　　　　　　"
			LANG=C
			#echo $LANG
			
			temp=$(echo "${REDownload}" | awk -F ' ' '{print $1}')
	        if [[ $(awk -v num1=${temp} -v num2=0 'BEGIN{print(num1>num2)?"1":"0"}') -eq 1 ]]; then
	        	printf "${RED}%-6s${YELLOW}%s%s${GREEN}%-24s${CYAN}%s%-10s${BLUE}%s%-10s${PURPLE}%-8s${PLAIN}\n" "${nodeID}"  "${nodeISP}" "|" "${strnodeLocation:0:24}" "↑ " "${reupload}" "↓ " "${REDownload}" "${relatency}" | tee -a $log
			fi
		else
	        local cerror="ERROR"
		fi
}

preinfo() {
	echo "***************************** SpeedTest 一键测速 ****************************************"
	echo "               节点更新： 2022/08/21  | 脚本更新: 2022/08/21"
	
	echo "使用方法： bash <(curl -Lso- https://github.com/doidea/speedtest/releases/download/v1.2/speedtest.sh)"

	echo "****************************************************************************************"
}

selecttest() {
	echo -e "  测速类型:    ${GREEN}1.${PLAIN} 所有节点    ${GREEN}2.${PLAIN} 取消测速"
	echo -ne "               ${GREEN}3.${PLAIN} 电信节点    ${GREEN}4.${PLAIN} 联通节点    ${GREEN}5.${PLAIN} 移动节点"
	while :; do echo
			read -p "  请输入数字选择测速类型: " selection
			if [[ ! $selection =~ ^[1-5]$ ]]; then
					echo -ne "  ${RED}输入错误${PLAIN}, 请输入正确的数字!"
			else
					break   
			fi
	done
}

runtest() {
	[[ ${selection} == 2 ]] && exit 1

	if [[ ${selection} == 1 ]]; then
		echo "——————————————————————————————————————————————————————————"
		echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
		start=$(date +%s) 

		# 电信
		 speed_test '3633' '上海' '电信'
		 speed_test '35722' '天津' '电信'
		 speed_test '29071' '成都' '电信'
		 speed_test '23844' '武汉' '电信'
		 speed_test '51772' '福州' '电信'
		 speed_test '3973' '兰州' '电信'
		 speed_test '17145' '合肥５Ｇ' '电信'
		 speed_test '26352' '南京５Ｇ' '电信'
		 speed_test '5396' '苏州５Ｇ' '电信'
		 speed_test '5317' '连云港５Ｇ' '电信'
		 speed_test '29353' '武汉５Ｇ' '电信'
		 speed_test '34115' '天津５Ｇ' '电信'
		 speed_test '34988' '沈阳５Ｇ' '电信'
		 speed_test '28225' '长沙５Ｇ' '电信'
		 speed_test '28946' '重庆５Ｇ' '电信'
		# 联通
		 speed_test '45170' '无锡' '联通'
		 speed_test '4870' '长沙' '联通'
		 speed_test '24447' '上海５Ｇ' '联通'
		 speed_test '36646' '郑州５Ｇ' '联通'
		# 移动
		 speed_test '25858' '北京' '移动'
		 speed_test '26940' '银川' '移动'
		 speed_test '15863' '南宁' '移动'
		 speed_test '16145' '兰州' '移动'
		 speed_test '16171' '福州' '移动'
		 speed_test '16398' '贵阳' '移动'
		 speed_test '17584' '重庆' '移动'
		 speed_test '26380' '西安' '移动'
		 speed_test '29105' '西安５Ｇ' '移动'
		 speed_test '26404' '合肥５Ｇ' '移动'
		 speed_test '6715' '杭州５Ｇ' '移动'
		 speed_test '41910' '郑州５Ｇ' '移动'
		# 广电和教育网节点，暂时先不用
		 # speed_test '5530' '重庆' '广电网CCN'
		 # speed_test '35527' '成都' '广电网四川'
		 # speed_test '30852' '昆山' '教育网'

		end=$(date +%s)  
		##rm -rf speedtest*
		echo "——————————————————————————————————————————————————————————"
		time=$(( $end - $start ))
		if [[ $time -gt 60 ]]; then
			min=$(expr $time / 60)
			sec=$(expr $time % 60)
			echo -ne "  测试完成, 本次测速耗时: ${min} 分 ${sec} 秒"
		else
			echo -ne "  测试完成, 本次测速耗时: ${time} 秒"
		fi
		echo -ne "\n  当前时间: "
		echo $(date +%Y-%m-%d" "%H:%M:%S)
		echo -e "  ${GREEN}# 三网测速中为避免节点数不均及测试过久，每部分未使用所${PLAIN}"
		echo -e "  ${GREEN}# 有节点，如果需要使用全部节点，可分别选择三网节点检测${PLAIN}"
	fi

	if [[ ${selection} == 3 ]]; then
		echo "——————————————————————————————————————————————————————————"
		echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
		start=$(date +%s) 

		 speed_test '3633' '上海' '电信'
		 speed_test '35722' '天津' '电信'
		 speed_test '29071' '成都' '电信'
		 speed_test '23844' '武汉' '电信'
		 speed_test '51772' '福州' '电信'
		 speed_test '3973' '兰州' '电信'
		 speed_test '17145' '合肥５Ｇ' '电信'
		 speed_test '26352' '南京５Ｇ' '电信'
		 speed_test '5396' '苏州５Ｇ' '电信'
		 speed_test '5317' '连云港５Ｇ' '电信'
		 speed_test '29353' '武汉５Ｇ' '电信'
		 speed_test '34115' '天津５Ｇ' '电信'
		 speed_test '34988' '沈阳５Ｇ' '电信'
		 speed_test '28225' '长沙５Ｇ' '电信'
		 speed_test '28946' '重庆５Ｇ' '电信'

		end=$(date +%s)  
		##rm -rf speedtest*
		echo "——————————————————————————————————————————————————————————"
		time=$(( $end - $start ))
		if [[ $time -gt 60 ]]; then
			min=$(expr $time / 60)
			sec=$(expr $time % 60)
			echo -ne "  测试完成, 本次测速耗时: ${min} 分 ${sec} 秒"
		else
			echo -ne "  测试完成, 本次测速耗时: ${time} 秒"
		fi
		echo -ne "\n  当前时间: "
		echo $(date +%Y-%m-%d" "%H:%M:%S)
	fi

	if [[ ${selection} == 4 ]]; then
		echo "——————————————————————————————————————————————————————————"
		echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
		start=$(date +%s) 

		 speed_test '45170' '无锡' '联通'
		 speed_test '4870' '长沙' '联通'
		 speed_test '24447' '上海５Ｇ' '联通'
		 speed_test '36646' '郑州５Ｇ' '联通'

		end=$(date +%s)  
		###rm -rf speedtest*
		echo "——————————————————————————————————————————————————————————"
		time=$(( $end - $start ))
		if [[ $time -gt 60 ]]; then
			min=$(expr $time / 60)
			sec=$(expr $time % 60)
			echo -ne "  测试完成, 本次测速耗时: ${min} 分 ${sec} 秒"
		else
			echo -ne "  测试完成, 本次测速耗时: ${time} 秒"
		fi
		echo -ne "\n  当前时间: "
		echo $(date +%Y-%m-%d" "%H:%M:%S)
	fi

	if [[ ${selection} == 5 ]]; then
		echo "——————————————————————————————————————————————————————————"
		echo "ID    测速服务器信息       上传/Mbps   下载/Mbps   延迟/ms"
		start=$(date +%s) 

		 speed_test '25858' '北京' '移动'
		 speed_test '26940' '银川' '移动'
		 speed_test '15863' '南宁' '移动'
		 speed_test '16145' '兰州' '移动'
		 speed_test '16171' '福州' '移动'
		 speed_test '16398' '贵阳' '移动'
		 speed_test '17584' '重庆' '移动'
		 speed_test '26380' '西安' '移动'
		 speed_test '29105' '西安５Ｇ' '移动'
		 speed_test '26404' '合肥５Ｇ' '移动'
		 speed_test '6715' '杭州５Ｇ' '移动'
		 speed_test '41910' '郑州５Ｇ' '移动'

		end=$(date +%s)  
		####rm -rf speedtest*
		echo "——————————————————————————————————————————————————————————"
		time=$(( $end - $start ))
		if [[ $time -gt 60 ]]; then
			min=$(expr $time / 60)
			sec=$(expr $time % 60)
			echo -ne "  测试完成, 本次测速耗时: ${min} 分 ${sec} 秒"
		else
			echo -ne "  测试完成, 本次测速耗时: ${time} 秒"
		fi
		echo -ne "\n  当前时间: "
		echo $(date +%Y-%m-%d" "%H:%M:%S)
	fi
}

runall() {
	checkroot;
	checksystem;
	checkpython;
	checkcurl;
	checkwget;
	checkspeedtest;
	clear
	speed_test;
	preinfo;
	selecttest;
	runtest;
	rm speedtest* -rf
}

runall
