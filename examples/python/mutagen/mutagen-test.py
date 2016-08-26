from mutagen.easyid3 import EasyID3
# import mutagen.id3
# print dir(mutagen)

meta = EasyID3("/mnt/bigdisk/newmus/bob.dylan/07 - You Ain't Goin' Nowhere.mp3")
meta["title"] = "Hello Test"
meta.save()
