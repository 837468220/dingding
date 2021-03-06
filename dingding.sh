#!/bin/bash
exec 1>>~/dingding/dingding.log 2>&1
export LC_ALL=C
set -xv
#-o表示短选项，两个冒号表示该选项有一个可选参数，可选参数必须紧贴选项
#    如-carg 而不能是-c arg
#--long表示长选项
#"$@" ：参数本身的列表，也不包括命令本身
# -n:出错时的信息
# -- ：举一个例子比较好理解：
#我们要创建一个名字为 "-f"的目录你会怎么办？
# mkdir -f #不成功，因为-f会被mkdir当作选项来解析，这时就可以使用
# mkdir -- -f 这样-f就不会被作为选项。
SCKEY=
MIPUSHID=
PUSHPLUSTOKEN=
TEMP=$(getopt -o -- --long 'mipushid::,sckey::,pushplustoken::' -n 'dingding.sh' -- "$@")
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
  exit
}
screenshot()
{
  Ymd_HMS=$(date +%Y%m%d%H%M%S)
  Y=$(date +%Y)
  m=$(date +%m)
  d=$(date +%d)
  H=$(date +%H)
  M=$(date +%M)
  S=$(date +%S)
  dstdir=/sdcard/dingding_screencap/$Y$m
  [[ -d $dstdir ]] || mkdir -p $dstdir
  [[ -f $dstdir/.nomedia ]] || touch $dstdir/.nomedia
  LC_ALL=C adb -s $sn shell screencap -p $dstdir/screen_${Ymd_HMS}.png
  url="http://xjz.liangfei.vip:8000/$Y$m/screen_${Ymd_HMS}.png"
}
echo start
ping -W 2 -c 1 www.baidu.com && : || { LC_ALL=C adb -s $sn shell svc data enable ; LC_ALL=C adb -s $sn shell svc wifi disable ;
    if [[ -n ${MIPUSHID} ]] ; then
      :
      #curl "https://script.haokaikai.cn/MiPush/index.php?id=${MIPUSHID}&title=%E9%92%89%E9%92%89%E6%89%93%E5%8D%A1&msg=%E5%85%B3%E9%97%ADwifi%E6%89%93%E5%BC%80data" ;
    fi
    if [[ -n ${SCKEY} ]] ; then
      curl "http://sc.ftqq.com/${SCKEY}.send?text=%E9%92%89%E9%92%89%E6%89%93%E5%8D%A1close%20wifi%20and%20open%20data"
    fi
}
cd $(dirname $0)
date
md=$(date +%Y%m%d)
grep $md jiejiari.json && {
  :
  rc=$(cat jiejiari.json | python -c "import sys, json; print (json.load(sys.stdin)['$md'])")
  if [[ ${rc}x != '0x' ]] ; then exit ; fi
} || {
  :
  u=$(date +%u)
  if [[ ${u}x == '6x' ||  ${u}x == '7x' ]] ; then exit ; fi
}
#sleep $(($(head -1 /dev/urandom | cksum.exe | awk '{print $1}')%600))
sleep $(($RANDOM%600))
date
LC_ALL=C adb -s $sn shell dumpsys window policy | grep 'mScreenOnFully=true' || {
  LC_ALL=C adb -s $sn shell input keyevent 26
  sleep 3
} && {
  LC_ALL=C adb -s $sn shell am start -n com.alibaba.android.rimet/.biz.LaunchHomeActivity
  sleep 16
  screenshot
  [[ -n ${MIPUSHID} ]] && curl "https://script.haokaikai.cn/MiPush/index.php?id=${MIPUSHID}&title=%E9%92%89%E9%92%89%E9%80%9A%E7%9F%A5&msg=%E6%89%93%E5%8D%A1%E6%88%90%E5%8A%9F"
  if [[ -n ${SCKEY} ]] ; then
    content="钉钉打卡截图
    "'!'"[pic]($url)"
    curl "http://sc.ftqq.com/${SCKEY}.send?text=%e9%92%89%e9%92%89%e6%9e%81%e9%80%9f%e6%89%93%e5%8d%a1%e6%88%90%e5%8a%9f" -d "&desp=$content"
  fi
  if [[ -n ${PUSHPLUSTOKEN} ]] ; then
    :
    content="<img src=$url>"
    contenturl=$(printf 打卡截图  | od -An -tx1 | tr ' ' % | tr -d '\n')$(date +%Y/%m/%d-%H:%M)%0a$(echo -n $content  | od -An -tx1 | tr ' ' % | tr -d '\n')
    title="打卡结果推送"
    titleurl=$(printf $title | od -An -tx1 | tr ' ' % | tr -d '\n')
    curl "http://www.pushplus.plus/send?token=${PUSHPLUSTOKEN}&title=$titleurl&content=$contenturl&template=html"
  fi
  sleep 1
  LC_ALL=C adb -s $sn shell input keyevent 3
  sleep 5
}
LC_ALL=C adb -s $sn shell dumpsys window policy | grep 'mScreenOnFully=true' && LC_ALL=C adb -s $sn shell input keyevent 26
date
echo end
#exit 0
