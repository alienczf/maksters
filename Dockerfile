FROM centos:latest

# ------------------------------------------------------------------------------
# Arguments
# ------------------------------------------------------------------------------
ARG rev="000000"
# Default to start of unix epoch
ARG date="1970-01-01 00:00:00Z"
# ------------------------------------------------------------------------------
# Build starts here
# ------------------------------------------------------------------------------
USER root

# add repos
COPY ./*.repo /etc/yum.repos.d/
# hadolint ignore=DL3031,DL3033
RUN yum -y install epel-release yum-utils sudo
RUN yum-config-manager --enable powertools
RUN yum -y --setopt=tsflags=nodocs update
RUN yum -y install \
	  google-cloud-sdk \
	  openssl-devel \
	  git \
	  git-lfs \
	  unzip \
	  wget \
	  vim \
      cmake \
      gdb \
      clang \
      lldb \
      lld \
      make \
      ninja-build \
      protobuf-devel \
      protobuf-compiler \
      boost-devel \
      python3-devel

# This user runs sshd, has sudo access for basic bootstrap of containers
ENV UID 7999
RUN groupadd sudo && \
	useradd -rm -d /home/centos -s /bin/bash -G wheel -l -u ${UID} centos && \
    echo "centos:centos" | chpasswd

# setup pyenv (less likely to change stuffs)
RUN mkdir -p /home/centos/maksters
WORKDIR /home/centos/maksters
COPY requirements.txt ./
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir -r ./requirements.txt

# build and install
COPY . /home/centos/maksters
RUN chown -R ${UID} /home/centos/maksters

USER ${UID}
WORKDIR /home/centos/maksters

# Default to running example
ENTRYPOINT ["bash"]
