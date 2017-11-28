#!/bin/sh

# Amazon EC2 User Data script for launching cmbootstrap.
# ------------------------------------------------------------------------------

# cmbootstrap configuration metadata - as an alternative to using EC2 tags,
# metadata can be defined directly in this file, using metadata names with
# underscores (_) rather than hyphens (-).
# ------------------------------------------------------------------------------

#cm_company=<organization>
#cm_project=<project>
#cm_type=<type>

# the following cmbootstrap metadata is typically specified in this file rather
# than via EC2 tags, since it is usually common across all instances
# ------------------------------------------------------------------------------

#cm_vcs_repo_base='https://github.com/<repo_path>'
#cm_vcs_repo_type='Git'
#cm_vcs_username='<username>'
#cm_vcs_password='<password>'

# cmbootstrap download and execution - normally does not need editing
# ------------------------------------------------------------------------------

CMBOOTSTRAP_GIT_PATH="https://github.com/Priocept/cmbootstrap/raw/master/cmbootstrap"

cmbootstrap_install_dir=/usr/local/bin
cmbootstrap_download_log=/tmp/cmbootstrap-download.log
wget \
    --directory-prefix="$cmbootstrap_install_dir" \
    "$CMBOOTSTRAP_GIT_PATH" 2>&1
chmod +x "$cmbootstrap_install_dir/cmbootstrap"

# execute configuration management bootstrap
/usr/local/bin/cmbootstrap
