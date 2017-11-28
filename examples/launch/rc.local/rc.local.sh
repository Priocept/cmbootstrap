# example code to download and launch cmbootstrap - place fetch-cmbootstrap in
# /usr/local/bin and then copy the code below to /etc/rc.d/rc.local or equivalent

# download and execute cmbootstrap
/usr/local/bin/fetch-cmbootstrap >"/var/log/fetch-cmbootstrap.log" 2>"/var/log/fetch-cmbootstrap.log"
if [ -x /usr/local/bin/cmbootstrap ]; then
    /usr/local/bin/cmbootstrap
fi
