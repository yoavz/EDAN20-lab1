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
for ($i = 0; $i < $#words; $i++) {
	$bigrams[$i] = $words[$i] . " " . $words[$i + 1];
	if (!exists($frequency{$words[$i]})) {
		$frequency{$words[$i]} = 1;
	} else {
		$frequency{$words[$i]}++;
	}
}

for ($i = 0; $i < $#words; $i++) {
	if (!exists($frequency_bigrams{$bigrams[$i]})) {
		$frequency_bigrams{$bigrams[$i]} = 1;
	} else {
		$frequency_bigrams{$bigrams[$i]}++;
	}
}

# foreach $bigram (sort keys %frequency_bigrams){
# 	print "$frequency_bigrams{$bigram} $bigram \n";
# }

open(FILE, "$sentence_file") || die "Could not open file $file_name.";
binmode(FILE, ":encoding(UTF-8)");
$sentence = <FILE>;
# make lowercase
$sentence =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;

@sentence_words = split(/\s+/, $sentence);
@probabilities = ();
$alpha = 0.4;

print "Bigrams\n";
print "wi | wi+1 | Ci,i+1 | C(i) | P(wi+1|wi)\n";
print "--- | --- | ---    | ---  | ---\n";
for ($j = 1; $j <= $#sentence_words; $j++) {
    $wi = $sentence_words[$j-1] ;
    $wi1 = $sentence_words[$j] ;
    $Cbigram = $frequency_bigrams{$wi . " " . $wi1};
    $Ci = $frequency{$wi};
    if ($Cbigram == 0) {
        $Pi = $alpha *  $Ci / $#words;
    } else {
        $Pi = $Cbigram / $Ci;
    }
    print $wi . " | " . $wi1 . " | " . $Cbigram . " | " . $Ci . " | " . $Pi;
    print "\n";

    $probabilities[$j-1] = $Pi
}

$prob = 1;
for ($i = 0; $i <= $#probabilities; $i++) {
    $prob = $prob * $probabilities[$i];
}

$entropy = 1;
for ($i = 0; $i < $#probabilities; $i++) {
    $entropy = $entropy * $probabilities[$i];
}
$entropy = log($entropy) / log(2);
$entropy = -(1/$#probabilities)*$entropy;

print "Probability Unigrams: " . $prob . "\n";
print "Entropy Rate: " . $entropy . "\n";
print "Perplexity: " . 2**$entropy . "\n";
