# PHP 5.6.40 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/php/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/php/)
  - Maintainer: -

"*PHP is a widely-used general-purpose scripting language that is
especially suited for Web development and can be embedded into HTML.*"

### Memory usage

It works, but it needs a lot of memory, so a swap file is advisable
(about 32 MB will do in most cases).

```
-rwxr-xr-x    1 root     root       5036004 Apr 25 18:41 php-cgi
```

```
VmPeak:    10740 kB
VmSize:    10740 kB The size of the virtual memory allocated to the process
VmRSS:      3068 kB The amount of memory mapped in RAM ( instead of swapped out )
```

This is why [fast-CGI](http://www.fastcgi.com/) is
better too: instead of loading the PHP binary over and over again it
stays in memory, also giving the system the opportunity to swap out
unused parts of it.

Another thing is that *php.ini* will use valuable flash space and is
quite big. A solution is to make a symbolic link to an USB storage
device:

```
cp /tmp/flash/php.ini /var/media/ftp/uFlash/hiawatha/php.ini
rm /tmp/flash/php.ini
ln -s /var/media/ftp/uFlash/hiawatha/php.ini /tmp/flash/php.ini
modsave
```

### Weiterführende Links

-   [Home page](http://www.php.net/)
-   [PHP Tutorial](http://www.w3schools.com/php/)
