import os
import wave
file_path = '/home/mbarnig/MARYLUX-648/Marylux-648-16000Hz/wavs/'
for file_name in os.listdir(file_path):
    with wave.open(file_path + file_name, "rb") as wave_file:
        frame_rate = wave_file.getframerate()
        if frame_rate != 16000:
            print(file_name + " : " + str(frame_rate))
