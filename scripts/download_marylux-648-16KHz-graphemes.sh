#!/bin/bash
# take the scripts's parent's directory to prefix all the output paths.
RUN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo $RUN_DIR
# download MARYLUX-648-16KHz-graphemes dataset
wget https://github.com/mbarnig/Marylux-648-TTS-Corpus/releases/download/v1-test/MARYLUX-648-16KHz-graphemes.zip
# extract
unzip  MARYLUX-648-16KHz-graphemes.zip
# create train-val splits
shuf MARYLUX/metadata.csv > MARYLUX/metadata_shuf.csv
head -n 630 MARYLUX/metadata_shuf.csv > MARYLUX/metadata_train.csv
