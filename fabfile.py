#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Description: Fabirc script to deploy Awesome WM configuration.
"""
__author__ = "Ariel Gerardo Ríos (ariel.gerardo.rios@gmail.com)"


import os
from fabric.api import *
from fabric.colors import red, green
from sys import exit

CONFIG_DIR = "/etc/xdg/awesome"
CONFIG_FILE = os.path.join(CONFIG_DIR, "rc.lua")
LOCAL_DIR = os.path.realpath(os.path.dirname(__file__))
AWESOME = "/usr/bin/awesome"


def delete(path):
    """
    deletes a given path.
    """
    local("/bin/rm -rf %s" % path)


def install(girl=None):
    """
    Overwrite existent configuration (if any) with this brand new one :).
    """
    if not girl:
        print red("You forgot to bring the girl!")
        exit(1)
    delete(CONFIG_DIR)
    link(girl)


def link(girl):
    """
    Links configuration file to the one contained in this repository.
    """
    cf = os.path.join(LOCAL_DIR, "%s.lua" % girl)
    local("/bin/ln -s %s %s" % (LOCAL_DIR, CONFIG_DIR))
    delete(CONFIG_FILE)
    local("/bin/ln -s %s %s" % (cf, CONFIG_FILE))
    if local("%s --config %s --check" % (AWESOME, CONFIG_FILE)).\
            return_code == 0:
        print green("You can reload your new configuration (or start) "\
                "Awesome WM.")
    else:
        print red("There is some problem with configuration file %s" %
                CONFIG_FILE)
