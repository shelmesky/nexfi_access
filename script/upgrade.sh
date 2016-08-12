#!/bin/sh
SERVER_PATH="http://download.nexfi.cn:8000"
# configuration version file name
CONF_VERSION="conf_version"
# configuration version file path
LOCAL_PATH="/root"
# md5 file name
MD5SUMS="md5sums"
DOWNLOAD_PATH=/tmp
# remove previous version configuration file.
rm -f $DOWNLOAD_PATH/$CONF_VERSION
# download version configuration file from server.
wget -c -P $DOWNLOAD_PATH $SERVER_PATH/$CONF_VERSION

if [ ! -f $DOWNLOAD_PATH/$CONF_VERSION ]
then
    echo "Download version configuration file : $CONF_VERSION failed."
    exit
fi

# major version number of download configuration file.
major=`awk -F":" '{if ($1=="Major_Version_Number") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`
# minor version number of download configuration file.
minor=`awk -F":" '{if ($1=="Minor_Version_Number") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`
# reversion number of download configuration file.
rever=`awk -F":" '{if ($1=="Reversion_Number") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`

firm_name=`awk -F":" '{if ($1=="File_Name") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`
build_num=`awk -F":" '{if ($1=="Build_Number") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`
date_num=`awk -F":" '{if ($1=="Date_Number") print $2}' $DOWNLOAD_PATH/$CONF_VERSION`

# configuration file version number compare function.
version_gt() { test "$(echo "$@" | tr -s " " "\n" | sort -n | head -n 1)" != "$1"; }
version_le() { test "$(echo "$@" | tr -s " " "\n" | sort -n | head -n 1)" == "$1"; }
version_lt() { test "$(echo "$@" | tr -s " " "\n" | sort -nr | head -n 1)" != "$1"; }
version_ge() { test "$(echo "$@" | tr -s " " "\n" | sort -nr | head -n 1)" == "$1"; }

# if local version configuration file not exist.
# local major minor Re. version number.
lmajor=""
lminor=""
lrever=""
if [ -f $LOCAL_PATH/$CONF_VERSION ]
then
    lmajor=`awk -F":" '{if ($1=="Major_Version_Number") print $2}' $LOCAL_PATH/$CONF_VERSION`
    lminor=`awk -F":" '{if ($1=="Minor_Version_Number") print $2}' $LOCAL_PATH/$CONF_VERSION`
    lrever=`awk -F":" '{if ($1=="Reversion_Number") print $2}' $LOCAL_PATH/$CONF_VERSION`
fi

if [ ! -f $LOCAL_PATH/$CONF_VERSION ] || version_gt "$major.$minor.$rever" "$lmajor.$lminor.$lrever"
then
    rm -f $DOWNLOAD_PATH/$MD5SUMS
    wget -c -P $DOWNLOAD_PATH $SERVER_PATH/$MD5SUMS
    if [ ! -f $DOWNLOAD_PATH/$MD5SUMS ]
    then
        echo "$DOWNLOAD_PATH/$MD5SUMS download failed."
        exit 
    fi
    
    # download openwrt firm file.
    
    openwrt_file=$firm_name-$major-$minor-$rever-$build_num-$date_num.bin
    rm -f "$DOWNLOAD_PATH/$firm_name-\*"
    #echo "$DOWNLOAD_PATH/$firm_name-*"
    wget -c -P $DOWNLOAD_PATH $SERVER_PATH/$openwrt_file
    if [ ! -f $DOWNLOAD_PATH/$openwrt_file ]
    then
        echo "$DOWNLOAD_PATH/$openwrt_file download failed."
        exit
    fi

    # MD5 verification
    
    cd /tmp
    md5sum -c -s $MD5SUMS
    if [ $? == 0 ]
    then
        cp $DOWNLOAD_PATH/$CONF_VERSION $LOCAL_PATH/$CONF_VERSION
        sysupgrade -v $DOWNLOAD_PATH/$openwrt_file
        echo "starting to upgrate $DOWNLOAD_PATH/$openwr_file."
    else
	echo "md5sum varification failed."
    fi
fi
