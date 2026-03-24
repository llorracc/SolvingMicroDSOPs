#!/usr/bin/env perl
# Strip \begin{comment}...\end{comment} blocks from LaTeX. Handles nested
# \begin{comment}/\end{comment} by counting depth. Reads stdin or file args, writes stdout.
# Usage: perl strip-comment-blocks.pl [file.tex ...]   or   cat file.tex | perl strip-comment-blocks.pl

use strict;
use warnings;

my $content = do { local $/; <> };

# Find and remove each \begin{comment}...\end{comment} (nesting-safe)
while ( $content =~ m/\\begin\s*\{\s*comment\s*\}/g ) {
    my $start = $-[0];
    my $depth = 1;
    my $i     = pos($content);
    my $len   = length($content);

    while ( $i < $len && $depth > 0 ) {
        if ( substr( $content, $i ) =~ m/^\s*\\begin\s*\{\s*comment\s*\}/ ) {
            $depth++;
            $i += length($&);
        } elsif ( substr( $content, $i ) =~ m/^\s*\\end\s*\{\s*comment\s*\}/ ) {
            $depth--;
            if ( $depth == 0 ) {
                my $end = $i + length($&);
                $content = substr( $content, 0, $start ) . "\n" . substr( $content, $end );
                pos($content) = 0;
                last;
            }
            $i += length($&);
        } else {
            $i++;
        }
    }
}

print $content;
