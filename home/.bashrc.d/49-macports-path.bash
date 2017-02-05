#!/usr/bin/env bash

# Put MacPerts info in the path
if [[ $OSTYPE == darwin* ]]; then
    export MP_PREFIX=$HOME/macports

    export PATH=$MP_PREFIX/bin:$MP_PREFIX/sbin:$PATH
    export PATH=`python -c 'import site; print(site.PREFIXES[0])'`/bin:$PATH
    export MANPATH=$MP_PREFIX/share/man:$MANPATH
    export PERL5LIB=$MP_PREFIX/lib/perl5/5.12.4:$MP_PREFIX/lib/perl5/vendor_perl/5.12.4:$PERL5LIB
fi
