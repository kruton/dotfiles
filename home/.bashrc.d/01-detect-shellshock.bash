# From: https://gist.github.com/wilkinson/9fedbacb6917c9cf6e36
#
# To anyone worried about using servers that may not have attentive admins --
# put the following line(s) in your ~/.bashrc to help protect yourself:
 
env x='() { :;}; echo "WARNING: SHELLSHOCK DETECTED"' \
    bash --norc -c ':' 2>/dev/null;
 
# It will print to stdout if and only if your shell is vulnerable, and nothing
# will be printed if your shell has been patched. It will take a little longer
# to launch a new shell slightly, but for some, this may be worth it.
