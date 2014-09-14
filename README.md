Lab 1: Language Models
======================
Report by ***Yoav Zimmerman*** for EDAN20 Fall 2014

Collecting a Corpus
-------------------

The Selma swedish novels was used as a corpus. The following bash command was used to retrieve the amount of words

```bash
$ cat Selma.txt | wc -w
965943 
```

Next the concordance script was run using the keyword "Nils" 
    
```bash
$ perl concord_perl.pl Selma.txt Nils 10
t! Se på Nils gåsapåg
t! Se på Nils Holgersso-
...
```

The tokenization script was then run to get a sorted frequency of all unigrams in the text.
     
```bash
$ perl token_perl.pl < Selma.txt | sort | uniq -c | sort -n
...
17234 han
28838 att
34847 och 
```

Normalizing a Corpus
--------------------

To normalize the corpus, the following perl regex replacements were used

```perl
$text =~ s/([A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ](.|\n)+?\.)/<s>$1<\/s>/g;
$text =~ s/([,.?!:;()'\-])//g;
$text =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;
```

The first line uses the simple heuristic of letter sequences beginning with a capital letter and ending with a period to detect sentences. It wraps all sentences with `<s>` tags. The next two lines remove all punctuations and translate all uppercase letters to lowercase. 

Counting unigrams and bigrams
-----------------------------

The frequency of unigrams and bigrams were fetched using provided perl scripts:

```bash
$ perl count_perl.pl < Selma.txt | wc -l
42228

$ perl count_bigram_perl.pl < Selma.txt | wc -l
336405 
```

Since the total amount of unique words in this corpus is 42,288, the total possible number of bigrams is 42,288^2 = 1,788,274,944. The count_bigram_perl script allows us to check how many of those possible bigrams are actually used in this corpus: 336,405. Only 0.0188% of all possible bigrams are used in this corpus; it turns out that most random 2-word combinations are gibberish. Still, there may be some valid bigrams that are not used in this corpus. This is called the sparse data problem, and we can deal with it using the technique of **backoff**. In simple terms, if we encounter a bigram that does not occur in our corpus and equivalently has a probability of zero, we then use the unigram probability instead. If we are using a closed language model, this probability will never be zero.

As an interesting exercise, we can calculate the possible number of 4-grams by taking 42,288^4 = 3.19792728e18. That's a lot of 4-grams!

Computing the likelihood of a sentence
--------------------------------------

Using word counting principles, two programs were written to compute to the probability of a given sentence using a given corpus. The first program uses unigram frequency and the second uses bigram frequency together with the technique of backoff. The following are the program outputs for several sentences, each using the Selma.txt corpus.

_Låt dem äta tårtan !_

# Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1&#124wi)
--- | --- | ---    | ---  | ---
<s> | låt | 90 | 55624 | 0.00161800661584927
låt | dem | 7 | 191 | 0.0366492146596859
dem | äta |  | 3401 | 0.00126809061199075
äta | tårtan |  | 154 | 5.7420157085144e-05
tårtan | </s> |  | 1 | 3.72858162890546e-07
Probability Unigrams: 1.60991625316035e-18
Entropy Rate: 9.43821258199935
Perplexity: 693.721401215826


Notice that the backoff technique is applied for the bigram "hette nils" which is not found anywhere in the corpus. Also notice that the bigram probability is much heigher than the unigram probability for the same sentence and corpus. 
