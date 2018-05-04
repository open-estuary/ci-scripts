#!/usr/bin/expect

#para [1] the git addr to be clone

set addr [lindex $argv 0]
set path [lindex $argv 1]

cd ${path}

spawn git clone ${addr}

expect {
	"Username"	{send "Luojiaxing1991\r";exp_continue}
	"Password"	{send "ljxfyjh1321\r";exp_continue}
	"remote"	{exp_continue}
	"Receiving"	{exp_continue}
	"Resolving"	{exp_continue}
	"Checking connectivity"	{exp_continue}
	"Checking out"	{exit}
}

