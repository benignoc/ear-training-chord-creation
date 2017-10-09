# ear-training-chord-creation

Reaper script that helps you create ear training chords to practice ear training anywhere.

This script lets you create random chords within a range (**From Note** to **To Note** specified in Midi note numbers), with a specified number of notes (from 1 to 10.. yeah I know 1 note does not make a chord but still).

The structure of the created item is:
- Chord (with a length of **Chord Time**) as many times as specified in **Repeats**.
- Melodic resolution (notes of the chord played from lowest to highest) with a length of **Melodic Time**. 
- Final repetition of the Chord lasting for **Chord Time**.
- If so wanted, between each chord or note, a rest time may be specified equal to **Silence Between**.

All times are specified in tenths of a second.

It will let you choose the number of times the chord is repeated, and for how long will it sound.

## Dependencies

It depends on [Lokasenna's GUI](https://github.com/ReaTeam/ReaScripts-Templates/tree/master/GUI/Lokasenna_GUI). It is part of the ReaTeam script's and templates offering which I highly recommend. My most sincere thanks to him and all the team for sharing and helping so much with the learning process.

At any rate I have added the code in this repository to avoid having distinct versions causing problems and for the ease of use. I may want to embed the code to avoid making subfolders but that will probably be for the future.

## What it does

The script will create items in the track selected, label them and then move the cursor some time after the item, so that you can click the **GO** button several times and leave some space in between.

The labelling of the items follows this logic:
- XnYo_A_B_C...

Where X is the number of notes in the chord, Y is the number of Octaves in the range of allowed notes, and A, B, C... are the notes from lowest to highest.

*It has been taken as default to label all the Sharps and Flats as Sharps, as a convention. Might change this in the future if I add exercises within a key*.

## TODO

- Finish minor bugs (~~error when not selecting track~~) and others yet undetected.
- Problem when clicking **GO** too quickly, the randomization depends on the time, but I think this goes down just to the second, so if you click twice quickly within the same second, the items generated will be identical **If anyone can help me with this, it would be much appreciated**