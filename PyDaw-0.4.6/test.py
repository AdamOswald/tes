#!/usr/bin/env python

import sys
import daw

def main(paths):
    for path in paths:
        f = daw.load(path)

        print("Beats per minute: %i" % f.tempo())
        if f.title():
            print(f"Project title: {f.title()}")

        stuff = (
            ("Generators", f.generators()),
            ("Samples", f.samples()),
            ("Effects", f.effects()),
        )
        for label, lst in stuff:
            print("\n%s:\n---------" % label)
            for item in lst:
                print(item)


if __name__ == "__main__":
    paths = sys.argv[1:]
    if paths == []:
        sys.exit(f"usage: {sys.argv[0]} <path> ...")
    main(paths)

