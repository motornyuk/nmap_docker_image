#!/usr/bin/env python3

from os import system
from subprocess import run, PIPE
from typing import List
from sys import argv
from random import shuffle


def switch_list():
    switches = [
    "-Pn -sS",
    "-Pn -sT",
    ]
    return switches


def command_builder(switches: List, targets: List, tag: str):
    try:
        # Add verbose
        cmds = ["-v " + s for s in switches]

        # Add ports
        cmds = [c + " --top-ports 5" for c in cmds]

        # Add extra switches
        scripts = [c + " -sC" for c in cmds]
        vers = [c + " -sV" for c in cmds]
        scripts_version = [c + " -sV -sC" for c in cmds]
        
        # Combine lists
        cmds = cmds + scripts + vers + scripts_version

        # Add target/s
        cmds = [c + " " + t for c in cmds for t in targets]
        
        # Dockerize
        cmds = ["docker run --rm " + str(tag) + " " + c for c in cmds]

        print("Commands to be run:")
        [print(c) for c in cmds]
        return cmds

    except Exception as e:
        print("Error! in command_builder: " + str(e))
        exit(1)


def command_executor(cmds):
    try:
        if not cmds:
            print("\ncmd list is empty!\n")
        # Run test commands
        [system(c) for c in cmds]
    except Exception as e:
        print("\n*******  ERROR! running nmap command: " + str(e))
        exit(1)


def main():
    try:
        if (argv[1]):
            docker_tag = str(argv[1])
    except IndexError:
        docker_tag = "latest"
    print("Docker Tag: " + str(docker_tag))        
    targets = ["scanme.nmap.org"]
    cmds = command_builder(switch_list(), targets, docker_tag)
    try:        
        command_executor(cmds)
    except Exception as e:
        print("Error!! in command executor: " + str(e))
        exit(1)
    exit(0)


if __name__ == '__main__':
    main()


