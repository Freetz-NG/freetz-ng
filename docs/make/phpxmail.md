# PHPXmail 1.5 - DEPRECATED
  - Package: [master/make/pkgs/phpxmail/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/phpxmail/)
  - Maintainer: -

The mail to/from my hosting provider got interrupted now and then and
the support wasn't that good. Setting up a mail server using Freetz and
PHPXMail was very simple. Now I can select my own blocklists and see in
the logs what is (not) happening.

### Basic setup guide

1.  To prevent disappointment: check if your internet provider allows
    SMTP (port 25) traffic
2.  Build and install Freetz with PHPXMail and
    [AVM-firewall-cgi](avm-firewall.md)
    1.  PHPXMail selects XMail and PHP
    2.  Be prepared for the space requirements ...
3.  Setup Firewall (Freetz menu Packages > AVM-Firewall)
    1.  Select port forwarding
    2.  Forward TCP port 25 to Fritz!Box port 10025 (SMTP)
    3.  Forward TCP port 110 to Fritz!Box port 10110 (POP3)
    4.  Apply settings
    5.  Reboot
4.  Setup XMail (Freetz menu Packages > XMail)
    1.  Set start type to automatic
    2.  Fill in a **existing** directory for settings & storage, for
        example

        ``` 
        /var/media/ftp/uStor01/XMail
        ```

5.  Activate SMTP & POP3
6.  Activate unencrypted admin access
7.  Activate all logging for the time being
8.  Apply
9.  Start XMail (freetz menu Services > XMail > Start)
10. Change the user name of the web interface to set XMail password
    (Freetz menu Settings > webcfg > change password)
11. Open PHPXMail configuration site (Freetz menu Packages >
    PHPXMail > here)
    1.  Login with user *admin* and the set web interface password
    2.  Goto server config
        1.  Enable *DefaultSMTPGateways*
        2.  Fill in your provider's smtp server address
        3.  Save values
        4.  Read
            [this](http://www.xmailserver.org/Readme.html#smtp_client_authentication)
            if you need to authenticate
    3.  Goto server domains > new domain
    4.  Enter your domain name, for example *your-domain.com*
    5.  Submit
    6.  Goto server config
        1.  Enable and set *CustMapsList* to (see
            [here](http://xmailforum.homelinux.net/index.php?showtopic=4620)):

            ``` 
            zen.spamhaus.org.:0
            ```
12. Create an MX record that points to the external IP of your FritzBox
    1.  See for example
        [here](http://www.dyndns.com/support/kb/email_mail_exchangers_and_dns.html)
        for information
    2.  Use [DynDNS](http://www.dyndns.com/) or
        similar if you have a dynamic IP address
    3.  I created an MX record with a higher priority than the existing
        records, so in case of problems mail will be handled by my
        hosting provider as usual
13. Setup your preferred e-mail client
    1.  Server: external IP of your FritzBox
    2.  User name: *postmaster @ your-domain.com*
14. Test your configuration
    1.  Send a test mail to *postmaster @ your-domain.com* (check server
        logs > smtp)
    2.  Receive the test mail with your e-mail client (check server
        logs > pop3)
    3.  Check for open mail relaying for example
        [here](http://www.abuse.net/relay.html)
15. Setup as many other domains and accounts as you like ...

If you want to forward e-mail:

1.  Goto the domain user you want to forward mail for
2.  Select the link user mail proc
3.  Enter redirect|<forwarding e-mail address>
4.  Submit

It is not a bad idea to backup your XMail settings and storage
directory!

### Setup SSL

1.  Build XMail with SSL support
2.  Login using telnet (or better SSH)
3.  Goto the XMail settings directory
4.  Create the file *openssl.cnf* with the example contents from
    [here](http://www.iona.com/support/docs/orbix2000/2.0/tls/html/OpenSslUtils3.html)
5.  Enter the following commands:

    ``` 
    openssl_genrsa 2048 > server.key
    openssl_req -new -x509 -key server.key -out server.cert -days 365 -config openssl.cnf
    ```

6.  Answer the questions with anything you like, but use your domain
    name as common name (CN)
7.  Forward TCP port 465 to Fritz!Box port 10465 (SSMTP)
8.  Forward TCP port 995 to Fritz!Box port 10995 (POP3S)
9.  Activate the XMail options SSMTP and POP3S (note that the checkboxes
    don't show up checked again before changeset
    Changeset r4760)
10. Test by checking your e-mail with SSL (port 995) enabled

### Useful links

-   [XMail Home Page](http://www.xmailserver.org/)
-   [PHPXmail source
    forge](http://sourceforge.net/projects/phpxmail/)
-   [PhpXMail
    Configuration](http://wiki.qnap.com/wiki/PhpXMail_Configuration)
-   [IPPF: Mailserver für die
    Fritzbox?](http://www.ip-phone-forum.de/showthread.php?t=103699&highlight=PHPXMail)
-   [IPPF: [PATCH]: XMail
    funktioniert](http://www.ip-phone-forum.de/showthread.php?t=205071&highlight=PHPXMail) *
-   [OpenSSL Self-signed Test
    Certificates](http://sial.org/howto/openssl/self-signed/)
-   [HOWTO: Creating SSL certificates with CAcert.org and
    OpenSSL](http://www.lwithers.me.uk/articles/cacert.html)
-   [Welche Webmail-Oberflächen in PHP gibt
    es?](http://www.php-faq.de/q-scripte-webmailer.html)
-   [AfterLogic WebMail
    Pro](http://www.afterlogic.com/products/webmail-pro)

