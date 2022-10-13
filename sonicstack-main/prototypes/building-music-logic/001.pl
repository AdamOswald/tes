#!/usr/bin/perl
use strict;
use warnings;
use Math::Trig;

binmode(STDOUT);
foreach (1..8000){ # 1s at rate = 8000
    # we aim for 800 Hz, so want 10 samples per cycle
    my $x = $_ * 2 * pi / 10;
    my $y = sin($x);
    # this is -1..+1, need 0..255
    $y += 1; # if unsigned
    $y /= 2;
    $y *= 256; # depth
    print pack('C', $y);
}
