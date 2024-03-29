#!/bin/bash
# backup script for a Pi -- packages, /etc/, and /home/pi, as well as service configs for homebridge and pihole
# version: 20220312
#
# Requires: tar, rclone -- https://rclone.org
# Optional: age (for additional encryption) - https://github.com/FiloSottile/age
#
# WARNING: this script assumes this is a secure device used by a single user
# It could be made more secure on a multi-user machine -- revise as needed for your own use:
# -- set something other than /tmp to store backup files
# -- secure your rclone.conf
# -- secure your age keyfile

# assumptions:
# -- this will run on a Raspberry Pi running the Raspberry Pi OS - not tested on other OSes
# -- anything worth saving in /home is in /home/pi (change this for a multi-user pi)
# -- pihole and homebridge, if present, are default installations
# -- rclone is installed and configured already, including with 'crypt' if preferred
# -- (optional) for age: unencrypted age keypair is saved at /usr/local/lib/backupkey.txt
#    (not in the backed up paths, so it won't be sent to the cloud - must be backed up separately)

#### configuration

# get the hostname, so backup files can be named accordingly
HOST=`hostname -s`

# for date-stamping backup files
DATE=`date -I`

# set the directory in which to build the backup files
# could be anything to which the backup user has write access, with enough space available
# to reduce wear on the flash card when making archives, I use /tmp, which is mounted as tmpfs
BDIR=/tmp/$HOST-backup

# set the rclone remotes: these could be the same
# -- encryption refers to whether the backup files are encrypted with age before being copied
# -- the remote itself could be encrypted (e.g., if configured with https://rclone.org/crypt/)

# remote for unencrypted backupg files
UREMOTE=gdrive-crypt:$HOST/
# remote for encrypted backup files
# (can be the same as the unencrypted remote)
EREMOTE=gdrive-crypt:$HOST/

# age key file
KEYFILE=/usr/local/lib/backupkey.txt

# set the basic options for creating tar files - 'J' uses xz compression
TAROPTS="-cJf"

# options for what to include or exclude from home directories
# adjust as needed
TARHOMEXCLUDE=" --exclude=src/packages --exclude=.cache"
TARHOME=" /home/pi"

#### end configuration

## usage check - it's pretty simple

USAGE="usage: pibu <r|e> (regular or encrypted)"

if [ $# -ne 1 ]; then
  echo $USAGE
  exit 1;
fi

## end usage check

# remove the previous backup, if it's still there
if [ -d $BDIR ]; then
	rm -rf $BDIR
fi

# (re)create the directory for the backup files
mkdir $BDIR

### backup package selections

echo "System package selections..."
dpkg --get-selections > $BDIR/$HOST-packages.list

# compress the list of installed packages
# for portability: xz should be available, but use gzip if not
if hash xz 2>/dev/null; then
	xz $BDIR/$HOST-packages.list
else
	gzip $BDIR/$HOST-packages.list
fi 

# consider: copying /etc/apt/sources.list* and 'apt-key exportall' separately
# not critical if using the stock apt repositories in Raspberry Pi OS

# also: keep a list of locally-installed packages
ls -1 /usr/local/bin > $BDIR/$HOST-localbin.txt

### backup /etc
# /etc includes configs for pihole, pivpn, wireguard, etc.
# since /etc/pihole contains (large) blocklists that don't need to be backed up,
# the pihole config is handled separately

if [ -d /etc/pihole ]; then
	echo "Pihole..."
	EXCLUDE=' --exclude=/etc/pihole'
	pushd $BDIR
	pihole -a -t
	popd
else
	EXCLUDE=""
fi

echo "System configuration (/etc)..."
sudo tar $TAROPTS $BDIR/$HOST-etc.tar.xz $EXCLUDE /etc

### backup homebridge configs and state (not logs)

if [ -d /var/lib/homebridge ]; then
	echo "Homebridge configuration..."
	sudo tar $TAROPTS $BDIR/$HOST-homebridge.tar.xz /var/lib/homebridge
fi

### backup home diretories - everything other than downloaded source and package files
# modify this section as needed, e.g., to change the exclude, add other home directories, etc.

echo "Home directories..."
sudo tar $TARHOMEXCLUDE $TAROPTS $BDIR/$HOST-home.tar.xz $TARHOME

### copy backup files to cloud storage

echo "Copying to cloud storage..."

case "$1" in
r)
	# don't pre-encrypt the backup files
	# if the remote is encrypted with rclone crypt, the backup will still be encrypted
	rclone copy $BDIR $UREMOTE
	# rclone delete $UREMOTE --min-age 30d
	;;
e)
	# encrypt files with age, if it's available (it's not in the Pi repos pre-bullseye)
	# if the remote is not encrypted, files will still be encrypted once
	if hash age 2>/dev/null; then
		echo "  encrypting..."
		for FILE in $BDIR/$HOST-*; do
			age -e -i $KEYFILE -o $FILE.age $FILE
			rm -f $FILE
		done
	fi
	echo "  uploading..."
	rclone copy $BDIR $EREMOTE
	# rclone delete #EREMOTE --min-age 30d
	;;
esac

# remove the backup files, now that they're copied
rm -rf $BDIR

exit 0
