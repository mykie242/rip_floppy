# rip_floppy
A simple shell script to batch rip floppies in MacOS

# what it is
It just rips the disk present in the specified floppy device (1.44m DS/HD) to a .dmg file that can be mounted and read natively in MacOS.  When it's done, it'll prompt for another disk until you CTRL-C out of it.

If the disk is empty, no image will be created and you'll be prompted for a new disk.

A disk image with the name `<disk label>-<epoch time>.dmg` will be created.  If there is no disk label or the label is "NO NAME" it will default to `floppy-<epoch time>.dmg>`.

# features
* Automatically detects disk insertion and removal.
* Utilizes DD, will attempt to read bad sectors and pad out with 00s if they cannot be read, making data recovery easier.
* Skips blank disks.  No one needs images of blank disks.
* Runs `dot_clean` on the disk to prevent MacOS junk from accumulating.
* Made for batch ripping, just keeps going until you Control+C.

# usage
```
sudo ./rip_floppy.sh /dev/disk#
```
Where # is the disk number of your floppy drive (Can be found in Disk Utility))
