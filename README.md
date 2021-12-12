# Marylux-640-TTS-Corpus

[Judith Manzoni](https://www.uni-trier.de/universitaet/fachbereiche-faecher/fachbereich-ii/faecher/phonetik/personal/dr-judith-manzoni) recorded in 2014 at Saarland University a multilingual Luxembourgish/French/German speech database for the [MaryTTS project](https://github.com/marytts). The audio data is provided in a single FLAC file, recorded at 48 kHz sampling frequency with 16 bit per sample. The transcriptions are provided in a single YAML file. The data is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

The dataset includes the following transcribed clips :
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
* The samples with a standard deviation between the audio- and text-length higher than 0.8 have been removed
* The transcriptions of all remaining clips have been manually checked and the mistakes corrected

 The result is a new database with 640 samples, called Marylux-640-TTS-Corpus.
 
 The different transformation steps are described in detail in the next chapter.
 
 ## Dataset Transformations
 
 ### Downsampling and format conversion
 There are numerous tools abd libraries available to modify the properties of an audio-file which can be used in a bash- or python-script, for example [ffmpeg](https://ffmpeg.org), [sox]http://sox.sourceforge.net/), [librosa](https://librosa.org), ... I used the `resample.py` script from [Coqui-TTS](https://github.com/mbarnig/TTS) based on librosa to process the Marylux dataset. Here is the related command for my environment :
   
``` 
python TTS/bin/resample.py --input_dir /workspace/myTTS-Project/datasets/marylux/wav48000/ --output_dir /workspace/myTTS-Project/datasets/marylux/wav22050/ --output_sr 22050
```   

### Silence Removal
The next figure shows a screenshot from the free, open source, cross-platform [audio software Audacity](https://www.audacityteam.org) showing a typical audio-clip with long silence periods before and after the speech signal.

![silence](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/wav-original.png) 

The deep machine learning TTS training is disturbed by long silence periods. The tools and software introduced above can also been used to remove silence from audio clips. Here is a typical bash command using `sox` to remove silence and to resample all audio clips in a folder in the same go :    

```
for file in wavs/*.wav; do sox "$file" "output/$file" silence 1 0.01 1% reverse silence 1 0.01 1% reverse rate -h 22050 norm -0.1 pad 0.05 0.05; done
```   
The following figure shows the trimmed and normalized audio-clip : 

![trimmed](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/wav-modified.png) 

### Loudness Settings
