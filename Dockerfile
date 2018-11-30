FROM openjdk:8-jdk
MAINTAINER Tomasz Sętkowski <tom@ai-traders.com>

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sudo git ca-certificates && \
  git clone --depth 1 -b 0.8.2 https://github.com/ai-traders/ide.git /tmp/ide_git && \
  /tmp/ide_git/ide_image_scripts/src/install.sh && \
  rm -r /tmp/ide_git && \
  echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY ide-scripts/* /etc/ide.d/scripts/

RUN apt-get update && apt-get install -y -q \
 sudo fakeroot git nsis rpm unzip zip mercurial rake subversion wget
# install nodejs, update-alternatives is needed on ubuntu to enable command 'node'
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - &&\
 apt-get install --yes nodejs && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
   echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list &&\
   apt-get update && apt-get install -y yarn

# install gradle, so that gradlew is not needed.
ENV GRADLE_VERSION 4.10
ENV GRADLE_HOME /usr/lib/gradle/gradle-${GRADLE_VERSION}
RUN cd /tmp &&\
  wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip &&\
  unzip gradle-${GRADLE_VERSION}-bin.zip && mv gradle-${GRADLE_VERSION}/ /usr/lib/ &&\
  rm gradle-${GRADLE_VERSION}-bin.zip &&\
  ln -s /usr/lib/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

RUN apt-get install -y ruby-dev build-essential && \
  gem install fpm

RUN mkdir -p /ide/work && chown ide:ide /ide/work

ENV ORACLE_JRE_LICENSE_AGREE=1
# This will cache dependencies in the image
RUN su - ide -c "git clone --depth 1 https://github.com/gocd/gocd.git /ide/work &&\
  cd /ide/work &&\
  gradle clean prepare &&\
  rm -rf /ide/work/* &&\
  rm -rf /ide/work/.*"

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
