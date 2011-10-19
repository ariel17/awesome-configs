#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Description: Fabirc script to deploy Awesome WM configuration.
"""
__author__ = "Ariel Gerardo Ríos (ariel.gerardo.rios@gmail.com)"


import os
from fabric.api import *
from fabric.colors import red, green

CONFIG_DIR = "/etc/xdg/awesome"
CONFIG_FILE = os.path.join(CONFIG_DIR, "rc.lua")
LOCAL_DIR = os.path.realpath(os.path.dirname(__file__))
AWESOME = "/usr/bin/awesome"


def delete():
    """
    Checks if configuration file already exists; if it does, deletes it.
    """
    if os.path.exists(CONFIG_DIR):
        local("/bin/rm -rf %s" % CONFIG_DIR)


def install():
    """
    Overwrite existent configuration (if any) with this brand new one :).
    """
    delete()
    link()


def link():
    """
    Links configuration file to the one contained in this repository.
    """
    local("/bin/ln -s %s %s" % (LOCAL_DIR, CONFIG_DIR))
    if local("%s --config %s --check" % (AWESOME, CONFIG_FILE)).\
            return_code == 0:
        print green("You can reload your new configuration (or start) "\
                "Awesome WM.")
    else:
        print red("There is some problem with configuration file %s" %
                CONFIG_FILE)
