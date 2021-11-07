#!/bin/bash
rm -rf boot_strap
git clone https://github.com/joq62/boot_strap.git
/lib/erlang/bin/erl -pa boot_strap/ebin -sname controller -setcookie cookie -detached -run boot_strap boot
