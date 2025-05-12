#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Originally from:
# https://github.com/ricobl/dotfiles/blob/master/bin/vim-proxy.py

import sys, subprocess, os

params = sys.argv[1:]

IS_MAC = 'darwin' in sys.platform.lower()
VIM = IS_MAC and 'mvim' or 'gvim'
PWD = os.path.abspath(os.path.curdir)
# Use 2 parent dirs as servername
SERVER_NAME = '/'.join(PWD.split('/')[-2:]).upper()

def run(*args):
    return subprocess.Popen(args, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)

def capture(*args):
    output, _ = run(*args).communicate()
    return output.strip()

def b(arg):
    if not isinstance(arg, bytes):
        return arg.encode('utf-8')
    return arg

def is_running():
    output = capture(VIM, b'--serverlist')
    return b(SERVER_NAME) in output

def open_vim(*args):
    run(VIM, '--servername', SERVER_NAME, *args)

def parse_command(command):
    return ':' + command.lstrip('+') + '<CR>'

def split_params(*args):
    files = []
    commands = []
    for p in args:
        if p.startswith('-'):
            commands.append(p)
            continue
        if p.startswith('+'):
            commands += ['--remote-send', parse_command(p)]
            continue
        files.append(p)

    return files, commands

def open_files(*args):
    files, commands = split_params(*args)
    if files:
        open_vim('--remote-tab-silent', *files)
    if commands:
        open_vim(*commands)

def activate():
    if IS_MAC:
        run('osascript', '-e', """tell application "MacVim" to activate""")
    else:
        run('xdotool', 'search', '--name', SERVER_NAME, 'windowactivate')

def new_tab():
    open_vim('--remote-send', '<Esc>:tabnew<CR>')

if not params:
    if is_running():
        new_tab()
    else:
        open_vim()
else:
    open_files(*params)
    if not IS_MAC and is_running():
        activate()
