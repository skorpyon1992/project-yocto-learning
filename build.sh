#!/bin/bash

clone_layers() {

  git clone -b warrior https://git.yoctoproject.org/git/poky
  git clone -b warrior https://github.com/openembedded/meta-openembedded.git

  if [[ $AUTO -eq 1 ]]
  then
    git clone -b $MACHINE https://github.com/skorpyon1992/meta-yoctolearning.git
  fi

  case "$MACHINE" in
    raspberrypi|raspberrypi2|raspberrypi3)
      git clone -b warrior https://git.yoctoproject.org/git/meta-raspberrypi
      ;;
    phyboard-regor-am335x-1)
      git clone -b warrior https://git.phytec.de/git/meta-phytec
  esac
}


source_bitbake() {
  if [[ $AUTO -eq 1 ]]
  then
      export TEMPLATECONF=${MAIN_DIR}/yocto/meta-yoctolearning/conf
  fi

  source poky/oe-init-build-env build

  if [[ $1 -eq 1 ]]
  then
    echo "MACHINE=\"${MACHINE}\"" >> ${MAIN_DIR}/yocto/build/conf/local.conf
  fi
}

check_machine() {
  for var in "${MACHINE_LIST[@]}"
  do
    if [[ "$var" = "$MACHINE" ]]; then
      DEVICE_FOUND=1
    fi
  done

  if [[ $DEVICE_FOUND -lt 1 ]]; then
    echo "Unknown machine name: $MACHINE"
    echo "Supported devices are: ${MACHINE_LIST[@]}"
    exit 1
  fi
}

install_prerequisites() {
  sudo apt-get install gawk wget git-core git diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
     xterm bmap-tools

}

do_prepare() {
  if [ ! -d yocto ] ; then
    mkdir yocto
  fi
  cd yocto
  check_machine
  install_prerequisites
  clone_layers
  source_bitbake 1

}

do_flash() {
  echo "Select sdcard partition : "
  lsblk
  read SDCARD_PARTITION
  echo "Select direct file to flash : "
  ls -1A yocto/build/deploy/images/wic
  read SDCARD_IMAGE
  sudo bmaptool copy yocto/build/deploy/images/wic/${SDCARD_IMAGE} /dev/${SDCARD_PARTITION} --nobmap
  sync
}

do_build() {
  cd yocto
  source_bitbake 0
  bitbake ${IMAGE_NAME}
  wic create ${IMAGE_TYPE} -e ${IMAGE_NAME} -o ./deploy/images/wic
}

SHIFTCOUNT=0
IMAGE_NAME="core-image-minimal"
IMAGE_TYPE="sdimage-raspberrypi"
MACHINE="raspberrypi3"
MACHINE_LIST=( "raspberrypi3" "raspberrypi2" "raspberrypi1" "phyboard-regor-am335x-1")
AUTO=0
MAIN_DIR=$(pwd)

while getopts "am:" opt;  do
  case "$opt" in
    h|\?)
        print_usage
        exit 0
        ;;
    m)
      MACHINE=$OPTARG
      SHIFTCOUNT=$(( $SHIFTCOUNT+2 ))
      ;;
    a)
      AUTO=1
      IMAGE_NAME="first-yocto-image"
      IMAGE_TYPE="first-sdimage"
      SHIFTCOUNT=$(( $SHIFTCOUNT+1 ))
      ;;
    *)
      ;;
  esac
done

shift $SHIFTCOUNT

while true ; do
  case "$1" in
    prepare)
      do_prepare
      shift
      break
      ;;

    build)
      do_build
      shift
      break
      ;;

    flash)
      do_flash
      shift
      break
      ;;
    *)
      echo "Invalid option!"
      break
      ;;
  esac

done