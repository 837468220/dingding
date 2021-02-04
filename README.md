# dingding
钉钉自动极速打卡

termux 0.94

/data/data/com.termux/files/usr/bin/adb

打开手机网络调试

安装crond

pkg upgrade

pkg install cronie runit termux-services

$ crontab -l

1 8 * * * bash ~/dingding/dingding.sh --sckey=""

1 12 * * * bash ~/dingding/dingding.sh --sckey=""

1 13 * * * bash ~/dingding/dingding.sh --sckey=""

31 17 * * * bash ~/dingding/dingding.sh --sckey=""

rm /data/data/com.termux/files/usr/var/service/crond/down

sv up crond


