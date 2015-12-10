FROM phusion/baseimage:0.9.17
MAINTAINER Tomasz Sętkowski <tom@ai-traders.com>

COPY ide-scripts/* /usr/bin/

RUN useradd -d /home/ide -p pass -s /bin/bash -u 1000 -m ide &&\
    chmod 755 /usr/bin/ide-fix-uid-gid.sh &&\
    chmod 755 /usr/bin/ide-setup-identity.sh &&\
    chmod 755 /usr/bin/entrypoint.sh &&\
    chown ide:ide -R /home/ide

RUN apt-get update && apt-get install -y -q \
 fakeroot git maven nsis openjdk-7-jdk rpm unzip zip
# install nodejs, update-alternatives is needed on ubuntu to enable command 'node'
RUN curl --silent --location https://deb.nodesource.com/setup_4.x | bash - && \
 apt-get install --yes nodejs && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10

RUN mkdir -p /ide/work && chown ide:ide /ide/work
RUN su - ide -c "git clone https://github.com/gocd/gocd.git /ide/work"
RUN su - ide -c "touch /ide/work/.ide-mark"

ADD gocd-scripts/go-compile.sh /usr/bin/go-compile
ADD gocd-scripts/go-build-installer.sh /usr/bin/go-build-installer

RUN chmod 755 /usr/bin/go-compile &&\
     chmod 755 /usr/bin/go-build-installer

RUN su - ide -c "/usr/bin/go-compile"

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/go-build-installer"]
