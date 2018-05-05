#!/usr/bin/expect
#para [1] the git addr to be clone

set addr [lindex $argv 0]

spawn git clone ${addr}

set timeout 120

expect {
	"Username"	{send "Luojiaxing1991\r";exp_continue}
	"Password"	{send "ljxfyjh1321\r";exp_continue}
	"remote"	{exp_continue}
	"Receiving"	{exp_continue}
	"Resolving"	{exp_continue}
	"Checking connectivity"	{exp_continue}
	"Checking out"	{exp_continue}
	default		{exp_continue}
}

