FROM openresty/openresty:xenial
RUN apt-get install iputils-ping -y
RUN apt-get install git -y
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http
RUN /usr/local/openresty/luajit/bin/luarocks install resty-smtp