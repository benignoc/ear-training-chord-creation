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

- To be sure no same items are generated, you could save generated items into a table (or into a file) and when GO is clicked, you could index the table and see if the item about to be generated exists already. If yes, then make a new randomseed and check again until a non-existent item is generate.

## HISTORY

- 2017-10-10 Fixed bug on random so that time is more precise (allowing to click fast without duplicate random values) math.randomseed(reaper.time_precise()) *Thanks to **amagalma** from forum.cockos.com for pointing the solution out.*
- 2017-10-09 Fixed bug on non-selected track.