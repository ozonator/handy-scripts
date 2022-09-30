#!/bin/bash
# sync script to backup main docs folder to (encrypted & mounted) USB drive
# useful for putting critical items on a flash drive (i.e., not a full backup, but suited to lower capacity storage)

# assume $HOME is inherited from the shell
HOST=`hostname -s`
RSYNC=`which rsync`

# volume name on the destination drive (change as needed)
USBDRIVE=flashdrive

### rsync options
## -N and --fileflags require rsync that supports crtimes and fileflags (not default on Mac)
RSYNC_OPTS="-auvPNXAH --fileflags --progress --delete --delete-during"

$RSYNC $RSYNC_OPTS ~/Documents /Volumes/$USBDRIVE
$RSYNC $RSYNC_OPTS ~/Downloads /Volumes/$USBDRIVE
$RSYNC $RSYNC_OPTS ~/Library/Keychains /Volumes/$USBDRIVE

echo "Unmounting drive..."
diskutil unmount /Volumes/$USBDRIVE
