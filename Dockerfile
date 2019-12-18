FROM openresty/openresty:bionic
RUN apt-get install iputils-ping -y
RUN apt-get install git -y
RUN apt-get install curl -y
RUN rm -rf /var/lib/apt/lists/*

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http
RUN /usr/local/openresty/luajit/bin/luarocks install resty-smtp
#RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-template



