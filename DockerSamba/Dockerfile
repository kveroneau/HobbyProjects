FROM debian:bookworm

RUN apt-get update && apt-get install -y samba nano

VOLUME /srv

COPY smb.conf /etc/samba/smb.conf
COPY shell /usr/bin/shell

ENTRYPOINT ["/usr/bin/shell"]
