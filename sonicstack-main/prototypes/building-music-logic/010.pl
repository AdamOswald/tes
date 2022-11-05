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
my $vibfreq = 10; 
my $vibdepth = 0.001;

my @music = (
    note($A, 4, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($C, 4, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($E, 12, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($C, 12, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($E, 12, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($Ab, 2, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($Ab, 4, 0, $Rate, $bpm, $vibfreq, $vibdepth),
);

my @musicTwice = (@music, @music);

my @musicLong = (
    note($A, 2, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($C, 2, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($E, 6, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($C, 6, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($E, 6, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($Ab, 1, 1, $Rate, $bpm, $vibfreq, $vibdepth),
    note($Ab, 2, 0, $Rate, $bpm, $vibfreq, $vibdepth),
);

my @mix = mix(
    {'music' => \@musicTwice, 'pan' => -1, 'level' => 0.9},
    {'music' => \@musicLong, 'pan' => 0.7, 'level' => 0.7}, 
);

#FormatTester($Rate, "U8 -c 2", \&FormatU8, compress(@mix)); # compression definitely stops clipping, but also changes the tone
FormatTester($Rate, "U8 -c 2", \&FormatU8, level(1, compressA(level(2, @mix)))); # this clips with atan
FormatTester($Rate, "U8 -c 2", \&FormatU8, level(1, compressH(level(2, @mix)))); # tanh this is quite nice!
FormatTester($Rate, "U8 -c 2", \&FormatU8, @mix);


sub note {
    my ($f, $len, $vol, $rate, $bpm, $vibfreq, $vibdepth) = @_;

    my $spb = 60/$bpm; # seconds per beat
    my $bpn = 4; # beats per whole-note (semi-breve?)

    my $length_seconds = $spb*$bpn/$len;

    my $nsamples = $rate * $length_seconds;
    my @y = ();

    ## Frequency Adjust...
    # set an exact number of cycles in the note
    my $cycles = int($f * $length_seconds);
    $f = $cycles/$length_seconds;
    # i've checked and this really works...
    # last value of note ends up being < e-12

    ## Synthesis
    foreach (1..$nsamples){ 
        my $p = $_ / $nsamples; # proportion of the way through the note
        my $t = $p * $length_seconds;
        my $z = $p * pi; # do something with it

        my $fm = $f * (1 + $vibdepth*sin(2 * pi * $t * $vibfreq));
        
        my $x = $_ * 2 * pi * $fm / $rate; # time, basically
        my $y = $vol * sin($x) * sin($z);
        push @y, $y;
    }
    print "start: $y[0]; end: $y[$#y]\n";
    return @y;
}

sub level {
    my $l = shift;
    return map {$_ * $l} @_;
}

sub mix {
    my $L = 0;
    foreach(@_){
        my $l = @{$_->{'music'}};
        $L = $l if $l > $L;

        my $right = ($_->{'pan'} + 1) / 2; 
        my $left = 1 - $right;
        $_->{'left'} = $left * $_->{'level'};
        $_->{'right'} = $right * $_->{'level'};
    }
    my @mix = map {(0, 0)} (1..$L);
    for(my $i = 0; $i < $L; $i++){
        foreach(@_){
            my $v = defined $_->{'music'}->[$i] ? $_->{'music'}->[$i] : 0;
            $mix[$i*2] += $v*$_->{'left'};
            $mix[$i*2+1] += $v*$_->{'right'};
        }
    }
    return @mix;
}

sub compressA {
    return map {atan $_} @_;
}

sub compressH {
    return map {tanh $_} @_;
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
