# rip_floppy
A simple shell script to batch rip floppies in MacOS.

I needed something to rip a whole bunch of disks I had to disk images before they were lost to time forever.  I imagine someone else might need this as well, so that's why I'm putting it up on GitHub.

# what it is
It just rips the disk present in the specified floppy device (1.44m DS/HD) to a .dmg file that can be mounted and read natively in MacOS.  When it's done, it'll prompt for another disk until you CTRL-C out of it.

If the disk is empty, no image will be created and you'll be prompted for a new disk.

A disk image with the name `<disk label>-<epoch time>.dmg` will be created.  If there is no disk label or the label is "NO NAME" it will default to `floppy-<epoch time>.dmg>`.

# features
* Automatic - Automatically detects disk insertion and removal.
* Fast - Takes about 65 seconds to rip a 1.44MB DS/HD disk without errors.
* Safe operation - Utilizes DD, will attempt to read bad sectors and pad out with 00s if they cannot be read, making data recovery easier.
* Saves time - Skips blank disks.  No one needs images of blank disks.
* Smart[ish] - Accounts for MacOS junk files and won't rip if the disk is otherwise blank.  I think.
* Get more done - Made for batch ripping, just keeps going until you Control+C.

# usage
Needs to be run as sudo, since the script requires direct disk access.

```
sudo ./rip_floppy.sh /dev/disk#
```
Where # is the disk number of your floppy drive (Can be found in Disk Utility)

# warning

If you put in the wrong device name, you might end up ripping the wrong thing.  So like, don't do that.  No warranties.
