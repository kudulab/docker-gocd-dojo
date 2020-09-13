FROM centos:8

# Install common Dojo scripts
ENV DOJO_VERSION=0.10.0
RUN yum install --assumeyes \
  git sudo &&\
  git clone --depth 1 -b ${DOJO_VERSION} https://github.com/kudulab/dojo.git /tmp/dojo_git &&\
  /tmp/dojo_git/image_scripts/src/install.sh && \
  rm -r /tmp/dojo_git

COPY gocd-oss-cookbooks/provision /usr/local/src/provision/

RUN /usr/local/src/provision/provision-centos.sh --contrib

COPY profile /home/dojo/.profile
COPY bashrc /home/dojo/.bashrc
RUN chown dojo:dojo /home/dojo/.profile /home/dojo/.bashrc

COPY etc_dojo.d/scripts/* /etc/dojo.d/scripts/
COPY etc_dojo.d/variables/* /etc/dojo.d/variables/

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
