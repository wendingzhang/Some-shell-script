#########################################################################
# File Name: SIM7000.sh
# Author: wending.zhang
# mail: wending.zhang@sim.com
# Created Time: Mon 26 Dec 2016 02:53:17 PM CST
#########################################################################
#!/bin/bash

#SIM7000 COMPILE SCRIPT

CurDir="$(cd `dirname $0`; pwd)"
cd `dirname $0`

if [ $1 ]; then
	OPERATION="$1"
	if [ $OPERATION == "BUILD" ]; then 
		if [ $2 ]; then
			COMPILETYPE="$2"
		else
			read -t 30 -p "Please input the compilation type: (1:BOOT/2:TZ/3:RPM/4:MODEM/5:APPS/6:BINARY) [ALL]:" COMPILETYPE
			if [ -z $COMPILETYPE ]; then
				COMPILETYPE="ALL"
			fi
		fi
		if [ $3 ]; then
			MODEMTYPE="$3"
		else
			if [[ $COMPILETYPE == "ALL" || $COMPILETYPE == "4" || $COMPILETYPE == "6" ]]; then
				echo "1:LTE only"
				echo "2:LTE only with f3"
				echo "3:LTE only without GPS"
				echo "4:LTE only without GPS with f3"
				read -t 30 -p "Please input the choice : (1/2/3/4) [1]:" MODEMTYPE
				if [ -z $MODEMTYPE ]; then
					MODEMTYPE="1"
				fi
			fi
		fi
		if [ $MODEMTYPE == "1" ]; then
			modem_com_cmd="build.sh 9607.lteonly.prod -k"
			xml_file="contents.xml"
		elif [ $MODEMTYPE == "2" ]; then
			modem_com_cmd="build.sh 9607.lteonlyf3.prod -k"
			xml_file="contents_LTEONLYF3.xml"
		elif [ $MODEMTYPE == "3" ]; then
			modem_com_cmd="build.sh 9607.lteonlynogps.prod -k"
			xml_file="contents_LTEONLYNoGPSNoF3.xml"
		elif [ $MODEMTYPE == "4" ]; then
			modem_com_cmd="build.sh 9607.lteonlynogpsf3.prod -k"
			xml_file="contents_LTEONLYNoGPSF3.xml"
		else
			echo "Please input right number of modem type!(1/2/3/4)"
			echo "1:LTE only"
			echo "2:LTE only with f3"
			echo "3:LTE only without GPS"
			echo "4:LTE only without GPS with f3"
		fi

		case $COMPILETYPE in
			1)
				source setenv.sh
				cd  $CurDir/../../boot_images/build/ms/
				./build.sh TARGET_FAMILY=9x07 --prod
				cd $CurDir
			;;
			2)
				source setenv.sh
				cd $CurDir/../../trustzone_images/build/ms/
				./build.sh CHIPSET=mdm9x07 tz tzbsp_no_xpu
				cd $CurDir
			;;
			3)
				source setenv_rpm.sh
				cd $CurDir/../../rpm_proc/build/
				./build_9x07.sh
				cd $CurDir
			;;
			4)
				source setenv.sh
				cd $CurDir/../../modem_proc/build/ms/
				./$modem_com_cmd
				cd $CurDir
			;;
			5)
				source setenv_apps.sh
				cd $CurDir/../../apps_proc/build/ms/
				./build.sh apps_images BUILD_ID=ACINAAAZ
				cd $CurDir
			;;
			6)
				cp $CurDir/../../common/build/$xml_file $CurDir/../../contents.xml -Rf
				cd ../../common/build/
				python build.py
				cd $CurDir/../../binaries/
				cp $CurDir/../../boot_images/build/ms/bin/9x07/nand/LAATANAZA/sbl1.mbn $CurDir/../../binaries/ -Rf 
				cp $CurDir/../../common/config/partition_nand.xml $CurDir/../../binaries/ -Rf
				cp $CurDir/../../contents.xml $CurDir/../../binaries/ -Rf
			;;
			ALL)
				source setenv.sh
				cd $CurDir/../../boot_images/build/ms/
				./build.sh TARGET_FAMILY=9x07 --prod
				cd $CurDir/../../trustzone_images/build/ms/
				./build.sh CHIPSET=mdm9x07 tz tzbsp_no_xpu
				cd $CurDir/../../modem_proc/build/ms/
				./$modem_com_cmd
				source $CurDir/setenv_rpm.sh
				cd $CurDir/../../rpm_proc/build/
				./build_9x07.sh
				source $CurDir/setenv_apps.sh
				cd $CurDir/../../apps_proc/build/ms/
				./build.sh apps_images BUILD_ID=ACINAAAZ
				cd $CurDir/../../
				cp ./common/build/$xml_file ./contents.xml -Rf
				cd ./common/build/
				python build.py
				cd $CurDir/../../binaries/
				cp $CurDir/../../boot_images/build/ms/bin/9x07/nand/LAATANAZA/sbl1.mbn $CurDir/../../binaries/ -Rf 
				cp $CurDir/../../common/config/partition_nand.xml $CurDir/../../binaries/ -Rf
				cp $CurDir/../../contents.xml $CurDir/../../binaries/ -Rf
			;;
			*)	
				echo "Please input right choice!(1/2/3/4/5/6)"
			;;
		esac
	elif [ $OPERATION == "CLEAN" ]; then
		if [ $2 ]; then
			CLEANTYPE="$2"
		else
			read -t 30 -p "Please input the clean type: (1:BOOT/2:TZ/3:RPM/4:MODEM/5:APPS) [ALL]:" CLEANTYPE
			if [ -z $CLEANTYPE ]; then
				CLEANTYPE="ALL"
			fi
		fi
		if [ $3 ]; then
			MODEMTYPE="$3"
		else
			if [[ $CLEANTYPE == "ALL" || $CLEANTYPE == "4" ]]; then
				echo "1:LTE only"
				echo "2:LTE only with f3"
				echo "3:LTE only without GPS"
				echo "4:LTE only without GPS with f3"
				read -t 30 -p "Please input the choice : (1/2/3/4) [1]:" MODEMTYPE
				if [ -z $MODEMTYPE ]; then
					MODEMTYPE="1"
				fi
			fi
		fi
	
		if [ $MODEMTYPE == "1" ]; then
			modem_clean_cmd="build.sh 9607.lteonly.prod -c"
		elif [ $MODEMTYPE == "2" ]; then
			modem_clean_cmd="build.sh 9607.lteonlyf3.prod -c"
		elif [ $MODEMTYPE == "3" ]; then
			modem_clean_cmd="build.sh 9607.lteonlynogps.prod -c"
		elif [ $MODEMTYPE == "4" ]; then
			modem_clean_cmd="build.sh 9607.lteonlynogpsf3.prod -c"
		else
			echo "Please input right number of modem type!(1/2/3/4)"
			echo "1:LTE only"
			echo "2:LTE only with f3"
			echo "3:LTE only without GPS"
			echo "4:LTE only without GPS with f3"
		fi
		
		case $CLEANTYPE in 
			1)
				cd $CurDir/../../boot_images/build/ms/
				./build.sh TARGET_FAMILY=9x07 –prod -c
				cd $CurDir
			;;
			2)
				cd $CurDir/../../trustzone_images/build/ms/
				./build.sh CHIPSET=mdm9x07 tz tzbsp_no_xpu -c
				cd $CurDir
			;;
			3)
				cd $CurDir
				source setenv_rpm.sh
				cd $CurDir/../../rpm_proc/build/
				./build_9x07.sh -c
				cd $CurDir
			;;
			4)
				cd $CurDir/../../modem_proc/build/ms/
				./$modem_clean_cmd
				cd $CurDir
			;;
			5)
				cd $CurDir/../../apps_proc/build/ms/
				./build.sh apps_images BUILD_ID=ACINAAAZ -c
				cd $CurDir
			;;
			ALL)
				source setenv.sh
				cd $CurDir/../../boot_images/build/ms/
				./build.sh TARGET_FAMILY=9x07 –prod -c
				cd $CurDir/../../trustzone_images/build/ms/
				./build.sh CHIPSET=mdm9x07 tz tzbsp_no_xpu -c
				cd $CurDir/../../modem_proc/build/ms/
				./$modem_clean_cmd
				cd $CurDir
				source setenv_rpm.sh
				cd $CurDir/../../rpm_proc/build/
				./build_9x07.sh -c
				cd $CurDir
				source setenv_apps.sh
				cd $CurDir/../../apps_proc/build/ms/
				./build.sh apps_images BUILD_ID=ACINAAAZ -c
				cd $CurDir
			;;
			*)
				echo "Please input right choice!(1/2/3/4/5)"
			;;
		esac
	fi
else
	echo ""
	echo "Please input an operation!<BUILD or CLEAN>"
	echo ""
	echo "***************************************************************************************"
	echo "You have two methods to build or clean"
	echo "# FOR EXAMPLE:"
	echo "  1.. source SIM7000.sh BUILD"
	echo "  .....and then choose the options that provided."
	echo "# OR"
	echo "  2.. source SIM7000.sh BUILD ALL 1"
	echo "  .....the 2nd param 'ALL' means to compile the whole project"
	echo "  .....you can choose the 2nd param from below."
	echo "  .....1:BOOT/2:TZ/3:RPM/4:MODEM/5:APPS/6:BINAR/ALL ......(BUILD)"
	echo "  .....1:BOOT/2:TZ/3:RPM/4:MODEM/5:APPS/ALL ..............(CLEAN)"
	echo "  .....if the 2nd param is modem related(MODEM/BINARY/ALL), the 3rd param is optional"
	echo "  .....and the options are below."
	echo "  .....1:LTE only"
	echo "  .....2:LTE only with f3"
	echo "  .....3:LTE only without GPS"
	echo "  .....4:LTE only without GPS with f3"
	echo "***************************************************************************************"
fi
