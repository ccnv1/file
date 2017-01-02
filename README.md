# file
存放文件
#SSR
wget -N --no-check-certificate https://raw.githubusercontent.com/FunctionClub/SSR-Bash/master/install.sh && bash install.sh
#BBR
wget -N --no-check-certificate https://soft.dou-bi.co/Bash/bbr.sh && chmod +x bbr.sh && bash bbr.sh
#Aria2
wget --no-check-certificate https://raw.githubusercontent.com/ccnv1/file/master/aria2.sh && bash aria2.sh

cd /www/yc
rm -rf /www/yc/*
wget --no-check-certificate https://raw.githubusercontent.com/mayswind/AriaNg/gh-pages/downloads/latest_daily_build.zip
unzip -o latest_daily_build.zip
rm -rf latest_daily_build.zip

