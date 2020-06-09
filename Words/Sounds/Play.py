# from os import listdir
# from os.path import isfile, join

# onlyfiles = [f for f in os.listdir(mypath) if os.path.isfile(os.path.join(mypath, f))]
 
# for f in onlyfiles:
#     if f is wav :
#         os.system("afplay the.wav&")
#         sleep(1)

import os

if os.name == 'posix': # Mac OS X?
  def play_sound (wave_file = "beep.wav"):
    os.system("afplay %s &" % wave_file)
elif os.name == 'nt': # Windows
  import winsound
  def play_sound (wave_file = beep.wav):
    winsound.PlaySound(wave_file ,windsound.SND_ASYNC)
else:
    pass

import glob
import time

play = 1

waves = [ f for f in glob.glob("*.wav") ]

for wave_file in waves:
    print(wave_file)
    if play:
        play_sound(wave_file)
        time.sleep(0.7)
