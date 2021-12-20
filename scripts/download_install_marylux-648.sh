#!/bin/bash
# take the scripts's parent's directory to prefix all the output paths.
RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo $RUN_DIR
# specify sample rate : 22050 or 16000
sample_rate = 22050
if %sample_rate%==22050
(# download and extract MARYLUX-648-22050 dataset
wget https://github.com/mbarnig/Marylux-648-TTS-Corpus/releases/download/v1-test/MARYLUX-648-22050.zip
unzip MARYLUX-648-22050.zip)

if %sample_rate%==16000
(# download and extract MARYLUX-648-16000 dataset
wget https://github.com/mbarnig/Marylux-648-TTS-Corpus/releases/download/v1-test/MARYLUX-648-16000.zip
unzip MARYLUX-648-16000.zip)

# specify text : "letters", "phonemes", "phonemes-ids", "phonemes-with-blanks", phonemes-with-blanks-ids"
text = "phonemes"
# specify format : "ljspeech" (3 columns) or "vctk" (2 columns)
format = "ljspeech"
# create metadata.csv file and train-val splits

if %text%=="letters" if %format%=="ljspeech"
( )
   
    




# create train-val splits
shuf MARYLUX/metadata.csv > MARYLUX/metadata_shuf.csv
head -n 640 MARYLUX/metadata_shuf.csv > MARYLUX/metadata_train.csv
tail -n 8 MARYLUX/metadata_shuf.csv > MARYLUX/metadata_val.csv
