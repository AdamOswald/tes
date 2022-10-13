#!/usr/bin/perl

use strict;
use warnings;

use Math::Trig ':pi';

my $sound1 = sub { sin(pi2 * $_[0])*$_[1]; };


# context stuff we need to know...
#  bitrate or sample rate
#  sample size or sample depth - min/max values
#  channels - mono or stereo


# note stuff we need to know
#  freq or note
#  relative volume
#  duration
#  envelope?
#  pan?
#  which waveform definition to use (should be fix at least throughout a phrase)
#  bpm

# stuff to make sure of...
# all wave forms start and end at zero
# each transition between notes starts at the closest zero-point



#12345678123456781234567812345678
#1   1   2   1 1   1 1   2   1 1 .



# 8000 Hz == 8000 samples per second
# 120 bpm == 2 beats per second
# so 4000 samples per beat
# s0 1000 samples per eighth note

#              12345678901234567890

my $n8L = 800; # eighth-note length

sub synthNote {
	my ($coderef, $n, $isTrig) = @_;
	my $bytes = '';
	foreach(1..$n){
		my $v = &$coderef(($isTrig ? pi2 : 1)*$_/$n);
		$bytes .= pack('C', int($v*128)+128);
	}
	return $bytes;
}


my @synths = (
	synthNote(sub{my $t=shift; return (1-$t)*sin($t**0.5*pi2*10)/2}, $n8L), # decent kick 
	synthNote(sub{my $t=shift; return (1-$t)*sin($t**0.5*pi2*20)/2}, $n8L), # half-decent kick
	synthNote(sub{return rand()/20}, $n8L), # just noise for snare?
	synthNote(sub{return rand()**4}, $n8L),
	synthNote(sub{return sin(shift()*1)}, $n8L, 1), # okayish bass
	synthNote(sub{my $t=shift(); return 1-sin($t/4)}, $n8L, 1), # sharp
	synthNote(sub{my $t=shift(); return (1-sin($t/4)) * rand()}, $n8L, 1), # more like toms... especially square, cube, 4th or rand
	synthNote(sub{my $t=shift(); return (1-sin($t/4)) * sin($t*200) * rand()}, $n8L, 1), # distorted cowbell?
	synthNote(sub{my $t=shift(); return (1-sin($t/4)) * sin($t*200) }, $n8L, 1), # cowbell?
	synthNote(sub{my $t=shift(); return (1-sin($t/4)) * sin($t*50) }, $n8L, 1), # cowbell?
	synthNote(sub{my $t=shift(); return (1-sin($t/4)) * cos($t*30) }, $n8L, 1), # cos gives a real thump at the start plus a note
	synthNote(sub{my $t=shift(); return (1-$t) * sin($t*2) }, $n8L), # tweak!
	synthNote(sub{my $t=shift(); return sin($t*5)/20 }, $n8L, 1), # low buzz
);

my $drum1 = $synths[0];
my $drum2 = $synths[1];

sub note2html {
	my @values = unpack("C*", $_[0]);
	my $html = qq!<svg width="100%" height="256">!;
	my $L = @values;
	$html .= qq!<line x1="0" y1="128" y2="128" x2="$L" stroke="red"/>!;
	$html .= qq!<polyline points="0,128!;
	foreach my $x(0..$#values){
		my $y = $values[$x];
		$html .= " $x,$y";
	}
	$html .= qq!" fill="none" stroke="black" /></svg>\n!;
	return $html;
}

open(my $fh, '>', 'test.html') or die $!;
foreach (@synths[0..1]){
	print $fh note2html($_);
}
close($fh);

# kick bass should be something like 700Hz attack descending to 60 Hz fundamental
#  the trick is lining up the waves, which is why i've use a physical simulator in the past
#  but actually, we can 

# 1. define individual waves based on the current position in the note
# 2. start and end each wave at zero
# 3. advance the position within the note after adding a wave
# 4. only add a wave if it will fit within the remaining note duration
# 5. pad any remaining note length with zero


=cut 

# so our structure/process could be...

track with 
	
	- voice, defined by a function
	- base pitch (from which, say, 2 octaves can be reached?)
	- maybe clef
	- level
	- pan
	- time signature
	
piece with
	
	- movements
	- sections
	- phrases
	- bars
	- notes
	... each of these would have optional settings for... eg:
		- level
		- pan
		- voice
		- clef
		- timesig
		...
		and each of those cloud affect the rest of the
		- piece, movement, phrase or bar
		or just thecurrent 
		- movement, phrase, bar or note

that's all pretty normal...but additionally 
I would like to be able to define themes and motifs so that they
can be repeated in different keys, voices, with different starting
notes, etc. 

eg: for sonic:

A2 A4 G F G | E1 | G2 G4 F E F | D1 |  ... it's the same thing twice

it could be

$motif1 = motifGenerator(A2 A4 G F G | E1 |)
$motif1('A')  $motif1('G') 

So we have note synthesizers and motif generators!!
Prersumably the motif generator would be sensitive to the key of the
current theme and modulate accordinly

output with -
	
	- sample rate
	- sample depth
	- bit rate
	- channels
	- sample length
	- total length
	- compression policy/scheme (clip, logistic/sigmoid, etc)



so we have some 

	- "SCORE" that defines the MOTIFS, THEMES and STRUCTURE of the music 
	- generators that make features of the music into a SEQUENCE or NOTES
	- synths that generate SAMPLES from the sequence information (memoized?)
	- composers that put the sequence samples together into a TRACK
	- mixers that mix the tracks together into a MIX
	- renderers that compress and output the MIX into RAW audio for aplay...

each note with be sent to a synth with the following params:

	- position within note as proportion (which it can *pi2 as necessary) - note gen
	- nominal frequency - note gen ... possibly tonal modulation 
	- position within 
		+ note 
			* in terms of quarter notes - useful for applying vibrato?
			* in samples - useful for attack?
		+ bar (measure)
		+ motif
		+ phrase
		+ section
		+ theme
		+ movement
		+ piece
		... these other things could be good for changing the 
		- volume
		- tone


	
important:

	+ synth's responsibility
		- starting and ending the note on zero
	+ calling function's responsibility
		- applying freqency, level and pan moduations
		- ensuring cycles meet at zero for freq modded notes
		- expanding to 2 channels?






=cut


my $silence = pack('C',128) x $n8L;

my $seq1 = '1   1   2   1 1   1 1   2   1 1 ';

my $pattern  = '';


foreach my $eighth(split '', $seq1){
	if($eighth eq ' '){
		$pattern .= $silence;
	}
	elsif($eighth eq '2'){
		$pattern .= $drum2;
	}
	else {
		$pattern .=$drum1;
	}
}

#print STDERR map {"$_\n"} unpack('C*', $pattern);

$|++;
binmode(STDOUT);

print $pattern x 4;




