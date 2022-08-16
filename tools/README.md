## curl_x64_static

~~~
cd /tmp/
git clone https://github.com/curl/curl.git
cd curl
git checkout <tag-version>
autoreconf -fi

# gcc is apparantly incapable of building a static binary, even gcc -static helloworld.c ends up linked to libc, instead of solving, use clang
export CC=clang

LDFLAGS="-static" PKG_CONFIG="pkg-config --static" ./configure --disable-shared --enable-static --disable-ldap --enable-ipv6 --enable-unix-sockets --with-openssl --enable-ares
make -j14 V=1 LDFLAGS="-static -all-static"
strip src/curl
~~~

test 1: `file src/curl`

~~~
src/curl: ELF 64-bit LSB executable, x86-64, version 1 (GNU/Linux), statically linked, for GNU/Linux 3.2.0, BuildID[sha1]=88e042a04e9326ec7d8669d8c17b457c6679ecfa, with debug_info, not stripped

-> must be: "statically linked"
~~~

test 2: `ldd src/curl`
~~~
	not a dynamic executable    <- important
~~~

finish: `cp src/curl -> <extendrom path>/tools/curl_x64_static`
