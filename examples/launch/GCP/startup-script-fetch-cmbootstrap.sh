#!/bin/sh

# Google Cloud Platform startup script for launching cmbootstrap.
# Assumes CentOS based base image.
# ------------------------------------------------------------------------------

CMBOOTSTRAP_NAME="cmbootstrap"
CMBOOTSTRAP_FILENAME="/usr/local/bin/$CMBOOTSTRAP_NAME"
CMBOOTSTRAP_GIT_PATH="https://github.com/Priocept/cmbootstrap/raw/master/$CMBOOTSTRAP_NAME"
LOG_FILE="/var/log/fetch-cmbootstrap.log"
ERR_FILE="/var/log/fetch-cmbootstrap.err"
WGET_FILE="/var/log/fetch-cmbootstrap.wget"
GCE_METADATA_URL="http://metadata/computeMetadata/v1/instance"
GCE_METADATA_HEADER='Metadata-Flavor: Google'

# generate escaped version and terminate if called with "-e" option
if [ "$1" == "-e" ]; then
    sed -e 's/\\/\\\\/g' "$0" | sed 's/\"/\\"/g' | sed -n -e 'H;${x;s/\n/\\n/g;p;}' > "$0.escaped"
    exit 0
fi

echo "Starting cmbootstrap download and execution..." > "$LOG_FILE"

# label instance as downloading cmbootstrap
gcp_instance_name=$(curl --fail --header "$GCE_METADATA_HEADER" "$GCE_METADATA_URL/hostname" 2>/dev/null  | cut -d. -f1)
gcp_zone=$(curl --fail --header "$GCE_METADATA_HEADER" "$GCE_METADATA_URL/zone" 2>/dev/null  | cut -d. -f1)
if [ ! -z "$gcp_instance_name" ] && [ ! -z "$gcp_zone" ]; then
    gcloud compute instances add-labels "$gcp_instance_name" --zone="$gcp_zone" --labels="cmbootstrap-downloading=" >> "$LOG_FILE" 2>&1
fi

# attempt download of latest cmbootstrap version
echo "Installing wget..." >> "$LOG_FILE"
yum_params=( '--assumeyes' '--disableplugin=fastestmirror' )
yum "${yum_params[@]}" install wget > "$WGET_FILE" 2>&1
if [ "$?" -ne 0 ]; then
    # retry a second time if wget install failed
    echo "Installation of wget failed, retrying..." >> "$LOG_FILE"
    sleep 10
    yum "${yum_params[@]}" install wget > "$WGET_FILE" 2>&1
    if [ "$?" -ne 0 ]; then
        echo "Error installing wget." > "$ERR_FILE"
        exit 1
    fi
fi
echo "Downloading cmbootstrap from '$CMBOOTSTRAP_GIT_PATH'..." >> "$LOG_FILE"
wget --output-document="$CMBOOTSTRAP_FILENAME.download" "$CMBOOTSTRAP_GIT_PATH" >> "$WGET_FILE" 2>&1
if [ "$?" -ne 0 ]; then
    # retry a second time if cmbootstrap download failed
    echo "Download of cmbootstrap failed, retrying..." >> "$LOG_FILE"
    sleep 10
    wget --output-document="$CMBOOTSTRAP_FILENAME.download" "$CMBOOTSTRAP_GIT_PATH" >> "$WGET_FILE" 2>&1
    if [ "$?" -ne 0 ]; then
        # if download failed again, check for previous version
        if [ -f "$CMBOOTSTRAP_FILENAME" ]; then
            echo "Download failed, using existing file at '$CMBOOTSTRAP_FILENAME'." >> "$LOG_FILE"
        else
            echo "Error downloading cmbootstrap, no previous file available." > "$ERR_FILE"
            exit 2
        fi
    fi
else
    mv "$CMBOOTSTRAP_FILENAME.download" "$CMBOOTSTRAP_FILENAME"
fi
chmod +x "$CMBOOTSTRAP_FILENAME"

# remove downloading label - cmbootstrap will perform subsequent labeling
if [ ! -z "$gcp_instance_name" ] && [ ! -z "$gcp_zone" ]; then
    gcloud compute instances remove-labels "$gcp_instance_name" --zone="$gcp_zone" --labels="cmbootstrap-downloading" >> "$LOG_FILE" 2>&1
fi

# execute configuration management bootstrap
echo "Executing cmbootstrap..." >> "$LOG_FILE"
/usr/local/bin/cmbootstrap
if [ "$?" -ne 0 ]; then
    echo "Error executing cmbootstrap." > "$ERR_FILE"
    exit 3
fi
echo "Execution of cmbootstrap completed successfully." >> "$LOG_FILE"
