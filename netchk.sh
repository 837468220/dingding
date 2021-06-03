#!/bin/bash
exec 1>>~/dingding/netchk.log 2>&1
export LC_ALL=C
SCKEY=
MIPUSHID=
PUSHPLUSTOKEN=
TEMP=$(getopt -o -- --long 'mipushid::,sckey::,pushplustoken::' -n 'dingding.sh' -- "$@")
date
if [ $? -ne 0 ]; then
  echo 'Terminating...' >&2
  exit 1
fi
# Note the quotes around `$TEMP': they are essential!
#set 会重新排列参数的顺序，也就是改变$1,$2...$n的值，这些值在getopt中重新排列过了
eval set -- "$TEMP"
unset TEMP

while true; do
  case "$1" in
    '--sckey')
      case "$2" in
        '')
          echo 'Option sckey, no argument'
        ;;
        *)
          echo "Option sckey, argument '$2'"
          SCKEY=$2
        ;;
      esac
      shift 2
      continue
    ;;
    '--mipushid')
      # c has an optional argument. As we are in quoted mode,
      # an empty parameter will be generated if its optional
      # argument is not found.
      case "$2" in
        '')
          echo 'Option mipushid, no argument'
        ;;
        *)
          echo "Option mipushid, argument '$2'"
          MIPUSHID=$2
        ;;
      esac
      shift 2
      continue
    ;;
    '--pushplustoken')
      case "$2" in
        '')
          echo 'Option pushplustoken, no argument'
        ;;
        *)
          echo "Option pushplustoken, argument '$2'"
          PUSHPLUSTOKEN=$2
        ;;
      esac
      shift 2
      continue
    ;;
    '--')
      shift
      break
    ;;
    *)
      echo 'Internal error!' >&2
      exit 1
    ;;
  esac
done

echo 'Remaining arguments:'
for arg; do
  echo "--> '$arg'"
done
    #curl "https://script.haokaikai.cn/MiPush/index.php?id=${MIPUSHID}&title=%E9%92%89%E9%92%89%E6%89%93%E5%8D%A1&msg=%E5%85%B3%E9%97%ADwifi%E6%89%93%E5%BC%80data" ;
#curl "https://sc.ftqq.com/${SCKEY}.send?text=%e9%92%89%e9%92%89%e6%89%93%e5%8d%a1%e6%88%90%e5%8a%9f"
url=
sn=emulator-5554
LC_ALL=C adb devices | grep $sn || {
  curl "http://sc.ftqq.com/${SCKEY}.send?text=adb%20devices%20error"
  netstat -lntp | grep 5555 && LC_ALL=C adb kill-server || ssh -p 2222 liangfei@127.0.0.1 "adb -s c69605a87cf5 tcpip 5555"
  exit
}

[[ $(($(date +%M)/10)) = 1 ]] && { :; LC_ALL=C adb -s $sn shell svc wifi enable ; sleep 33; }

ping -W 3 -c 1 www.baidu.com && : || {
  LC_ALL=C adb -s $sn shell svc data enable ;
  LC_ALL=C adb -s $sn shell svc wifi disable ;
  sleep 10;
  if [[ -n ${MIPUSHID} ]] ; then
    :
    curl "https://script.haokaikai.cn/MiPush/index.php?id=${MIPUSHID}&title=netchk&msg=%E5%85%B3%E9%97%ADwifi%E6%89%93%E5%BC%80data" ;
  fi
  if [[ -n ${SCKEY} ]] ; then
    curl "http://sc.ftqq.com/${SCKEY}.send?text=Netchk%20Close%20Wifi%20and%20Open%20Data"
  fi
  if [[ -n ${PUSHPLUSTOKEN} ]] ; then
    :
    contenturl=
    #title="打卡结果推送"
    #titleurl=$(printf $title | od -An -tx1 | tr ' ' % | tr -d '\n')
    titleurl="Netchk%20Close%20Wifi%20and%20Open%20Data"
    curl "http://www.pushplus.plus/send?token=${PUSHPLUSTOKEN}&title=$titleurl&content=$contenturl&template=html"
  fi
}
