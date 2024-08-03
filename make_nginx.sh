#!/bin/bash

useradd mock
useradd mockbuild
mkdir rpm && cd rpm && yumdownloader --source nginx

rpm -Uvh nginx*.src.rpm
yum-builddep nginx
cd /root

git clone --recurse-submodules https://github.com/google/ngx_brotli

cd ngx_brotli/deps/brotli && mkdir out && cd out

cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..

cmake --build /root/ngx_brotli/deps/brotli/out/ --config Release -j 2 --target brotlienc
sed -i  's/--lock-path=\/run\/lock\/subsys\/nginx/--with-http_stub_status_module --with-http_sub_module --add-module=\/root\/ngx_brotli --lock-path=\/run\/lock\/subsys\/nginx/g' /root/rpmbuild/SPECS/nginx.spec
cd /root/rpmbuild/SPECS/ && rpmbuild -ba nginx.spec -D 'debug_package %{nil}'

cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/
cd ~/rpmbuild/RPMS/x86_64
yum localinstall *.rpm -y
systemctl start nginx && systemctl status nginx


mkdir -p /usr/share/nginx/html/repo
cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/
createrepo /usr/share/nginx/html/repo/
sed -i 's/sendfile            on;/sendfile on;index index.html index.htm;autoindex on;/g' /etc/nginx/nginx.conf
nginx -s reload
echo "[otus]" >> /etc/yum.repos.d/otus.repo
echo "name=otus-linux" >> /etc/yum.repos.d/otus.repo
echo "baseurl=http://$`hostname -I`/repo" >> /etc/yum.repos.d/otus.repo
echo "gpgcheck=0" >> /etc/yum.repos.d/otus.repo
echo "enabled=1" >> /etc/yum.repos.d/otus.repo

setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config





