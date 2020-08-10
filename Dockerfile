FROM openresty/openresty:bionic
RUN apt-get install iputils-ping -y && apt-get install iputils-tracepath -y && apt-get install git -y && apt-get install curl -y && apt-get install telnet -y
#RUN export DEBIAN_FRONTEND=noninteractive &&  apt-get  -yq install wkhtmltopdf
RUN rm -rf /var/lib/apt/lists/*

RUN git config --global url."https://".insteadOf git://
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http
RUN /usr/local/openresty/luajit/bin/luarocks install resty-smtp
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-mail
RUN /usr/local/openresty/luajit/bin/luarocks install lua-zlib
RUN /usr/local/openresty/luajit/bin/luarocks install zipwriter
RUN /usr/local/openresty/luajit/bin/luarocks install struct
RUN /usr/local/openresty/luajit/bin/luarocks install lua-xlsxwriter
#RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-template



