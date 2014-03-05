FROM centos
MAINTAINER Yohei Kawahara "inokara@gmail.com"
#
RUN yum install -y gcc git openssh-server
RUN rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y nodejs npm --enablerepo=epel
RUN cd /root/ && wget http://download.redis.io/releases/redis-2.8.6.tar.gz
RUN cd /root/ && tar zxvf redis-2.8.6.tar.gz
RUN cd /root/redis-2.8.6 && make && make install
RUN sed -i 's/daemonize\ no/daemonize\ yes/g' /root/redis-2.8.6/redis.conf
RUN cp /root/redis-2.8.6/redis.conf /usr/local/etc/
RUN npm install -g redis-commander
RUN yum install -y http://pkgs.repoforge.org/monit/monit-5.5-1.el6.rf.x86_64.rpm
RUN echo "NETWORKING=yes" >/etc/sysconfig/network
#
ADD monit.conf /etc/
RUN chmod 600 /etc/monit.conf && chown root:root /etc/monit.conf
ADD redis.conf.monit /etc/monit.d/redis.conf
ADD redis-commander.conf.monit /etc/monit.d/redis-commander.conf
ADD sshd.conf.monit /etc/monit.d/sshd.conf

RUN useradd -d /home/sandbox -m -s /bin/bash sandbox
RUN echo sandbox:sandbox | chpasswd
RUN echo 'sandbox ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
#
# for redis
EXPOSE 6379
# for redis-commander
EXPOSE 8081
# for ssh
EXPOSE 22
# for monit
EXPOSE 2812
#
CMD ["/usr/bin/monit", "-I", "-c", "/etc/monit.conf"]
