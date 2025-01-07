# bugzilla running on postgresql
#
# Version 0.0.1
#
# Based on dklawren/docker-bugzilla
#

FROM phusion/baseimage:noble-1.0.0
MAINTAINER gameldar@gmail.com

ENV BUGZILLA_USER bugzilla
ENV BUGZILLA_HOME /home/$BUGZILLA_USER
ENV BUGZILLA_ROOT $BUGZILLA_HOME/devel/htdocs/bugzilla
ENV BUGZILLA_URL http://localhost/bugzilla

ENV GITHUB_BASE_GIT https://github.com/bugzilla/bugzilla
ENV GITHUB_BASE_BRANCH 5.2
ENV GITHUB_QA_GIT https://github.com/bugzilla/qa

ENV ADMIN_EMAIL admin@bugzilla.com
ENV ADMIN_PASSWORD password

ENV BUGS_DB_DRIVER Pg
ENV BUGS_DB_HOST localhost
ENV BUGS_DB_PORT 0
ENV BUGS_DB_NAME bugs
ENV BUGS_DB_USER bugs
ENV BUGS_DB_PASS bugs

ENV BUGS_CONTEXT http://localhost:8080


# Update distribution
RUN apt-get update -qq && \
    apt-get install -y git apache2 build-essential git libcgi-pm-perl libdatetime-perl libdatetime-timezone-perl libdbi-perl libdbix-connector-perl libdigest-sha-perl libemail-address-perl libemail-mime-perl libemail-sender-perl libjson-xs-perl liblist-moreutils-perl libmath-random-isaac-perl libtemplate-perl libtimedate-perl liburi-perl  graphviz libapache2-mod-perl2 libapache2-mod-perl2-dev libauthen-radius-perl libauthen-sasl-perl libcache-memcached-perl libchart-perl libdaemon-generic-perl libemail-reply-perl libencode-detect-perl libencode-perl libfile-copy-recursive-perl libfile-mimeinfo-perl libfile-which-perl libgd-dev libgd-graph-perl libgd-perl libgd-text-perl libhtml-formattext-withlinks-perl libhtml-parser-perl libhtml-scrubber-perl libio-stringy-perl libjson-rpc-perl libmime-tools-perl libnet-ldap-perl libnet-smtp-ssl-perl libsoap-lite-perl libtemplate-plugin-gd-perl libtest-taint-perl libtheschwartz-perl libwww-perl libxmlrpc-lite-perl libxml-twig-perl cpanminus libpq-dev postgresql-client-16 supervisor memcached && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# User configuration
RUN userdel -r ubuntu && useradd -m -G adm -u 1000 -s /bin/bash $BUGZILLA_USER \
    && usermod -U $BUGZILLA_USER \
    && echo "bugzilla:bugzilla" | chpasswd
RUN useradd -m -G adm -u 1001 -s /bin/bash memcached \
    && usermod -U memcached \
    && echo "memcached:memcached" | chpasswd

RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Apache configuration
COPY bugzilla.conf /etc/apache2/sites-available/bugzilla.conf

# Clone the code repo
RUN su $BUGZILLA_USER -c "git clone $GITHUB_BASE_GIT -b $GITHUB_BASE_BRANCH $BUGZILLA_ROOT"

RUN a2dissite 000-default && a2ensite bugzilla && a2enmod cgi headers expires rewrite && touch $BUGZILLA_ROOT/needs_configure && mkdir -p /etc/my_init.d && mkdir -p /etc/service/bugzilla/

# Copy setup and test scripts
COPY install_deps.sh /
RUN chmod 755 /install_deps.sh

# Bugzilla dependencies
RUN /install_deps.sh


COPY run /etc/service/bugzilla/
RUN chmod 755 /etc/service/bugzilla/run
COPY supervisord.conf /etc/
RUN chmod 700 /etc/supervisord.conf

CMD ["/sbin/my_init"]
