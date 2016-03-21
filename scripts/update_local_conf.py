#!/usr/bin/env python

import os
import sys

def main():
	if len(sys.argv) != 3:
		print "Error: incorrect number of args passed"
		return 1

	local_conf = open(os.sys.argv[1], "r").read()
	topdir = sys.argv[2]

	parts = local_conf.split("# DO NOT ADD ANYTHING BELOW THIS LINE")

	newlines = open(topdir+"/scripts/local_additions.conf", "r").read()
	updated_contents = parts[0]+newlines
	open(os.sys.argv[1], "w").write(updated_contents)
	return 0
	
if __name__ == "__main__":
	ret = main()
	sys.exit(ret)
