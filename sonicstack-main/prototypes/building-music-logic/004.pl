#!/usr/bin/perl
use strict;
use warnings;
use Math::Trig;

my $currentSemitone = 440;
my $st = 2**(1/12);
sub NextSemiTone { return $currentSemitone *= $st; }

binmode(STDOUT);

my $A = $currentSemitone;
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
my $Rate = 44100; # use aplay -r 44100

my @music = (
    note($A, 0.5, $Rate),
    note($C, 0.5, $Rate),
    note($E, 0.5, $Rate),
    note($Ab, 2, $Rate),
);

FormatTester($Rate, "U8", \&FormatU8, @music);
#FormatTester($Rate, "S8", \&FormatS8, @music); # not available on my system!
FormatTester($Rate, "S16_LE", \&FormatS16, @music);
#FormatTester($Rate, "U16_LE", \&FormatU16, @music); # not available on my system!

sub note {
    my ($f, $length_seconds, $rate, $renderer) = @_;
    my $nsamples = $rate * $length_seconds;
    my @y = (); 
    foreach (1..$nsamples){ 
        my $x = $_ * 2 * pi * $f / $rate;
        my $y = sin($x);
        push @y, $y;
    }
    return @y;
}

sub FormatTester {
    my ($rate, $format, $renderer, @music) = @_;
    my $rendered = &$renderer(@music);
    print length();
    open(my $ph, "| aplay -r $rate -f $format") or die $!;
    binmode($ph);
    print $ph $rendered;
    close($ph);
}

sub FormatS8 {
    return pack('c*', map {int(255 * $_ / 2)} @_);
}

sub FormatU8 {
    return pack('C*', map {int(255 * ($_+1) / 2)} @_);
}

sub FormatS16 {
    return pack('s*', map {int(65535 * $_ / 2)} @_);
}

sub FormatU16 {
    return pack('S*', map {int(65535 * ($_ + 1) / 2)} @_);
}

