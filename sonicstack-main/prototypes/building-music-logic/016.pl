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

my $len = 4;
my ($length_seconds, $nsamples) = notelength($len, $bpm, $Rate);
print $length_seconds;
my $noteFreq = 1/$length_seconds;
my $vibfreq = 10;
my $vibdepth = 0.02;

my $freqpower = 1/2;

my @drum = note(100, 4, 1, $Rate, $bpm, 1, 0, $freqpower);

FormatTester($Rate, "S16", 1, \&FormatS16, @drum);

my @rdrum = reverb(0.5, 0.2, 64, $Rate, $bpm, @drum);

FormatTester($Rate, "S16", 2, \&FormatS16, @rdrum);


my $chorusfreq = 4;
my %noteDefs = ('A' => $A, 'C' => $C, 'E' => $E, 'Ab' => $Ab);
my %noteDefs2 = map {$_ => $noteDefs{$_} + $chorusfreq} keys %noteDefs;

my $tune = "4 A C 12 E C E 2 Ab 4 x";

$freqpower = 1;

my @music2 = notes($tune, $Rate, $bpm, $vibfreq, $vibdepth, $freqpower, %noteDefs);
my @music3 = notes($tune, $Rate, $bpm, $vibfreq, $vibdepth, $freqpower, %noteDefs2);

#FormatTester($Rate, "U8", \&FormatU8, @music2);
#FormatTester($Rate, "U8", \&FormatU8, @music3);

my @mix = mix(
    {'music' => \@music2, 'pan' => -1, 'level' => 0.7},
    {'music' => \@music3, 'pan' => 1, 'level' => 0.7}, 
);

#FormatTester($Rate, "U8 -c 2", \&FormatU8, @mix);

my $delay_level = 0.6;
my @music4 = delay($delay_level, 2, $Rate, $bpm, @music2);
my @music5 = delay($delay_level, 1, $Rate, $bpm, @music2);

@mix = mix(
    {'music' => \@music2, 'pan' => 0, 'level' => 0.4},
    {'music' => \@music4, 'pan' => 1, 'level' => 0.4},
    {'music' => \@music5, 'pan' => -1, 'level' => 0.4}, 
);

#FormatTester($Rate, "U8 -c 2", \&FormatU8, @mix);

my $echo_feedback = 0.4;
my @music6 = echo($echo_feedback, 7, $Rate, $bpm, pad(1, $Rate, $bpm, level(0.5, @music2)));

#FormatTester($Rate, "U8", \&FormatU8, @music6);


sub notes {
    my ($notestring, $Rate, $bpm, $vibfreq, $vibdepth, $freqpower, %defs) = @_;
    my @pass = ($Rate, $bpm, $vibfreq, $vibdepth, $freqpower);
    my @notes = split /\s+/, $notestring;
    my $len = 4;
    my $vol = 1;
    my @music = ();
    foreach(@notes){
        if(/^\d+$/){
            $len = $_;
        }
        elsif($_ eq 'x'){
            push @music, note(1, $len, 0, @pass);

        }
        elsif(exists $defs{$_}){
            push @music, note($defs{$_}, $len, $vol, @pass);
        }
    }
    return @music;
}

sub notelength {
    my ($len, $bpm, $rate) = @_;
    my $spb = 60/$bpm; # seconds per beat
    my $bpn = 4; # beats per whole-note (semi-breve?)
    my $length_seconds = $spb*$bpn/$len;
    my $nsamples = $rate * $length_seconds;
    return ($length_seconds, $nsamples);
}

sub note {
    my ($f, $len, $vol, $rate, $bpm, $vibfreq, $vibdepth, $freqpower) = @_;

    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);

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
        $p = $p ** $freqpower;
        my $t = $p * $length_seconds;
        my $z = 1; #$p * pi; # do something with it

        my $fm = $f * (1 + $vibdepth*sin(2 * pi * $t * $vibfreq));
        
        my $c = $p * $nsamples;
        my $x = $c * 2 * pi * $fm / $rate; # time, basically
        my $y = $vol * sin($x) * sin($z);
        push @y, $y;
    }
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

sub compress {
    return map {tanh $_} @_; # this should be tanh! (a specific case of logistic: y = 2/(1 + EXP(-2 * x)) -1)
}

sub delay {
    my ($level, $len, $rate, $bpm, @music) = @_;
    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);
    my @pad = map {0} (1..$nsamples);
    return (@pad, level($level, @music));
}

sub echo {
    my ($feedback, $len, $rate, $bpm, @music) = @_;
    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);
    foreach($nsamples .. $#music){
        $music[$_] += $music[$_-$nsamples]*$feedback;
    }
    return @music;
}

sub pad {
    my ($len, $rate, $bpm, @music) = @_;
    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);
    my @pad = map {0} (1..$nsamples);
    return (@music, @pad);
}

sub FormatTester {
    my ($rate, $format, $channels, $renderer, @music) = @_;
    my $rendered = &$renderer(@music);

    # if we're on windows, try to use VLC...
    # vlc uses 4-char format codes that are a little different...

    if ($^O ne 'linux'){ 
	if(length($format) == 2){
	    # s8 or u8
	    $format = lc($format).'  ';
	}
        elsif($format =~ /^S/i){ # signed and longer... needs explicit endiness
	    $format = lc($format).'l';
	}
    }
    

    my $command = $^O eq 'linux' 
        ? "aplay -r $rate -f $format -c $channels"
	: " vlc -I dummy --demux=rawaud --rawaud-channels $channels --rawaud-samplerate $rate --rawaud-fourcc \"$format\" - vlc://quit";
    
    open(my $ph, "| $command") or die $!;
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


##########

# some new ideas in 15 that need testing

# main aim... get some drum sounds 
#   do a basic drum sound using $freqpower
#   do a basic noise signal
#   give the noise signal the same energy envelope as the drum
#   mix them
#   reverb the mix

sub noise {
    # random signal
    my ($len, $rate, $bpm, @music) = @_;
    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);
    return map {2*rand()-1} (1..$nsamples);
}

sub envelope {
    # add a signal level envelope... 
    
    # NOTE.1:
    # attack can be level and freq...
    # sustain can be a sin**(1/p) half-wave ... where p is the attack freq/2 (see tanh.ods)
    #  sin**(1/p) and sin(p*2) appear to have the same gradient though zero, so are good to sum
    # so we should decide on the attack freq and calc the p from that.
    # then both attack sustain have levels
    # finally, we can tweak the decay

    
    # NOTE.2:
    #  attack/ decay:  =2 * pi * (0.5-p/2)^q/(0.5^q)/2
    # ... where p is proportion of note, q is skewe
    #  can then raise this to power k (k<1 probably) to get interesting envelopes
    # eg
    # q  k
    # 40 0.01
    #  5 0.5
    #  3 0.1

    # though none of them have a nice discrete sustain/decay combo - I guess they are useful and easy to calculate 


    # NOTE.3:
    # another way to do this...

    # calc sin attack
    # on the downward section, set the minimum as the sustain level
    # after the sustain period... linear decay to zero, with power modifier to shape it (power where 1 => sustain level)
    # so, parameters we have:
    # attack freq/period
    # attack level
    # sustain freq/period
    # sustain level
    # decay freq/period
    # decay shape


    # NOTE.4:
    # another way...
    
    # 2 tanh functions multiplied...

    # =TANH(X80*Y$77)^Y$78
    # =TANH((2*PI() - X80)*Z$77)^Z$78

    # =TANH(x*p)^q
    # =TANH((2*PI() - x)*r)^s
     
    # where p, q, r, s are shape functions.
    # a nice thing would be to combine note 1 with the second term here by multiplication, thus getting the desired attack, sustain and decay

    my ($attackFreq, $attackLevel, $len, $rate, $bpm, @music) = @_;
    my ($length_seconds, $nsamples) = notelength($len, $bpm, $rate);

    foreach (1..$nsamples){
        
        my $sustain = sin($_)**(2/$attackFreq);
        my $attack = sin($_*$attackFreq);
    }


    # sustain can be a sin**(1/p) half-wave ... where p is the attack freq/2 (see tanh.ods)
    
    #  sin**(1/p) and sin(p*2) appear to have the same gradient though zero, so are good to sum

}

sub applyEnergyEnvelope {
    # grab the energy envelope of a signal, 
    # this would be 1/2 m v^2, so
    # maxLevel * f * f ?
    # and both need to be measured in a sliding window
}

sub measureEnergyEnvelope {
    # grab the energy envelope of a signal, 
    # this would be 1/2 m v^2, so
    # maxLevel * f * f ?
    # and both need to be measured in a sliding window
}

sub modulate {
    # add a signal level modulator, eg: square the signal
    # eg:

    # 1. measure the rms
    # 2. set rms to 0.5
    # 3. compress
    # 4. square the signal
    # 5. set the rms to what it orginally was

    # but step 4. could be anything... but probably a power.

}

sub maxLevel {
    # get the maximum level of a signal
}

sub rmsLevel {
    # get the rms level of a signal

}

sub normalise {
    # set the rms level
}

sub threshold {
    # mute a signal when it drops below a certain level
}

sub reverb {
    # unlike echo, this will be like multiple delay hitting different pans each time.
    my ($feedback, $pan, $len, $rate, $bpm, @music) = @_;

    my @tracks = ({'music' => \@music, 'pan' => $pan, 'level' => 0.4});

    my @delay = @music;

    foreach(1..10){
        my $sign = $pan/(abs($pan));
        $pan = -1*$sign*sqrt(abs($pan));
        @delay = delay($feedback, $len, $rate, $bpm, @delay);
        push @tracks, {'music' => \@delay, 'pan' => $pan, 'level' => 1};
    }

    return @mix = mix(@tracks);
}

sub wrapPan {
    my ($panVal) = @_;
    return (($panVal+1)%2)-1;
}




# TODO: test tanh compression
# DONE... retested in 10.pl
#  shows that atan clips while tanh does not


