# Marylux-648-TTS-Corpus

[Judith Manzoni](https://www.uni-trier.de/universitaet/fachbereiche-faecher/fachbereich-ii/faecher/phonetik/personal/dr-judith-manzoni) recorded in 2014 at Saarland University a multilingual Luxembourgish/French/German speech database for the [MaryTTS project](https://github.com/marytts). The audio data is provided in a single FLAC file, recorded at 48 kHz sampling frequency with 16 bit per sample. The transcriptions are provided in a single YAML file. The data is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

The dataset includes the following transcribed audio clips :
* Nordwand an d'Sonn : 12
* Luxembourgish utterances from Wikipedia : 584
* Luxembourgish words : 52
* German utterances from Wikipedia : 198
* French utterances from Wikipedia : 255

I optimized this dataset to create a luxembourgish synthetic voice **Luxi** by  training a deep machine learning system, based on neural networks. The following transformations have been done :
* The 12 northwind samples have been removed from the training list to use these sentences for inference tests
* The sampling rate of the audio clips has been changed from 48000 to 22050 Hz and the format has been changed from flac to wav
* The silence at the beginning and the end of each audio clip has been removed 
* The loudness of the audio clips has been set to -25 dB
* The length of the audio clips exceeding 10 seconds has been reduced by splitting and renaming the samples 
* The clips with single words have been assembled into samples each with 4 words, separated by commas
* The clips with noise or wrong pronunciations have been removed
* The transcriptions of all remaining clips have been manually checked, mistakes corrected, numbers and abbreviations expanded
* The samples with a standard deviation between the audio- and text-length higher than 0.8 have been removed after the final quality check

 The result is a new database with 648 samples, called Marylux-648-TTS-Corpus.
 
 The different transformation steps are described in detail in the next chapter.
 
 ## Dataset Transformations
 
 ### Downsampling and format conversion
 There are numerous tools and libraries available to modify the properties of an audio-file which can be used in a bash- or python-script, for example [ffmpeg](https://ffmpeg.org), [sox](http://sox.sourceforge.net/), [librosa](https://librosa.org), ... I used the `resample.py` script from [Coqui-TTS](https://github.com/mbarnig/TTS), based on librosa, to process the Marylux dataset. Here is the related command for my environment :
   
``` 
python TTS/bin/resample.py --input_dir /workspace/myTTS-Project/datasets/marylux/wav48000/ --output_dir /workspace/myTTS-Project/datasets/marylux/wav22050/ --output_sr 22050
```   

### Silence Removal
The next figure shows a screenshot from the free, open source, cross-platform [audio software Audacity](https://www.audacityteam.org) showing a typical audio-clip with long silence periods before and after the speech signal.

figure 1        
![silence](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/wav-original.png)          

The deep machine learning TTS training is disturbed by long silence periods. The tools and software introduced above can also been used to remove silence from audio clips. Here is a typical bash command using `sox` to remove silence and to resample all audio clips in a folder in the same go :    

```
for file in wavs/*.wav; do sox "$file" "output/$file" silence 1 0.01 1% reverse silence 1 0.01 1% reverse rate -h 22050 norm -0.1 pad 0.05 0.05; done
```   
The following figure shows the trimmed and normalized audio-clip : 

figure 2      
![trimmed](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/wav-modified.png)        

### Loudness Settings
The deep machine learning TTS training is sensitive to the level of the audio signal. To avoid differences in the volume of the clips of a TTS dataset the levels should be normalized. This can be done with the same tools and programs introduced before. We must distinguish between peak- and RMS-levels. The peak level is defined by the highest peaks within the signal independently of the amount of energy they are representing. The audio-signal shown in figure 2 has been normalized to a full-scale peak level. During TTS training this can lead to out-of-range amplitudes and auto-clipping. 

A better reference for TTS training is RMS (root mean square), the average of the loudness in the waveform as a whole. Broadcasters and streaming providers like Youtube or Spotify measure and normalize the loudness in LUFS, which is similar to RMS. The [EBU recommendation R128](https://tech.ebu.ch/docs/r/r128-2014.pdf) (= ITU-R BS.1770) specifies the technical details for the loudness normalization. I used the [Python script loudness.py](https://github.com/csteinmetz1/loudness.py) to normalize the audio clips of the Marylux dataset with a reference level of -25 dB. The next figure shows the following normalized clips in the Audacity program :  
* lb-wiki-0192.wav (RMS = -24,51 dB)
* lb-wiki-0373.wav (RMS = -24,84 dB)
* lb-wiki-0477.wav (RMS = -24,51 dB)
* lb-wiki-0533.wav (RMS = -24,38 dB)

figure 3     
![marylux-normalized](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/marylux-normalized-loudness.png)

### Audio Splitting
The audio splitting has been done manually in Audacity. To [calculate the size of an uncompressed audio file](https://www.colincrawley.com/audio-file-size-calculator/), we have to multiply the bit rate (352,8 kbps) of the audio by its duration in seconds. An Marylux audio file of 10 seconds has a size of 441 KB. If we order the audio files in a folder by size, it's easy to select all files exceeding a size of 440 KB and to import them into Audacity. I repeated the following process for all samples :

* set a label in each track at a silence position below the 10 seconds threshold 
* enter the filename as name of the label by changing the first digit of the filename number (lb-wiki-0192 >> lb-wiki-1192) 
* listen to the audio clip part after the label and select the corresponding transcription in the text editor
* break the related csv-transcription into a new row and add the new filename of the splitted clip in the first column of the new row
* export the two file parts with the old and new filename

 The next figure shows the process in the Audacity window for sample lb-wiki-0543.wav.

figure 4    
![audio-splitting](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/clip-splitting.png)   
 
### Assembling Words
Some TTS models fail while training single words or they ignore them. To avoid these problems I assembled the related audio clips and csv rows manually with Audacity and with the text editor. I named the new 12 clips as lb-words-a.wav, lb-words-b.wav, up to lb-words-l.wav.
 
### Noise Removal
Bad audio quality with much noise is a no-go for deep machine learning TTS training. Breath, cough, stutter, background noise, echos and other disturbing sounds presents great challenges for TTS model training and must be discarded. There are several tools and python libraries available to denoise the audio clips, but in my trials none of them provided good results without manual supervision. My favorite tool is the [Audacity noise reduction plugin](https://manual.audacityteam.org/man/noise_reduction.html). By selecting a noisy region in the audio track you can define and save a noise profile. The effect of reducing noise based on this profile can be tested in a preview and applied if the result was satisfactory. 

figure 5    
![noise plug-in](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/noise-reduction.png)

Fortunately the original Marylux audio files are of high quality and I was able to discard a few disturbing sounds manually in Audacity during the sound check done for the text correction. 

### Text Corrections
To check if the text and audio of the resulting 660 samples are congruent, I used the following tools arrangement on my desktop-PC :    

figure 6      
![arrangement](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/tools-arrangement.png)
 
I imported the audio clips into Audacity and looped through the different tracks to listen the speech and to compare it with the text in the `metadata.csv` file, displayed in a text-editor. Some remaining errors have been redressed. At the end the database was ready for a final automatic quality check.

### Quality Check
The final quality check was done with the notebook [TTS/notebooks/dataset_analysis/AnalyzeDataset.ipynb](https://github.com/mbarnig/TTS/blob/marylux/notebooks/dataset_analysis/AnalyzeDataset.ipynb) provided by [Coqui-ai](https://coqui.ai). This program checks if all wav files listed in the `metadata.csv` file are available and unique (no duplicates), calculates mean- and median-values for audio- and text-lengths, counts the number of words (...) in the dataset and plots the results. The next figure shows the plotted graph of the standard deviation between audio-lengths and character-counts. 

figure 7    
![std plot](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/plot-std-1.png)

For best results with the `deep machine learning TTS training` a standard-deviation less than 0.8 is recommended. I identified the samples out of scope and analysed the related audio-clips and transcriptions. In most cases the reason for the deviation was obvious. An example is shown below :

figure 8    
![std out of scope](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/std-out-of-scope.png)

Due to the silence between the single words, separated by commas, the audio-length is very high in comparison to the character-count. Spectrograms can be a great help to check the audio quality of samples where the reason of the deviation is not evident. A great tool is [Sonogram Visible Speech](https://github.com/Christoph-Lauer/Sonogram), version 5. The following figure gives an overview about the features of this software.

figure 9           
![Sonogram 5](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/sonogram-2.png)

To assure a high quality, I removed the following 12 samples of the intermediate MARYLUX-660 corpus, based on the measurement results :

* lb-wiki-0040
* lb-wiki-0109
* lb-wiki-0124
* lb-wiki-0231
* lb-wiki-0235
* lb-wiki-0266
* lb-wiki-0391
* lb-wiki-0438
* lb-wiki-0556
* lb-wiki-0569
* lb-wiki-1047
* lb-wiki-1369

The following figures shows the plotted results for the validated Marylux-database with 648 samples.

figure 10    
![quality check](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/plot-quality.png)

## Dataset Phonemization
### Tensors
A `deep machine learning TTS model` is trained with tensors, a sequence of integers created by converting the symbols from the samples to indices. The symbols can be latin characters, arabic, greek or russian letters, japanese or chinese idiograms and logograms, phonemes, or even emoji's, and much more. The conversion is commonly done by calculating the position (index) of a symbol, extracted from the input-sample, in a predefined symbol-list. Some examples are shown below :

```    
symbols = [

input =

tensor = [

input = 

tensor = [

```   
### International Phonetic Alphabet
In the past an alphabetic system of phonetic notation has been used for TTS voice synthesis. The first pseudo-standards for the phonetic notation, for example [Kirshenbaum](https://en.wikipedia.org/wiki/Kirshenbaum) and [SAMPA](https://en.wikipedia.org/wiki/SAMPA), have been progressively replaced by the [International Phonetic Alphabet](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet) (IPA), based primarily on the Latin script. To generate the phonemes from letters, a conversion program is required. Initially these programs have been rule based. Currently these converters, called g2p (grapheme to phoneme) models, are also trained by deep machine learning. An [automatic phonetic transcription tool for Luxembourgish](http://engelmann.uni.lu/transcription/), created by [Peter Gilles](https://wwwfr.uni.lu/recherche/fhse/dhum/people/peter_gilles), is available at the [luxembourgish web portal](https://infolux.uni.lu) of the [University of Luxembourg](https://wwwfr.uni.lu).

figure 11    
![infolux](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/infolux-transcription.png)

The Luxembourgish Online Dictionary (LOD), maintained by the [Zenter fir d'Lëtzebuerger Sprooch](https://portal.education.lu/zls/) (ZLS), provides phonetic transcriptions for most luxembourgish words.

figure 12    
![LOD](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/lod-housecker.png)

As both the phonemizer- and voice-models are based on deep machine learning with neural networks and tensors, a legitimate question is why doing two sequential trainings to convert letters into phonemes and afterwards convert phonemes via indices (integers) into audio signals. Why not transforming in one training process graphemes into audio signals ? Most recent TTS models are adopting this option and the resulting speech quality is even better then by using the classic procedure, but more computer performance and more training time is required to get valid results. 

The Marylux-648 dataset can be used for both learning options.

### Luxembourgish Phonemizers
[eSpeak-NG](https://github.com/espeak-ng/espeak-ng) and [Rhasspy-Gruut](https://github.com/rhasspy/gruut) are two famous open-source phonemizers which are used by numerous TTS projects. A few months ago I developped the code to integrate the [luxembourgish language into eSpeak-NG](https://github.com/mbarnig/espeak-ng-lb). The code was merged into the main eSpeak-NG project with my [Github pull request #1038](https://github.com/espeak-ng/espeak-ng/pull/1038) on November 11, 2021. Now Luxembourgish is the 127th language supported by eSpeak-NG. A luxembourgish voice, based on formant synthesis techniques, is part of my package. The voice is intelligible, but of low quality. I did no sound optimization because my focus was put on the rule-based phonemization front-end process. The eSpeak-NG lb-phonemizer includes a luxembourgish emoji-dictionary which translates some children-emojis into the names of my grand-children. Some animal-graphics are also converted to the related luxembourgish phonetic transcriptions. The next figure shows a sentence which can be handled by eSpeak-NG-lb.

figure 13     
![emojis](https://github.com/mbarnig/Marylux-648-TTS-Corpus/blob/main/pictures/emojis.png)

The integration of the luxembourgish language into the [gruut-phonemizer](https://github.com/mbarnig/gruut-lb) is more recent. My [code to support Luxembourgish](https://github.com/mbarnig/gruut-ipa) was merged into the gruut-ipa repository with my [Github pull request #7](https://github.com/rhasspy/gruut-ipa/pull/7) on November 10, 2021. My main code was merged into the gruut project with my [Github pull request #18](https://github.com/rhasspy/gruut/pull/18) on December 6, 2021.

The luxembourgish phonemes list used in both phonemizers is the following :

Here is the [associated phonetic luxembourgish dictionary](), based on the [luxembourgish-language ressources](https://github.com/PeterGilles/Luxembourgish-language-resources), provided by Peter Gilles on Github. I did some corrections, modifications and additions.

The fully support of the luxembourgish language by the big TTS-projects with embedded eSpeak-NG- or Gruut-Phonemizer will only be assured when these projects update their code-base to the latest versions of the concerned dependencies. In the mean-time the luxembourgish phonemes must be provided in the external training- and validation files and some hacking is required to feed these files as input to the TTS-models for training.

For this purpose I prepared different Marylux-648 dataset versions which are described in the next chapter.

### Text Format
The reference for the text format of the Marylux transcription file is the public domain dataset [LJSpeech](https://keithito.com/LJ-Speech-Dataset/). All text samples are assembled in one file called `metadata.csv`. Each row contains three columns, separated by the pipe ` | ` symbol :  

* first column : filename of the corresponding audio-file, without extension
* second column : raw text with uppercase and lowercase characters, numbers, abbreviations etc
* third column : cleaned text with lowercase characters, expanded numbers and abbreviations, or phonemes, or phonemes-ids

Here are some simple examples : 

```
marylux_lb-wiki-xxxx|
marylux_lb-wiki-yyyy|
marylux_lb-wiki-zzzz| 
```   
### Luxembourgish Datasets
The checked and validated Marylux TTS database contains 648 luxembourgish samples. Additionally a list of 6 luxembourgish sentences, based on the [Aesop's fables](https://en.wikipedia.org/wiki/Aesop%27s_Fables), is provided for synthesizing tests during the training :   

```        
1. An der Zäit hunn sech den Nordwand an d’Sonn gestridden, wie vun hinnen zwee wuel méi staark wier, wéi e Wanderer, deen an ee waarme Mantel agepak war, iwwert de Wee koum. 
2. Si goufen sech eens, datt deejéinege fir dee Stäerkste gëlle sollt, deen de Wanderer forcéiere géif, säi Mantel auszedoen. 
3. Den Nordwand huet mat aller Force geblosen, awer wat e méi geblosen huet, wat de Wanderer sech méi a säi Mantel agewéckelt huet. 
4. Um Enn huet den Nordwand säi Kampf opginn. 
5. Dunn huet d’Sonn d’Loft mat hire frëndleche Strale gewiermt, a schonn no kuerzer Zäit huet de Wanderer säi Mantel ausgedoen. 
6. Do huet den Nordwand missen zouginn, datt d’Sonn vun hinnen zwee dee Stäerkste wier.
``` 
The following archives of the Marylux-648 database are avaible for download in the release section  of the present Github repository.

Archives including audio files sampled with 22050 Hz :

* marylux-648-22.05KHz-graphemes.zip
* marylux-648-22.05KHz-phonemes.zip
* marylux-648-22.05KHz-phonemes-ids.zip
* marylux-648-22.05KHz-phonemes&blanks.zip
* marylux-648-22.05KHz-phonemes&blanks-ids.zip

Archive including audio files sampled with 16000 Hz :
* marylux-648-16KHz-graphemes.zip

An good splitting of this database for machine learning is the following : 

* training list : 640 (optimal for batch sizes of 64, 32, 20, 16, 10, 8, ...)
* validation list : 8 (optimal for batch sizes of 8, 4, ...)

Some batch scripts to download, decompress, shuffles, split and install these archives are stored in the [scripts]() folder.
