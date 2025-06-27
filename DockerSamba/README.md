# Samba inside Docker

The main purpose of this Docker image is to assist with using Windows File Sharing with retro computer systems.  It is possible to connect isolated retro networks to an isolated docker network, allowing older operating systems and network clients such as LAN Manager to share files with a modern file sharing server on your host inside Docker.  I also included a very short Pascal program which can be compiled easily using the FreePascal compiler, available on almost every distro with a small installation size, and minimal effort to build, and included a basic Makefile to assist with both the building of this shell, and the docker image.  It is trivial to remove this Pascal script, but you will also lose out on it's benefits, as it does auto-start the Samba services, and provides an easy shell interface is you start the container in *interactive mode* to create and manage samba users, as well as updating the samba configuration itself.

Using it is really easy, just install the FreePascal compiler on your distro, and also get a copy of my [klib](https://github.com/kveroneau/klib) as it uses a unit from my Pascal library.  You will also either need to update your `fpc.cfg` with a similar line:

```
#IFDEF KLIB
-Fu~/Projects/klib/lib/x86_64-linux
#ENDIF
```

Or you can update the `Makefile` with `-Fu<Location of downloaded klib>`.

Finally, if all that is too much for you to configure, you can also just download both `kexec.pas` and `ksignals.pas` from my klib mentioned above and place them inside this directory here, and run the compile.

To use the Docker image, it is recommended that you create a new Docker network to say connect with a local *taptun* device using Docker's *macvlan* support, then start the container with that as your network.  Then, connect any retro systems to this tap device using for example VDE, and you'll be-able to use classic file sharing in your older systems, allowing them to all share files like it's the 80s, 90s, or early 2000s.

To support very old retro operating systems, you will need to use the `config` tool in the image to update the `smb.conf`, or you can also make this change before building your image, if you'd prefer this samba always be enabled for older operating systems.  This is done on lines 77-80:

```
# Enables older versions of both DOS and Windows to connect.
#   server min protocol = NT1
#   lanman auth = yes
#   ntlm auth = yes
```

Just uncomment these lines to enable clients all the way from LAN Manager on MS-DOS to easily connect.  You can also reference the [smb.conf](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) man page for further information on these settings.
