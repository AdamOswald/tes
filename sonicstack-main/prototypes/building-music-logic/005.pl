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
my $bpm = 140;

my @music = (
    note($A, 4, 1, $Rate, $bpm ),
    note($C, 4, 1, $Rate, $bpm ),
    note($E, 12, 1, $Rate, $bpm ),
    note($C, 12, 1, $Rate, $bpm ),
    note($E, 12, 1, $Rate, $bpm ),
    note($Ab, 2, 1, $Rate, $bpm ),
    note($Ab, 4, 0, $Rate, $bpm ),
);

FormatTester($Rate, "U8", \&FormatU8, @music);
FormatTester($Rate, "S16_LE", \&FormatS16, @music);

sub note {
    my ($f, $len, $vol, $rate, $bpm) = @_;

    my $spb = 60/$bpm; # seconds per beat
    my $bpn = 4; # beats per whole-note (semi-breve?)

    my $length_seconds = $spb*$bpn/$len;

    my $nsamples = $rate * $length_seconds;
    my @y = ();

    ## Frequency Adjust...
    # set an exact number of cycles in the note
    my $cycles = int($f * $length_seconds);
    $f = $cycles/$length_seconds;

    ## Synthesis
    foreach (1..$nsamples){ 
        my $x = $_ * 2 * pi * $f / $rate;
        my $y = $vol * sin($x);
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

sub FormatU8 {
    return pack('C*', map {int(255 * ($_+1) / 2)} @_);
}

sub FormatS16 {
    return pack('s*', map {int(65535 * $_ / 2)} @_);
}
