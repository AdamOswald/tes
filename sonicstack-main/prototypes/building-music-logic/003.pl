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

#my $Rate = 8000;
my $Rate = 44000; # use aplay -r 44000

note($A, 0.5, $Rate);
note($C, 0.5, $Rate);
note($E, 0.5, $Rate);
note($Ab, 2, $Rate);

sub note {
    my ($f, $length_seconds, $rate) = @_;
    my $nsamples = $rate * $length_seconds; 
    foreach (1..$nsamples){ 
        my $x = $_ * 2 * pi * $f / $rate;
        my $y = sin($x);
        # this is -1..+1, need 0..255
        $y += 1; # if unsigned
        $y /= 2;
        $y *= 255; # depth (or more precisely, max val)
        print pack('C', $y);
    }
}

