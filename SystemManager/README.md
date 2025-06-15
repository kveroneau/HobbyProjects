# System Manager

Into Retro Systems like I am?  Do you run Linux?  Wanna really make use of the **Btrfs** file system?
Well, you came to the right place on the wide wide Internet, as luck has it, *System Manager* is the
program you desparately need in your day-to-day Retro Computing life!

## Key Features of System Manager:

  * Fast! Efficient!
    * The first priority of this program for me was for it to be fast and very efficient.
  * Uses the Btrfs file system
    * Using the amazing *copy-on-write* technology, you can create an almost infinite amount of virtual
      retro computers in mere seconds, all of which will take a fraction of storage space!
  * Create an Instant-on Template Library
    * Is there ever a time you just wanted to have a cleanly installed and configured retro operating
      system up with as little fuss as possible?  Look no further than *System Manager*!
    * Place a directory of system templates on your Btrfs file system, and you'll be-able to spin them
      up in seconds!
  * System lists are all stored as easy to edit CSV files
  * Create systems as fast as you can use a spreadsheet!
    * No, really, that is entirely how this program operates!  If you can use a spreadsheet, you can
      use *System Manager*!
  * Currently manages local 86Box, and libvirt Virtual systems, and remote LXC containers via libvirt.
  * Can effortlessly manage your VDE network, including accessing remote switches over SSH.

## Basic usage instructions:

Firstly, you will require Linux and have a working Btrfs file system at your disposal.  If you merely want to
just try it out, you can easily create a Btrfs file system via a loopback device, although for better
performance, you really should have your Btrfs backed by a real block device.  Below are the currently
hardcoded paths which you will need, some of these you may need to manually update.  If there is any
interest in anyone but myself using this tool, then I will update the source code to use **constants** which
can then be updated before a build to set up these various paths according to your specific needs, but for now,
these are the paths which you will need to have available unless the source code is updated:

  * `/home/kveroneau/VMs/` *optional*
    - In this directory are exported libvirt domain XML definitions, not needed if VMs are already defined.
  * `/btrfs/Boxes/`
    - Here is where all the 86Boxes are created and managed.
  * `/btrfs/Library/` *optional*
    - Doesn't need to be in Btrfs, and optionally contains a library of software, .img, .86f, .vhd, .iso, etc...
  * `/btrfs/Boxes/.templates/` *optional, but very desired*
    - This directory will have many Btrfs subvolumes ready to be snapshotted as a new 86Box to use.
  * `/btrfs/Boxes/.sysmgr/`
    - Directory which will hold your *System Lists* and the journals for each of those lists.

It is highly recommended to run this program as your own user account, and to `chown` the above directories so
that your user can use the needed `btrfs` commands to create snapshots and perform other required activities
during the normal operation of the program.  In fact, if any of these directories cannot be accessed by
your running user account, I am not sure this program will operate as intended.

### The System List

After compiling and running the application, one of the main parts you will be mostly working with is the
grid, which will look and operate like a spreadsheet, where you are able to update any of the cells at
any point by clicking into them and modifying the cell itself.  The contents of the Title and the Box Path
are very important, the other 2 middle cells are more or less optional, but also very informative.  The
Title column is used to populate a few other parts of the form, so in order to have a consistent form view,
be sure to always enter in a Title here.  The Box Path is the most interesting, so please do pay a bit of
attention to the following.  The text in this cell if not prefixed by a special operator creates the final
part to a path to your 86Box, eg, if you place `Fedora` in the Box Path, then the 86Box will be located at
`/btrfs/Boxes/Fedora/86Box.cfg`.  If you already have an existing Fedora installation in 86Box you'd like
to manage by this system, importing your Box is frankly really easy.  First `btrfs subvolume create /btrfs/Boxes/Fedora`,
then copy your existing 86Box directory you were already using into there, then in the grid, put `Fedora`
into the Box Path cell, then there you go, you can now launch this 86Box effortlessly from within
*System Manager*.  Now, here is where it gets a bit more interesting...  So, say you entered in a path
to a box that doesn't currently exist, what will happen?  Well, if you select a template from the
drop-downs, then a `btrfs subvolume snapshot` will be performed automatically, taking a snapshot of the
template you choose into the `/btrfs/Boxes/Fedora` directory, allowing you to easily spin up any box
you've already installed at least once and built a template for.  Easy!  Now, what if you also want to
manage local KVMs via System Manager and utilize the more advanced features of Linux and connect your
Fedora 86Box to an Ubuntu KVM?  This can be easily done as well, although, currently the system does
only support installing some Debians from it, it isn't too difficult to add an option for say Ubuntu,
All you need to do though, is prefix a `!` to the beginning of the box path, eg. `!Ubuntu`, this will
cause the *System Manager* to use the libvirt tools to check if this KVM exists, and to start it if
it does, and if it doesn't exist, it will bring up a dialog box with a few very easy to select options
to effortlessly install an OS into a KVM with as minimal effort as I could humanly put into a software
program.  It is incredibly simple to create a brand-new install of Debian currently via KVM here.  The
final *secret* operation of the Box Path is to start and connect to a remote LXC, currently the hostname
is statically set in the source code to `pi4`, which is fairly easy to update and point to a different
remote server, or even update to say use a local LXC on your local machine instead.  But the point is
that you can start and connect to an LXC console using the libvirt tools using *System Manager*.

## Eventual upcoming features:

A short list of features which I am planning to implement in the future as this tool is developed
further.

  * Cloning of KVMs using the libvirt tools
    - This will not require the disks to be on a Btrfs, it will use native KVM features instead.
  * Ability to open non-GUI KVMs consoles
    - It is fully possible to not install any video output device in a KVM, and instead use ttyS0.
  * Native support for local LXCs, and not just remote LXCs.
  * Potential Docker image and container support, along with networking it effortlessly with VDE.
  * An advanced networking patch bay tool, allowing very complex networks to be created fast.
  * Easy image conversions with a nice front-end to `qemu-img convert`.
    - This would say allow a **.VHD** to be easily converted to say a **.QCOW2** and back.
    - Allows images to be shared between various emulators and virtualizers.
