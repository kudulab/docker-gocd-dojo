FROM openjdk:8-jdk
MAINTAINER Tomasz Sętkowski <tom@ai-traders.com>

COPY ide-scripts/* /usr/bin/

RUN useradd -d /home/ide -p pass -s /bin/bash -u 1000 -m ide &&\
    chmod 755 /usr/bin/ide-fix-uid-gid.sh &&\
    chmod 755 /usr/bin/ide-setup-identity.sh &&\
    chmod 755 /usr/bin/entrypoint.sh &&\
    chown ide:ide -R /home/ide

RUN apt-get update && apt-get install -y -q \
 fakeroot git nsis rpm unzip zip mercurial rake subversion wget
# install nodejs, update-alternatives is needed on ubuntu to enable command 'node'
RUN curl --silent --location https://deb.nodesource.com/setup_4.x | bash - && \
 apt-get install --yes nodejs && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10

# install gradle, so that gradlew is not needed.
ENV GRADLE_VERSION 3.1
ENV GRADLE_HOME /usr/lib/gradle/gradle-${GRADLE_VERSION}
RUN cd /tmp &&\
  wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip &&\
  unzip gradle-${GRADLE_VERSION}-bin.zip && mv gradle-${GRADLE_VERSION}/ /usr/lib/ &&\
  rm gradle-${GRADLE_VERSION}-bin.zip &&\
  ln -s /usr/lib/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

RUN apt-get install -y ruby-dev build-essential && \
  gem install fpm

RUN mkdir -p /ide/work && chown ide:ide /ide/work
RUN mkdir -p /ide/output && chown ide:ide /ide/output
RUN su - ide -c "git clone https://github.com/gocd/gocd.git /ide/work"
RUN su - ide -c "touch /ide/work/.ide-mark"

ADD gocd-scripts/go-compile.sh /usr/bin/go-compile
ADD gocd-scripts/go-build-installer.sh /usr/bin/go-build-installer

RUN chmod 755 /usr/bin/go-compile &&\
     chmod 755 /usr/bin/go-build-installer

RUN su - ide -c "/usr/bin/go-compile"

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/go-build-installer"]
