all: shell image

shell: shell.pas
	fpc -dKLIB -dRELEASE $^

image: Dockerfile shell
	docker build -t samba:latest .

run:
	docker run -it samba:latest
