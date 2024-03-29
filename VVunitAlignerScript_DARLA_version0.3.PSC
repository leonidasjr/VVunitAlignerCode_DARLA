# VVunitAligner.psc ##################################################
# Script implemented by Leônidas Silva Jr. (leonidas.silvajr@gmail.com), CH/UEPB, Brazil,
# based originally on DARLA aligner
####--------------------- CITATION ---------------------#####
### SILVA JR. Leônidas. (2022). VVunitAligner for DARLA-based segmentation. Script for Praat (version 0.3). 
######################################################################  
#-#-#-#-#-#-#-#-#-#-#-#-#- C R E D I T S -#-#-#-#-#-#-#-#-#-#-#-#-#
# Plinio Barbosa, for the whole teaching and supervision during my postdoctoral research besides
# the crucial tips/suggestions on programming in Praat as well as being a great friend
# Copyright (C) 2021, Silva Jr., L.
######################################################################

## Getting started...

form Phonetic syllable alignment
	word Folder Paste directory path
	comment WARNING! This script must be in the same folder of the sound and TextGrid files
	comment ".TextGrid" files must be must be created from: "DARLA Semi-Automated Alignment and Extraction"
	comment URL: http://darla.dartmouth.edu/
	boolean Chunk_segmentation 1
	boolean Save_TextGrid_files 0
	#natural Tier_number_1 3
	#natural Tier_number_2 1
	#real Max_period 0.02
	#real Mean_period 0.01
	#real Pause_detection_(s) 0.65
endform

## cleaning Praat's objects window before workflow
numberOfSelectedObjects = numberOfSelected()
if numberOfSelectedObjects > 0
	select all
	Remove
endif
clearinfo

Create Strings as file list... audioDataList *.wav
numberOfFiles = Get number of strings
#writeInfoLine: "DATA SUMMARY"
#appendInfoLine: ""

for y from 1 to numberOfFiles
	select Strings audioDataList
	soundname$ = Get string... y
	Read from file... 'soundname$'
	sound_file$ = selected$ ("Sound")
	tg$ = sound_file$ + ".TextGrid"

	## this is DARLA original TxetGrid file
	darla$ =  "DARLA" + mid$(sound_file$,7,3)
	Read from file... 'tg$'
	select TextGrid 'sound_file$'
	Copy... 'sound_file$'
	Rename... 'darla$'

	## setting a ".TextGrid" name for DARLA segmentation into VV units and VV phones
	darlaVV$ = "DARLA-VV" + mid$(sound_file$,7,3)
	
	select TextGrid 'sound_file$'
	repeat
		ntiers = Get number of tiers
		t = 2
		select TextGrid 'sound_file$'
		Remove tier: 't'
		ntiers = Get number of tiers
	until ntiers = 1
	
	Duplicate tier: 1, 1, "VC"
	textVC = Get number of intervals: 1
	
	## V/C/# labeling for American English
	for i from 2 to textVC - 1
		label$ = Get label of interval: 1, 'i'
		if label$ = "AA" or label$ = "AA0" or label$ = "AA1" or label$ = "AA2" or label$ = "AE" or label$ = "AE0" or label$ = "AE1" or label$ = "AE2"
		... or label$ = "AH" or label$ = "AH0" or label$ = "AH1" or label$ = "AH2" or label$ = "AO" or label$ = "AO0" or label$ = "AO1" or label$ = "AO2"
		... or label$ = "AW" or label$ = "AW0" or label$ = "AW1" or label$ = "AW2" or label$ = "AY" or label$ = "AY0" or label$ = "AY1" or label$ = "AY2" 
		... or label$ = "EH" or label$ = "EH0" or label$ = "EH1" or label$ = "EH2" or label$ = "ER" or label$ = "ER0" or label$ = "ER1" or label$ = "ER2"
		... or label$ = "EY" or label$ = "EY0" or label$ = "EY1" or label$ = "EY2"
		... or label$ = "IH" or label$ = "IH0" or label$ = "IH1" or label$ = "IH2" or label$ = "IY" or label$ = "IY0" or label$ = "IY1" or label$ = "IY2"
		... or label$ = "OW" or label$ = "OW0" or label$ = "OW1" or label$ = "OW2" or label$ = "OY" or label$ = "OY0" or label$ = "OY1" or label$ = "OY2"
		... or label$ = "OH" or label$ = "OH0" or label$ = "OH1" or label$ = "OH2"
		... or label$ = "UW" or label$ = "UW0" or label$ = "UW1" or label$ = "UW2" or label$ = "UY" or label$ = "UY0" or label$ = "UY1" or label$ = "UY2"
		... or label$ = "UH" or label$ = "UH0" or label$ = "UH1" or label$ = "UH2"
			Set interval text: 1, 'i', "V"
		elsif label$ = "B" or label$ = "CH" or label$ = "D" or label$ = "DH" or label$ = "F" or label$ = "G"
		... or label$ = "HH" or label$ = "JH" or label$ = "K" or label$ = "L" or label$ = "M" or label$ = "N" or label$ = "NG" 
		... or label$ = "P" or label$ = "R" or label$ = "S" or label$ = "SH" or label$ = "T" or label$ = "TH" or label$ = "V"
		... or label$ = "W" or label$ = "Y" or label$ = "Z" or label$ = "ZH" 
			Set interval text: 1, 'i', "C"
		elsif label$ = "sp"
			Set interval text: 1, 'i', "#"
		endif
	endfor
	
	## Getting phonetic syllables (V.onset to V.onset, henceforth, VV)
	## Force aligning phonetic syllable (VV) tier to vowel/consonant/pause (V/C/#) tier
	select TextGrid 'sound_file$'
	Get starting points: 1, "is equal to", "V"
	select PointProcess 'sound_file$'_V
	To TextGrid (vuv): 5e-6, 1.25e-6
	#(To TextGrid (vuv): 0.02, 0.01)
	#(To TextGrid (vuv): 'max_period', 'mean_period') (form)
	
	## alignment correction of the VV tier
	select TextGrid 'sound_file$'_V
	k = 2
	repeat
 		nintervals = Get number of intervals: 1
 		select TextGrid 'sound_file$'_V
		Remove left boundary... 1 'k'
		k = k + 1
		nintervals = Get number of intervals... 1
	until k > nintervals

	nintervals = Get number of intervals: 1
	textVV = Get number of intervals: 1

	## Labeling phonetic sylable labels as "VV"
	for i from 2 to textVV - 1
		Set interval text: 1, 'i', "VV"
	endfor
	
	select TextGrid 'darla$'
	Extract one tier: 2
	wordTier_temp$ = "WORD_TIER_temp"
	Rename... 'wordTier_temp$'
	
	## Merging the ".TextGrid" files: (DARLA + VV)
	select TextGrid 'sound_file$'
		plus TextGrid 'sound_file$'_V
		plus TextGrid 'wordTier_temp$'
	Merge
	
	## creating a new (DARLA-VV) tier that mirrors VV unit tier
	Duplicate tier: 2, 4, "DARLA-VV"
	selectObject: "TextGrid merged"
	
	## deleting the first interval of the new DARLA-VV tier if it is a consonant 
	repeat
		labPhone$ = Get label of interval: 4, 2 
			if labPhone$ = "B" or labPhone$ = "CH" or labPhone$ = "D" or labPhone$ = "DH" or labPhone$ = "F" or labPhone$ = "G"
			... or labPhone$ = "HH" or labPhone$ = "JH" or labPhone$ = "K" or labPhone$ = "L" or labPhone$ = "M" or labPhone$ = "N" or labPhone$ = "NG" 
			... or labPhone$ = "P" or labPhone$ = "R" or labPhone$ = "S" or labPhone$ = "SH" or labPhone$ = "T" or labPhone$ = "TH" or labPhone$ = "V"
			... or labPhone$ = "W" or labPhone$ = "Y" or labPhone$ = "Z" or labPhone$ = "ZH" 
				Remove left boundary: 4, 2
			endif
		labPhone$ = Get label of interval: 4, 2 
	until labPhone$ = "AA" or labPhone$ = "AA0" or labPhone$ = "AA1" or labPhone$ = "AA2" or labPhone$ = "AE" or labPhone$ = "AE0" or labPhone$ = "AE1" or labPhone$ = "AE2"
		... or labPhone$ = "AH" or labPhone$ = "AH0" or labPhone$ = "AH1" or labPhone$ = "AH2" or labPhone$ = "AO" or labPhone$ = "AO0" or labPhone$ = "AO1" or labPhone$ = "AO2"
		... or labPhone$ = "AW" or labPhone$ = "AW0" or labPhone$ = "AW1" or labPhone$ = "AW2" or labPhone$ = "AY" or labPhone$ = "AY0" or labPhone$ = "AY1" or labPhone$ = "AY2" 
		... or labPhone$ = "EH" or labPhone$ = "EH0" or labPhone$ = "EH1" or labPhone$ = "EH2" or labPhone$ = "ER" or labPhone$ = "ER0" or labPhone$ = "ER1" or labPhone$ = "ER2"
		... or labPhone$ = "EY" or labPhone$ = "EY0" or labPhone$ = "EY1" or labPhone$ = "EY2"
		... or labPhone$ = "IH" or labPhone$ = "IH0" or labPhone$ = "IH1" or labPhone$ = "IH2" or labPhone$ = "IY" or labPhone$ = "IY0" or labPhone$ = "IY1" or labPhone$ = "IY2"
		... or labPhone$ = "OW" or labPhone$ = "OW0" or labPhone$ = "OW1" or labPhone$ = "OW2" or labPhone$ = "OY" or labPhone$ = "OY0" or labPhone$ = "OY1" or labPhone$ = "OY2"
		... or labPhone$ = "OH" or labPhone$ = "OH0" or labPhone$ = "OH1" or labPhone$ = "OH2"
		... or labPhone$ = "UW" or labPhone$ = "UW0" or labPhone$ = "UW1" or labPhone$ = "UW2" or labPhone$ = "UY" or labPhone$ = "UY0" or labPhone$ = "UY1" or labPhone$ = "UY2"
		... or labPhone$ = "UH" or labPhone$ = "UH0" or labPhone$ = "UH1" or labPhone$ = "UH2"
	
	## overlapping VV and DARLA tiers
	selectObject: "TextGrid merged"
	a = 2
	repeat
		n_intVV = Get number of intervals... 4
		selectObject: "TextGrid merged"
		startVV = Get start time of interval... 3 'a'
		endVV = Get end time of interval... 3 'a'
		durVV = endVV - startVV
		startPhone = Get start time of interval... 4 'a'
		endPhone = Get end time of interval... 4 'a'
		durPhone = endPhone - startPhone
			if 'durPhone:3' < 'durVV:3'
				Remove right boundary... 4 'a'
			elsif 'durPhone:3' >= 'durVV:3'
				a = a + 1
			endif
		n_intPhone = Get number of intervals... 3
		n_intVV = Get number of intervals... 4
	until a = n_intVV
	
	Rename... 'darlaVV$'
	select TextGrid 'darlaVV$'
		Set tier name: 2, "Phones"
		Set tier name: 3, "VowelOnsets"
		Set tier name: 4, "VV Phones"
		Set tier name: 5, "Words"
	
	select TextGrid 'sound_file$'_V
		plus TextGrid 'sound_file$'
	Merge
	
	## deleting temporary files
	select TextGrid 'sound_file$'
		plus TextGrid 'wordTier_temp$'
		plus TextGrid 'sound_file$'_V
		plus PointProcess 'sound_file$'_V
	Remove

	selectObject: "TextGrid merged"
	Rename... 'sound_file$'
		Set tier name: 2, "Phones"
		Set tier name: 3, "VowelOnsets"
		Duplicate tier: 3, 1, "VowelOnsets"
		Remove tier: 4
		Insert interval tier: 4, "Chunk"

	## creating a chunk tier, and segmentation procedures
	select Sound 'sound_file$'
		To Intensity... 100 0 0 yes 
		nframes = Get number of frames
	for k from 1 to nframes
		int = Get value in frame: k
		if int > 50
			time = Get time from frame: k
			select TextGrid 'sound_file$'
			Insert boundary: 4, time
		endif
		select Intensity 'sound_file$'
	endfor
	
	select TextGrid 'sound_file$'
	b = 3
	repeat
		intervals = Get number of intervals: 4
		Remove left boundary: 4, b
		intervals = Get number of intervals: 4
	until b = intervals
	
	if chunk_segmentation = 1
		textVC = Get number of intervals: 2
		for i from 2 to textVC - 1
			label$ = Get label of interval: 2, 'i'
			if label$ = "#" or label$ = ""
				start_pause = Get start time of interval: 2, 'i'
				end_pause = Get end time of interval: 2, 'i'
				dur_pause = (end_pause - start_pause)
					#if dur_pause >= 'pause_detection'
				if dur_pause >= 0.65
					bound = Insert boundary: 4, 'end_pause'
				endif
			endif
		endfor
		
		ch_number = 0
		text_ch = Get number of intervals: 4
		for j from 2 to text_ch - 1
			label$ = Get label of interval: 4, 'j'
			if label$ = ""
				ch_number = ch_number + 1
				Set interval text: 4, 'j', "CH'ch_number'"
			endif
		endfor
		Extract one tier: 4
		selectObject: "TextGrid Chunk"
			plus TextGrid 'darlaVV$'
		Merge
		select TextGrid 'darlaVV$'
		Remove
		selectObject: "TextGrid merged"
		Rename... 'darlaVV$'
		select TextGrid 'darlaVV$'
		Set tier name: 6, "Chunks"
	endif

	## Saving TextGrid files
	if save_TextGrid_files = 1
		@saveTextGrid
		@data_summary
		@results
	else
		@data_summary
		@results
	endif
	
	#####-----#####-----#####-----#####-----#####-----#####
	procedure saveTextGrid
		select TextGrid 'darla$'
		Write to text file... 'darla$'.TextGrid
		#
		select TextGrid 'darlaVV$'
		Write to text file... 'darlaVV$'.TextGrid
		#
		select TextGrid 'sound_file$'
		Write to text file... 'sound_file$'.TextGrid
	endproc
	#####-----#####-----#####-----#####-----#####-----#####
	
	## Counting V, C, # and VV units
	procedure data_summary
		select TextGrid 'darlaVV$'
		vCount = Count intervals where: 1, "is equal to", "V"
		cCount = Count intervals where: 1, "is equal to", "C"
		vvCount = Count intervals where: 3, "is equal to", "VV"
		pauseCount = Count intervals where: 1, "is equal to", "#"
		
		## counting words 
		Duplicate tier: 5, 6, "word_temp"
		numberOfWords = Get number of intervals: 6
		for word from 2 to numberOfWords - 1
			word_label$ = Get label of interval: 6, 'word'
				if word_label$ <> ""
					Set interval text: 6, 'word', "WORD"
				endif
			wordCount = Count intervals where: 6, "is equal to", "WORD"
		endfor
		Remove tier: 6
	endproc
	#####-----#####-----#####-----#####-----#####-----#####

	## Data summary
	#####-----#####-----#####-----#####-----#####-----#####
	procedure results
		appendInfoLine: soundname$, "/.TextGrid"
		appendInfoLine: ""
		appendInfoLine: 'vCount', " vowels"
		appendInfoLine: 'cCount', " consonants"
		appendInfoLine: 'pauseCount', " pauses"
		appendInfoLine: 'vvCount', " VV units"
		appendInfoLine: 'wordCount', " words"
		if y < numberOfFiles
			appendInfoLine: "#####"
		endif
		if chunk_segmentation = 0
			appendInfoLine: ""
			appendInfoLine: "NOTE*: DO NOT FORGET TO CHUNK THE 4th TIER."
			appendInfoLine: ""
		endif
		endproc
	#####-----#####-----#####-----#####-----#####-----#####
endfor

## Counting the TextGrid files (MAUS), and the new ones created: (MAUS<->Phono.Syl., and VVunits)
Create Strings as file list... tgList *.TextGrid
select Strings tgList
numberOfTG = Get number of strings
	if save_TextGrid_files = 1
		appendInfoLine: "--------------------"
		appendInfoLine: 'numberOfFiles', " '.WAV' files, and ", 'numberOfTG', " '.TextGrid' files 
		... were created in the folder:"
		appendInfoLine: folder$
		select all
			minus Strings audioDataList
			minus Strings tgList
		Remove
		select Strings audioDataList
			plus Strings tgList
		Append
	else
		select all
		sound_objects = numberOfSelected ("Sound")
		tg_objects = numberOfSelected ("TextGrid")
		appendInfoLine: "--------------------"
		appendInfoLine: 'sound_objects', " '.WAV' files, and ", 'tg_objects', " '.TextGrid' files
		... were created in the Praat objects window"
		select all
			#minus Strings tgList
			minus Strings audioDataList
		#Write to binary file... 'folder$'\praat.Collection
		select Strings audioDataList
	endif
#select all
#Remove