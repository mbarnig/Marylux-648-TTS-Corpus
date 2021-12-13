# Marylux-640-TTS-Corpus

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
* The samples with a standard deviation between the audio- and text-length higher than 0.8 have been removed
* The transcriptions of all remaining clips have been manually checked, mistakes corrected, numbers and abbreviations expanded

 The result is a new database with 640 samples, called Marylux-640-TTS-Corpus.
 
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
The audio splitting has been done manually in Audacity. To determine the file size of an uncompressed audio file, we have to multiply the bit rate of the audio by its duration in seconds. An audio file of 10 seconds has a size of 220,50 KB. If we order the audio files in a folder by size, it's easy to select all files exceeding a size of 220 KB and to import them into Audacity. I repeated the following process for all samples :

* set a label in each track at a silence position below the 10 seconds threshold 
* enter the filename as name of the label by changing the first digit of the filename number (lb-wiki-0192 >> lb-wiki-1192) 
* listen to the audio clip after the label and select the corresponding transcription in the text editor
* break the related csv-transcription into a new row and add the new filename of the splitted clip in the first column of the new row

At the end when all labels have been set I exported all tracks with the multi-export menu to save the splitted audio clips. The next figure shows the arrangement in my PC window to execute this process as efficient as possible. 

figure 4
 
### Assembling Words
Some TTS models fail while training single words or they ignore them. To avoid these problems I assembled the related audio clips and csv rows manually with Audacity and with the text editor by using the same arrangement as for the audio splitting. I named the new 12 clips as lb-words-a.wav, lb-words-b.wav, up to lb-words-l.wav.
 
### Checking Audio Quality
Bad audio quality with much noise is a no-go for deep machine learning TTS training. Breath, cough, stutter, background noise, echos and other disturbing sounds presents great challenges for TTS model training and must be discarded. There are several tools and python libraries available to denoise the audio clips, but in my trials none of them provided good results without manual supervision. My favorite tool is the [Audacity noise reduction plugin](https://manual.audacityteam.org/man/noise_reduction.html). By selecting a noisy region in the audio track you can define and save a noise profile. The effect of reducing noise based on this profile can be tested in a preview and applied if the result was satisfactory. 

figure audacity plugin

Spectrograms can also be a great help to check the audio quality. A great tool is [Sonogram Visible Speech](https://github.com/Christoph-Lauer/Sonogram) version 5. The following figure gives an overview about the features of this software.

![Sonogram 5](https://github.com/mbarnig/Marylux-640-TTS-Corpus/blob/main/pictures/sonogram-2.png)

Fortunately the original Marylux audio file is of high quality and I was able to discard a few disturbing sounds manually in Audacity during the sound check done for the text correction. 
 
### Standard Deviation
[Coqui-TTS](https://github.com/coqui-ai/TTS/tree/main/notebooks/dataset_analysis) provides several [Jupyter Notebooks](https://jupyter.org) to analyze a new dataset and to find exceptional cases. 
 
### Text Corrections
