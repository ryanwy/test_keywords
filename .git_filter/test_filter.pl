#!/usr/bin/perl -d 

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
    
    $author = `git log --pretty=format:"%an %ae" -1 -- $filename`;
    $date = `git log --pretty=format:"%ad" -1 -- $filename`;
    $rev = `git log --pretty=format:"%H" -1 -- $filename`;
    $usrname = `git log --pretty=format:"%an" -1 -- $filename`;

    if( not defined $author or 
        not defined $usrname or
        not defined $date or
        not defined $rev ) {
        print "lack of information:  author/date/rev/usrname";
        exit(1);
    }
    
       
    $filepath = abs_path($filename);
    if( not defined $filepath ) {
        print "invalid filepath";
        exit(1);
    }
    
    my @content;
    # replace all marks
    open( FILE, '+<' .$filename ) or die( "open file error");
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
    my ( $author, $usrname, $date, $rev, $filepath );
    
    $author = `git log --pretty=format:"%an %ae" -1 -- $filename`;
    $date = `git log --pretty=format:"%ad" -1 -- $filename`;
    $rev = `git log --pretty=format:"%H" -1 -- $filename`;
    $usrname = `git log --pretty=format:"%an" -1 -- $filename`;


    if( not defined $author or 
        not defined $usrname or
        not defined $date or
        not defined $rev ) {
        print "lack of information:  author/date/rev/usrname";
        exit(1);
    }
    
    # the log information is empty, we get log from remote master
    if( $author eq "" or 
        $date eq "" or
        $rev eq "" or
        $usrname eq ""
        )
    {
        my $branch = `git branch`;
        my $remote = `git remote`;
        $branch =~ /^\*\s+(.*)/m;
        $branch = $1;
        $remote =~ /(.*)/m;
        $remote = $1;
        my $prefix = $remote.'/'.$branch;
        $author = `git log $prefix --pretty=format:"%an %ae" -1 -- $filename`;
        $date = `git log $prefix --pretty=format:"%ad" -1 -- $filename`;
        $rev = `git log $prefix --pretty=format:"%H" -1 -- $filename`;
        $usrname = `git log $prefix --pretty=format:"%an" -1 -- $filename`; 
    }
    
    $filepath = abs_path($filename);
    if( not defined $filepath ) {
        print "invalid filepath";
        exit(1);
    }
    
    my @content;
    # replace all marks
    while(<STDIN>) {
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
    
    return 0;
}

