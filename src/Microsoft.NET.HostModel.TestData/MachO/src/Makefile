all: buildonly unsigned signed buildonly_x64 signed_x64 unsigned_x64

buildonly:
	clang main.c -o ../a.out

signed:
	clang main.c -o ../a.signed.out
	codesign --sign - ../a.signed.out

unsigned:
	clang main.c -o ../a.unsigned.out
	codesign --remove-signature ../a.unsigned.out

buildonly_x64:
	clang main.c -o ../a.x64.out -arch x86_64

signed_x64:
	clang main.c -o ../a.signed.x64.out -arch x86_64
	codesign --sign - ../a.signed.x64.out

unsigned_x64:
	clang main.c -o ../a.unsigned.x64.out -arch x86_64
	codesign --remove-signature ../a.unsigned.x64.out
