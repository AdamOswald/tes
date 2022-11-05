#!/usr/bin/perl
use strict;
use warnings;
use Math::Trig;

my $F = 440;
my $st = 2**(1/12);
sub NextSemiTone { return $F *= $st; }

binmode(STDOUT);

my $A = $F;
my $Bb = NextSemiTone();
my $B = NextSemiTone();
my $C = NextSemiTone();
my $Db = NextSemiTone();
my $D = NextSemiTone();
my $Eb = NextSemiTone();
my $E = NextSemiTone();
my $F = NextSemiTone();
my $Gb = NextSemiTone();
my $G = NextSemiTone();
my $Ab = NextSemiTone();

print STDERR "$A\n";

note($A);
note($C);
note($E);
note($Ab);

sub note {
    my ($f) = @_;
    foreach (1..8000){ # 1s at rate = 8000
        # now we accept frequency...
        my $x = $_ * 2 * pi * $f / 8000;
        my $y = sin($x);
        # this is -1..+1, need 0..255
        $y += 1; # if unsigned
        $y /= 2;
        $y *= 255; # depth (or more precisely, max val)
        print pack('C', $y);
    }
}

