# This just makes my username disappear with agnoster
if [[ $HOSTNAME == kroot.* ]]; then
    export DEFAULT_USER="kroot"
else
    export DEFAULT_USER="kenny"
fi
