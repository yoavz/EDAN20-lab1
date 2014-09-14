use utf8;
binmode(STDOUT, ":encoding(UTF-8)");
binmode(STDIN, ":encoding(UTF-8)");

$text = <>;
while ($line = <>) { 
   $text .= $line;
}

# add <s> tags 
$text =~ s/([A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ](.|\n)+?\.)/<s>$1<\/s>/g;
# remove punctuation
$text =~ s/([,.?!:;()'\-])//g;
# make lowercase
$text =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;

print $text;
