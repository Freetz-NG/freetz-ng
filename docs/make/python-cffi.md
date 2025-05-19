# Cffi 1.15.1
 - Homepage: [https://cffi.readthedocs.io](https://cffi.readthedocs.io)
 - Manpage: [https://cffi.readthedocs.io/en/stable/overview.html](https://cffi.readthedocs.io/en/stable/overview.html)
 - Changelog: [https://github.com/python-cffi/cffi/releases](https://github.com/python-cffi/cffi/releases)
 - Repository: [https://github.com/python-cffi/cffi](https://github.com/python-cffi/cffi)
 - Package: [master/make/pkgs/python-cffi/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/python-cffi/)
 - Maintainer: -

Add **python-cffi**, a Foreign Function Interface package for calling C libraries from Python.

------------------------------------------------------

## Installation notes

Python shall be externalized on Freetz-NG.

After the system build, before using *cffi*, you also need *curl*, *pip*, *pycparser*.

To install *pip* on Freetz-NG:

```
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
python get-pip.py --user
python -m pip install --user -r requirements.txt
```

To install the *pycparser* Python module:

```
python -m pip install pycparser
```

## Usage notes

The `ffibuilder.compile()` method of the *cffi* module will not work because Freetz-NG does not include a compiler. To overcome this issue, in a temporary directory of the build system create a file named `mips-linux-uclibc-gcc.c` including this code.

```c

int main(int argc, char *argv[]) {
    printf("\n------ Executed command:\n");
    for (int i = 0; i < argc; i++) {
      if (i > 0) printf(" ");
        printf("%s", argv[i]);
    }
    printf("\n");
    printf("------ (end)\n\n");
    return 0;
}
```

Cross-compile it (on the build system):

```
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -I/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/include/python2.7 mips-linux-uclibc-gcc.c -o mips-linux-uclibc-gcc
```

Move the obtained executable code to Freetz-NG:

```
mkdir -p /home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/
mv mips-linux-uclibc-gcc /home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc
```

Then, after running `ffibuilder.compile()`, you need to move the created files to the build system and execute the commands shown by the above program.

To each, command, you shoud add:

```
-I/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/include/python2.7
```

The obtained shared object shall be moved back to Freetz-NG and imported in Python.

------------------

Example using [API Mode, calling C sources instead of a compiled library](https://cffi.readthedocs.io/en/stable/overview.html#api-mode-calling-c-sources-instead-of-a-compiled-library):

- create *pi.c* following instructions
- create *pi.h* following instructions
- create *pi_extension_build.py* following instructions
- Build the extension following instructions.

Obtained printout:

```
>>> ffibuilder.compile(verbose=True)
generating ./_pi.c
(already up-to-date)
the current directory is '/var/media/myfreetz'
running build_ext
building '_pi' extension
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -c _pi.c -o ./_pi.o

------ Executed command:
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -c _pi.c -o ./_pi.o
------ (end)

/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -c pi.c -o ./pi.o

------ Executed command:
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -c pi.c -o ./pi.o
------ (end)

/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -shared ./_pi.o ./pi.o -L/usr/lib -lm -lpython2.7 -o ./_pi.so

------ Executed command:
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -shared ./_pi.o ./pi.o -L/usr/lib -lm -lpython2.7 -o ./_pi.so
------ (end)

'/var/media/myfreetz/_pi.so'

```

Move `pi.c`, `_pi.c`, `pi.h` to a temporary directory of the build system.

On the build system, run the cross-compiler basing on the above istructions:

```
/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -I/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/include/python2.7 -c _pi.c -o ./_pi.o

/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -c pi.c -o ./pi.o

/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/bin/mips-linux-uclibc-gcc -fno-strict-aliasing -march=34kc -mtune=34kc -msoft-float -Ofast -pipe -Wa,--trap -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wl,-I/usr/lib/freetz/ld-uClibc.so.1 -DNDEBUG -fno-inline -fPIC -I/usr/include/python2.7 -I/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/include/python2.7 -c _pi.c -o ./_pi.o
```

Notice the addition of `-I/home/$USER/freetz-ng/toolchain/build/mips_gcc-13.3.0_uClibc-1.0.52-nptl_kernel-4.9/mips-linux-uclibc/include/python2.7`.

Move *_pi.so* to Freetz-NG.

The following [Python program](https://cffi.readthedocs.io/en/stable/overview.html#api-mode-calling-c-sources-instead-of-a-compiled-library) will run without errors.

```python
from _pi.lib import pi_approx
approx = pi_approx(10)
assert str(approx).startswith("3.")

approx = pi_approx(10000)
assert str(approx).startswith("3.1")
```
