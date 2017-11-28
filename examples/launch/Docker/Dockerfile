# ------------------------------------------------------------------------------
# Example Dockerfile for creating a Docker based CentOS environment, with
# configuration management based on cmbootstrap.
# ------------------------------------------------------------------------------

FROM centos

MAINTAINER Priocept <support@priocept.com>

# configure the following lines to define the configuration management metadata
ENV \
    CM_VCS_REPO_BASE=https://github.com/<repo_path> \
    CM_VCS_REPO_TYPE=Git \
    CM_VCS_USERNAME=<username> \
    CM_VCS_PASSWORD=<password> \
    CM_ORGANIZATION=<organization> \
    CM_PROJECT=<project> \
    CM_TYPE=<type> \
    # the following metadata values are also required if not pre-configured in cmbootstrap.cfg
    CM_VCS_REPO_BASE=https://github.com/<repo_path> \
    CM_VCS_REPO_TYPE=Git
    # optional additional configuration metadata
    #CM_VCS_REVISION= \
    #CM_ARGS=name1=value1;name2=value2 \

# download cmbootstrap into the Docker container
RUN yum -y install wget \
    2>/dev/null \
    && \
    wget \
    --directory-prefix=/usr/local/bin \
    https://github.com/Priocept/cmbootstrap/raw/master/cmbootstrap
    2>/dev/null \
    && \
    chmod +x /usr/local/bin/cmbootstrap

#  execute cmbootstrap to start the configuration management process
RUN /usr/local/bin/cmbootstrap -
