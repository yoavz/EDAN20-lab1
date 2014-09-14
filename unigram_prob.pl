use utf8;
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDIN, ":encoding(UTF-8)");

($corpus, $sentence_file) = @ARGV;
open(FILE, "$corpus") || die "Could not open file $file_name.";
binmode(FILE, ":encoding(UTF-8)");

$text = <FILE>;
while ($line = <FILE>) { 
	$text .= $line;
}

# add <s> tags 
$text =~ s/([A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ](.|\n)+?\.)/<s> $1 <\/s>/g;
# remove punctuation
$text =~ s/([,.?!:;()'\-])//g;
# make lowercase
$text =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;
# seperate yo
$text =~ tr/a-zåàâäæçéèêëîïôöœßùûüÿA-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ<>\//\n/cs;

@words = split(/\n/, $text);
for ($i = 0; $i <= $#words; $i++) {
	if (!exists($frequency{$words[$i]})) {
		$frequency{$words[$i]} = 1;
	} else {
		$frequency{$words[$i]}++;
	}
}

# foreach $word (sort keys %frequency){
# 	print "$frequency{$word} $word\n";
# }

open(FILE, "$sentence_file") || die "Could not open file $file_name.";
binmode(FILE, ":encoding(UTF-8)");
$sentence = <FILE>;
# make lowercase
$sentence =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;

@sentence_words = split(/\s+/, $sentence);
@probabilities = ();

print "##### Unigrams\n";
print "wi | c(wi) | #words | P(wi)\n";
print "--- | --- | --- | ---\n";
for ($j = 0; $j <= $#sentence_words; $j++) {
    $wi = $sentence_words[$j] ;
    $c_wi = $frequency{$sentence_words[$j]};
    $P_i = $c_wi / $#words;
    print $wi . " | " . $c_wi . " | " . $#words . " | " . $P_i;
    print "\n";

    $probabilities[$j] = $P_i
}

$prob = 1;
$H_sum = 0;
for ($i = 0; $i <= $#probabilities; $i++) {
    $prob = $prob * $probabilities[$i];
    $H_sum = $H_sum + $probabilities[$i] * (log($probabilities[$i])/log(2))
}

$entropy = 1;
for ($i = 0; $i < $#probabilities; $i++) {
    $entropy = $entropy * $probabilities[$i];
}
$entropy = log($entropy) / log(2);
$entropy = -(1/$#probabilities)*$entropy;

print "* Probability Unigrams: " . $prob . "\n";
print "* Entropy Rate: " . $entropy . "\n";
print "* Perplexity: " . 2**$entropy . "\n";
