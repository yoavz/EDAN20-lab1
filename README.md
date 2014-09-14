###### Lab 1: Language Models

#### Collecting a Corpus

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
     
```perl
perl token_perl.pl < Selma.txt | sort | uniq -c | sort -n
...
17234 han
28838 att
34847 och 
```

#### Normalizing a Corpus

To normalize the corpus, the following perl regex replacements were used

    $text =~ s/([A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ](.|\n)+?\.)/<s>$1<\/s>/g;
    $text =~ s/([,.?!:;()'\-])//g;
    $text =~ tr/A-ZÅÀÂÄÆÇÉÈÊËÎÏÔÖŒÙÛÜŸ/a-zåàâäæçéèêëîïôöœßùûüÿ/;

The first line uses the simple heuristic of letter sequences beginning with a capital letter and ending with a period to detect sentences. It wraps all sentences with `<s>` tags. The next two lines remove all punctuations and translate all uppercase letters to lowercase. 

#### Counting unigrams and bigrams

The frequency of unigrams and bigrams were fetched using provided perl scripts:

    $ perl count_perl.pl < Selma.txt | wc -l
    42228
    
    $ perl count_bigram_perl.pl < Selma.txt | wc -l
    336405 

Since the total amount of unique words in this corpus is 42,288, the total possible number of bigrams is 42,288^2 = 1,788,274,944. The count_bigram_perl script allows us to check how many of those possible bigrams are actually used in this corpus: 336,405. Only 0.0188% of all possible bigrams are used in this corpus; it turns out that most random 2-word combinations are gibberish. Still, there may be some valid bigrams that are not used in this corpus. This is called the sparse data problem, and we can deal with it using the technique of **backoff**. In simple terms, if we encounter a bigram that does not occur in our corpus and equivalently has a probability of zero, we then use the unigram probability instead. If we are using a closed language model, this probability will never be zero.

As an interesting exercise, we can calculate the possible number of 4-grams by taking 42,288^4 = 3.19792728e18. That's a lot of 4-grams!

#### Computing the likelihood of a sentence

Using word counting principles, a program was written to compute the unigram probability of a given sentence and tested on several. The following is the output for the sentence "Det var en gång en katt som hette Nils" using Selma.txt as our corpus:

    $ perl unigram_prob.pl Selma.txt sentence.txt
    Unigrams
    ===========================================
    wi      c(wi)   #words  P(wi)
    ===========================================
    det     22087   1072794 0.0205882956094087
    var     12850   1072794 0.0119780684828588
    en      13898   1072794 0.012954956869632
    gång    1332    1072794 0.00124161768242552
    en      13898   1072794 0.012954956869632
    katt    15      1072794 1.39821811083955e-05
    som     16788   1072794 0.0156488570965162
    hette   107     1072794 9.97395585732209e-05
    nils    84      1072794 7.83002142070146e-05
    </s>    55624   1072794 0.0518496561315593
    ===========================================
    Probability Unigrams: 4.55303343054364e-27
    Entropy Rate: 9.24841208232302
    Perplexity: 608.204247851174  

A similar program was written to compute the bigram probability of a given sentence using the backoff technique to deal with sparse data. The following is the output for the sentence "Det var en gång en katt som hette Nils" using Selma.txt as our corpus:

    Bigrams
    ===========================================
    wi      wi+1    Ci,i+1  C(i)    P(wi+1|wi)
    ===========================================
    det     var     4023    22087   0.182143342237515
    var     en      753     12850   0.0585992217898833
    en      gång    695     13898   0.0500071952798964
    gång    en      23      1332    0.0172672672672673
    en      katt    5       13898   0.000359763994819398
    katt    som     2       15      0.133333333333333
    som     hette   50      16788   0.00297831784608053
    hette   nils            107     3.98958234292884e-05
    nils    </s>    1       84      0.0119047619047619
    ===========================================
    Probability Unigrams: 6.25369768461475e-19
    Entropy Rate: 6.75995086271198
    Perplexity: 108.379708574658

Notice that the backoff technique is applied for the bigram "hette nils" which is not found anywhere in the corpus. Also notice that the bigram probability is much heigher than the unigram probability for the same sentence and corpus. 
