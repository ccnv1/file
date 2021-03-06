#!/bin/sh
echo '
	************************************************************
	*****                                                  *****
	*****        本脚本只在debian8 x64上通过测试           *****
	*****                                                  *****
	************************************************************
            默认Aria2管理界面：你下面填写的域名/web                                               
	    例如：pan.xxx.com/web										
											-Powered by 小表弟
'
read -p '请输入网盘下载地址（例如 pan.xxx.com）： ' pan;
[ -z "$pan" ] && echo "你是猪吗，让你填域名 已经给你设置为www.baidu.com，自己改" && pan="www.baidu.com"
apt-get update -y
apt-get install -y --force-yes deb-multimedia-keyring
apt-get install -y -t jessie nginx php5 php5-fpm php5-gd ffmpeg unzip
apt-get install -y build-essential
mkdir -p /home/wwwroot/${pan}/web
cd /etc/nginx/
rm -rf fastcgi_params
echo '
fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  REDIRECT_STATUS    200;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;
fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  HTTPS              $https if_not_empty;
fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;
' >> fastcgi_params

cd conf.d

echo "
server {
    listen 80;
    server_name ${pan};
    root /home/wwwroot/${pan};

    location / {
        index index.html index.php /_h5ai/public/index.php;
    }
    location ~* \.php$ {
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(.*)$;
        include fastcgi_params;
    }
}
" >> ${pan}.conf

cd
echo "deb http://ftp.debian.org/debian sid main" >>/etc/apt/sources.list
apt-get update -y
apt-get install aria2 screen -y
sed -i '/debian sid main/d' /etc/apt/sources.list
mkdir .aria2

echo "

## '#'开头为注释内容, 选项都有相应的注释说明, 根据需要修改 ##
## 被注释的选项填写的是默认值, 建议在需要修改时再取消注释  ##

## 文件保存相关 ##

# 文件的保存路径(可使用绝对路径或相对路径), 默认: 当前启动位置
dir=/home/wwwroot/${pan}/
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
#disk-cache=32M
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: none < falloc ? trunc < prealloc
# falloc和trunc则需要文件系统和内核支持
# NTFS建议使用falloc, EXT3/4建议trunc, MAC 下需要注释此项
file-allocation=none
# 断点续传
continue=true

## 下载连接相关 ##

# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=10
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=5
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=10M
# 单个任务最大线程数, 添加时可指定, 默认:5
split=20
# 整体下载速度限制, 运行时可修改, 默认:0
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0
#max-upload-limit=0
# 禁用IPv6, 默认:false
disable-ipv6=true

## 进度保存相关 ##

# 从会话文件中读取下载任务
input-file=/root/.aria2/aria2.session
# 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
save-session=/root/.aria2/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
#save-session-interval=60

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
#event-poll=select
# RPC监听端口, 端口被占用时可以修改, 默认:6800
#rpc-listen-port=6800
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
#rpc-secret=<TOKEN>
# 设置的RPC访问用户名, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-user=<USER>
# 设置的RPC访问密码, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-passwd=<PASSWD>

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
#follow-torrent=true
# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
listen-port=51413
# 单个种子最大连接数, 默认:55
#bt-max-peers=55
# 打开DHT功能, PT需要禁用, 默认:true
enable-dht=true
# 打开IPv6 DHT功能, PT需要禁用
#enable-dht6=false
# DHT网络监听端口, 默认:6881-6999
#dht-listen-port=6881-6999
# 本地节点查找, PT需要禁用, 默认:false
#bt-enable-lpd=true
# 种子交换, PT需要禁用, 默认:true
enable-peer-exchange=true
# 每个种子限速, 对少种的PT很有用, 默认:50K
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
peer-id-prefix=-UT341-
user-agent=uTorrent/341(109279400)(30888)
# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
seed-ratio=0.1
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
#force-save=false
# BT校验相关, 默认:true
#bt-hash-check-seed=true
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=false

" >> /root/.aria2/aria2.conf
echo '' > /root/.aria2/aria2.session
#开机自启aria2
sed -i '/exit 0/d' /etc/rc.local
echo "screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf -D
exit 0" >> /etc/rc.local
chmod +x /etc/rc.local
#启动aria2
screen -dmS aria2 aria2c --conf-path=/root/.aria2/aria2.conf -D
# AriaNg （Aria2 管理界面）
cd /home/wwwroot/${pan}/web
wget --no-check-certificate https://raw.githubusercontent.com/mayswind/AriaNg/gh-pages/downloads/latest_daily_build.zip
unzip -o latest_daily_build.zip
rm -rf latest_daily_build.zip

cd /home/wwwroot/${pan}
chmod 777 /home/wwwroot/${pan}
wget --no-check-certificate https://raw.githubusercontent.com/ccnv1/file/master/_h5ai.zip
unzip -o _h5ai.zip
rm -rf _h5ai.zip
chmod 777 ./_h5ai/public/cache
chmod 777 ./_h5ai/private/cache

cd /home/wwwroot
apt-get install -y git autoconf python2.7-dev python-pip
git clone https://github.com/binux/qiandao.git
cd qiandao
pip install tornado u-msgpack-python jinja2 chardet requests pbkdf2 pycrypto
cd
#开机自启签到
sed -i '/exit 0/d' /etc/rc.local
echo "screen -dmS qiandao /home/wwwroot/qiandao/run.py
exit 0" >> /etc/rc.local
chmod +x /etc/rc.local
#启动签到
screen -dmS qiandao /home/wwwroot/qiandao/run.py
#启动PHP/nginx
service nginx restart
service php5-fpm restart
