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

1. _Låt dem äta tårtan_

##### Unigrams
wi | c(wi) | #words | P(wi)
--- | --- | --- | ---
`<s>` | 55624 | 1072794 | 0.0518496561315593
låt | 191 | 1072794 | 0.000178039772780236
dem | 3401 | 1072794 | 0.00317022652997686
äta | 154 | 1072794 | 0.00014355039271286
tårtan | 1 | 1072794 | 9.32145407226364e-07
`</s>` | 55624 | 1072794 | 0.0518496561315593
* Probability Unigrams: 2.03042586619628e-19
* Entropy Rate: 11.5650659361663
* Perplexity: 3029.92409381538

##### Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1,wi)
--- | --- | ---    | ---  | ---
`<s>` | låt | 90 | 55624 | 0.00161800661584927
låt | dem | 7 | 191 | 0.0366492146596859
dem | äta | backoff | 3401 | 0.00126809061199075
äta | tårtan | backoff | 154 | 5.7420157085144e-05
tårtan | `</s>` | backoff | 1 | 3.72858162890546e-07
* Probability Unigrams: 1.60991625316035e-18
* Entropy Rate: 9.43821258199935
* Perplexity: 693.721401215826

2. _Den svarta räven hoppade över staketet_

##### Unigrams
wi | c(wi) | #words | P(wi)
--- | --- | --- | ---
`<s>` | 55624 | 1072794 | 0.0518496561315593
den | 11773 | 1072794 | 0.010974147879276
svarta | 213 | 1072794 | 0.000198546971739216
räven | 59 | 1072794 | 5.49965790263555e-05
hoppade | 57 | 1072794 | 5.31322882119028e-05
över | 3246 | 1072794 | 0.00302574399185678
staketet | 2 | 1072794 | 1.86429081445273e-06
`</s>` | 55624 | 1072794 | 0.0518496561315593
* Probability Unigrams: 9.65530220567307e-26
* Entropy Rate: 11.2613267547034
* Perplexity: 2454.69277390881

##### Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1,wi)
--- | --- | ---    | ---  | ---
`<s>` | den | 1274 | 55624 | 0.0229037825399108
den | svarta | 30 | 11773 | 0.00254820351652085
svarta | räven | backoff | 213 | 7.94187886956862e-05
räven | hoppade | 1 | 59 | 0.0169491525423729
hoppade | över | 5 | 57 | 0.087719298245614
över | staketet | backoff | 3246 | 0.00121029759674271
staketet | `</s>` | 1 | 2 | 0.5
* Probability Unigrams: 4.17032492246624e-15
* Entropy Rate: 7.7947936050972
* Perplexity: 222.058133547733

3. _Detta är en mycket enkel mening_

##### Unigrams
wi | c(wi) | #words | P(wi)
--- | --- | --- | ---
detta | 2571 | 1072794 | 0.00239654584197898
är | 6604 | 1072794 | 0.00615588826932291
en | 13898 | 1072794 | 0.012954956869632
mycket | 1382 | 1072794 | 0.00128822495278684
enkel | 12 | 1072794 | 1.11857448867164e-05
mening | 172 | 1072794 | 0.000160329010042935
`</s>` | 55624 | 1072794 | 0.0518496561315593
* Probability Unigrams: 2.28942831459782e-20
* Entropy Rate: 10.1623421227089
* Perplexity: 1145.96091400625

##### Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1,wi)
--- | --- | ---    | ---  | ---
`<s>` | detta | 283 | 55624 | 0.00508773191428161
detta | är | 172 | 2571 | 0.0669000388953715
är | en | 312 | 6604 | 0.047244094488189
en | mycket | 27 | 13898 | 0.00194272557202475
mycket | enkel | backoff | 1382 | 0.000515289981114734
enkel | mening | backoff | 12 | 4.47429795468655e-06
mening | `</s>` | 38 | 172 | 0.22093023255814
* Probability Unigrams: 1.59126065729794e-17
* Entropy Rate: 8.93737836589534
* Perplexity: 490.251544702405

4. _Mannen gick till affären_

##### Unigrams
wi | c(wi) | #words | P(wi)
--- | --- | --- | ---
mannen | 456 | 1072794 | 0.000425058305695222
gick | 1856 | 1072794 | 0.00173006187581213
till | 9444 | 1072794 | 0.00880318122584578
affären | 4 | 1072794 | 3.72858162890546e-06
`</s>` | 55624 | 1072794 | 0.0518496561315593
* Probability Unigrams: 1.25152440013472e-15
* Entropy Rate: 11.3089283090122
* Perplexity: 2537.03605850295

##### Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1,wi)
--- | --- | ---    | ---  | ---
`<s>` | mannen | 63 | 55624 | 0.00113260463109449
mannen | gick | 3 | 456 | 0.00657894736842105
gick | till | 54 | 1856 | 0.0290948275862069
till | affären | backoff | 9444 | 0.00352127249033831
affären | `</s>` | 1 | 4 | 0.25
* Probability Unigrams: 1.9084912606939e-10
* Entropy Rate: 7.57171209216275
* Perplexity: 190.24465251911

5. _Kvinnan talade med sin dotter_

##### Unigrams
wi | c(wi) | #words | P(wi)
--- | --- | --- | ---
kvinnan | 148 | 1072794 | 0.000137957520269502
talade | 521 | 1072794 | 0.000485647757164936
med | 9385 | 1072794 | 0.00874818464681943
sin | 2589 | 1072794 | 0.00241332445930906
dotter | 148 | 1072794 | 0.000137957520269502
`</s>` | 55624 | 1072794 | 0.0518496561315593
* Probability Unigrams: 1.01179302801261e-17
* Entropy Rate: 10.4372683282615
* Perplexity: 1386.53500877143

##### Bigrams
wi | wi+1 | Ci,i+1 | C(i) | P(wi+1,wi)
--- | --- | ---    | ---  | ---
`<s>` | kvinnan | 4 | 55624 | 7.19114051488566e-05
kvinnan | talade | 2 | 148 | 0.0135135135135135
talade | med | 83 | 521 | 0.159309021113244
med | sin | 146 | 9385 | 0.0155567394778902
sin | dotter | 22 | 2589 | 0.00849748937813828
dotter | `</s>` | 21 | 148 | 0.141891891891892
* Probability Unigrams: 2.90384354076028e-12
* Entropy Rate: 7.10160749457073
* Perplexity: 137.339946315528

