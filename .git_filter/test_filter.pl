#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';

exit main();

sub main {
    my ( $type, $file ) = (undef, undef);
         
    # get command args
    GetOptions(
        't=s' => \$type,
        'f=s' => \$file,
    );
  
    if( not defined $type and not defined $file ) {
        print "type and file, all needed";
        exit(1);
    }

    # function in types
    if( $type =~ /clean/i ) {
        set_clean($file);
    } elsif ( $type =~ /smudge/i ) {
        set_smudge($file);
    } else {
        print "please enter correct mode clean or smudge";
        exit(1);
    }
}

# clean: from work area to stage area, like add, commit
# get information from 'git log'
sub set_clean {
    my $filename = shift;
    
    my ( $author, $usrname, $date, $rev, $filepath );
    #my $log = `git log -- $filename | head -n 3`;
   
    #$log =~ /^Author:\s*(.*)\s*$/xsm;
    #$author = $1;
    #$log =~ /^Date:\s*(.*)\s*$/xsm;
    #$date = $1;
    #$log =~ / commit (.*)$/xsm;
    #$rev = $1;
    #$author =~ /\s*(.*)\s*<.*/xsm;
    #$usrname = $1;
    
    $author = `git log --pretty=format:"%an %ae" -1 -- $filename`;
    $date = `git log --pretty=format:"%ad" -1 -- $filename`;
    $rev = `git log --pretty=format:"%H" -1 -- $filename`;
    $usrname = `git log --pretty=format:"%an" -1 -- $filename`;

    if( not defined $author or 
        not defined $usrname or
        not defined $date or
        not defined $rev ) {
        exit(1);
    }
    
    $filepath = abs_path($filename);
    if( not defined $filepath ) {
        print "invalid filepath";
        exit(1);
    }
    
    my @content;
    # replace all marks
    open( FILE, '+<' .$filepath ) or die( "open file error");
    while(<FILE>) {
        if(/\$Author[^\$]*\$/) {
            s/\$Author[^\$]*\$/\$Author: $author \$/g;
        }
        if(/\$Id[^\$]*\$/) {
            s/\$Id[^\$]*\$/\$Id: $filename $date  $usrname \$/g;
        }
        if(/\$Date[^\$]*\$/) {
            s/\$Date[^\$]*\$/\$Date:   $date \$/g;
        }
        if(/\$Revision[^\$]*\$/) {
            s/\$Revision[^\$]*\$/\$Revision: $rev \$/g;
        }
        if(/\$Header[^\$]*\$/) {
            s/\$Header[^\$]*\$/\$Header: $filepath $rev $date $usrname \$/g;
        }
        push @content, $_;
    }
    print @content;
    close(FILE); 
    
    return 0;
}

# smudge: from stage area to work area, like checkout, pull
sub set_smudge {
    my $filename = shift;
    set_clean($filename);
    return;
}

