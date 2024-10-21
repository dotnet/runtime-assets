all: buildonly unsigned signed

buildonly:
	clang main.c -o ../a.out

signed:
	clang main.c -o ../a.signed.out
	codesign --sign - ../a.signed.out

unsigned:
	clang main.c -o ../a.unsigned.out
	codesign --remove-signature ../a.unsigned.out
