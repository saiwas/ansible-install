FROM centos:centos7

RUN sed -i -e '0,/#baseurl/ s/#baseurl/baseurl/' /etc/yum.repos.d/CentOS-Base.repo && \
    yum update -y && yum install -y \
    openssl epel-release ncurses python3 python3-pip && \
    yum clean all

RUN mkdir -p /path/to && \
    cd /tmp && \
    openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout RootCA.key -out RootCA.pem -subj "/C=US/CN=localhost" && \
    openssl x509 -outform pem -in RootCA.pem -out RootCA.crt && \
    mv /tmp/RootCA.crt /path/to/tower.crt && \
    mv /tmp/RootCA.key /path/to/tower.key

ADD https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-3.7.3-1.tar.gz  /tmp/ansible-tower-setup-3.7.3-1.tar.gz
RUN mkdir -p /var/log/tower && \
    cd tmp && \
    tar xvfz /tmp/ansible-tower-setup-3.7.3-1.tar.gz && \
    mv /tmp/ansible-tower-setup-3.7.3-1 /opt/ansible-tower && \
    sed -i '/admin_password/c\admin_password=1234567890' /opt/ansible-tower/inventory && \
    sed -i '/pg_host/c\pg_host="db"' /opt/ansible-tower/inventory && \
    sed -i '/pg_port/c\pg_port="5432"' /opt/ansible-tower/inventory && \
    sed -i '/pg_database/c\pg_database="ansible"' /opt/ansible-tower/inventory && \
    sed -i '/pg_username/c\pg_username="ansible"' /opt/ansible-tower/inventory && \
    sed -i '/pg_password/c\pg_password="ansible_pwd"' /opt/ansible-tower/inventory && \
    sed -i '/postgres_use_ssl/c\postgres_use_ssl=FALSE' /opt/ansible-tower/inventory && \
    sed -i '/required_ram/c\required_ram: 1500' /opt/ansible-tower/roles/preflight/defaults/main.yml && \
    sed -ie '/ansible_all_ipv6_addresses/,/endif/d' /opt/ansible-tower/roles/nginx/templates/nginx.conf

# RUN /usr/sbin/init
# RUN bash /opt/ansible-tower/setup.sh
CMD [ "tail", "-f", "/opt/ansible-tower/roles/preflight/defaults/main.yml" ]
EXPOSE 80 443
ENTRYPOINT [ "/usr/sbin/init" ]
