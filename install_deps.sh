#!/bin/bash

cd $BUGZILLA_ROOT


# Install Perl dependencies
CPANM="cpanm --quiet --notest --skip-satisfied"

if [ "$GITHUB_BASE_BRANCH" == "master" ]; then
    perl checksetup.pl --cpanfile
    $CPANM --installdeps --with-recommends --with-all-features .
else
    # Some modules are explicitly installed due to strange dependency issues
    $CPANM Software::License
    $CPANM HTML::FormatText::WithLinks
    $CPANM DBD::$BUGS_DB_DRIVER 
    $CPANM --installdeps --with-recommends .
fi

# Remove CPAN build files to minimize disk usage
rm -rf /root/.cpanm
