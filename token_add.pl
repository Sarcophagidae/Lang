#!/usr/bin/perl -w

use strict;
use warnings;
use 5.014;

sub checkMatrix{
}

open FILE, "<", $ARGV[0];
while (<FILE>){
	chomp;
	next if (/^\#/);
	s/(.*)\](.*)/$1\,0\]$2/g;
	say;	
} 