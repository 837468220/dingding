# dingding
钉钉自动极速打卡

termux 0.94

/data/data/com.termux/files/usr/bin/adb
打开手机网络调试
安装crond

pkg install cronie

$ crontab -l

1 8 * * * bash ~/dingding/dingding.sh

1 12 * * * bash ~/dingding/dingding.sh

1 13 * * * bash ~/dingding/dingding.sh

31 17 * * * bash ~/dingding/dingding.sh

rm /data/data/com.termux/files/usr/var/service/crond/down

sv up crond


