# VVunitAligner.psc #################################################
# Script implemented by Leônidas Silva Jr. (leonidas.silvajr@gmail.com), CH/UEPB, Brazil,
# based originally on DARLA aligner
####--------------------- CITATION ---------------------#####
### 
###  
#-#-#-#-#-#-#-#-#-#-#-#-#- C R E D I T S -#-#-#-#-#-#-#-#-#-#-#-#-#
# 
#
# Plinio Barbosa, for the whole teaching and supervision during my postdoctoral research besides
# the crucial tips/suggestions on programming in Praat as well as being a great friend
# Copyright (C) 2021, Silva Jr., L.
######################################################################

## Getting started...

form Phonetic syllable alignment
	#word Folder Paste directory path
	word Folder C:\Users\Leonidas\Dropbox\Alinhadores\webMAUS\FR
	comment WARNING! This script must be in the same folder of the sound file
	comment ".TextGrid" files must be must be created from webMAUS ("PIPELINE without ASR")
	comment URL: https://clarin.phonetik.uni-muenchen.de/BASWebServices/interface/Pipeline
	#choice Language: 3
  		#button Brazilian Portuguese
  		#button English (US)
		#button French
	boolean Save_TextGrid_files 0
	#natural Tier_number_1 3
	#natural Tier_number_2 1
	#real Max_period 0.02
	#real Mean_period 0.01
endform

#select all
#Remove
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

	## setting a ".TextGrid" name for DARLA segmentation into VV units and VV unit phones
	darlaVV$ = "DARLA-VV" + mid$(sound_file$,7,3)
	
	select TextGrid 'sound_file$'
	repeat
		ntiers = Get number of tiers
		t = 2
		select TextGrid 'sound_file$'
		Remove tier: 't'
		ntiers = Get number of tiers
	until ntiers = 1
	
	#Duplicate tier: 2, 2, "PhonoSyl"
	Duplicate tier: 1, 1, "VC"
	#textPhonoSyl = Get number of intervals: 3
	textVC = Get number of intervals: 1
	
	## Labeling the phonogical syllables (from webMAUS) as "PhonoSyl" 
	#for i from 2 to textPhonoSyl - 1
	#	label$ = Get label of interval: 3, 'i'
	#	if label$ = "<p:>" or label$ = "<p>"
    #			Set interval text: 3, 'i', "#"
	#	else
    #			Set interval text: 3, 'i', "PhonoSyl"
  	#	endif
	#endfor

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
		#elsif label$ = "?"
		#	Set interval text: 1, 'i', ""
		endif
	endfor
	## Deleting right boundaries of empty intervals to align vocalic laryngealization
	#select TextGrid 'sound_file$'
	#j = 2
	#repeat
  	#	n_int = Get number of intervals... 1
	#		lab$ = Get label of interval: 1, 'j'
	#		select TextGrid 'sound_file$'
	#			if lab$ = ""
	#				Remove right boundary... 1 'j'
	#			endif
	#		j = j + 1
	#		n_int = Get number of intervals... 1
	#until j > n_int
	
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

	## Merging the ".TextGrid" files: (MAUS + VV)
	select TextGrid 'sound_file$'
		plus TextGrid 'sound_file$'_V
	Merge
	
	## creating a new (MAS-VV) iter that overlaps VVunit tier
	Duplicate tier: 2, 6, "MAS-VV"
	selectObject: "TextGrid merged"
	
	## erasing the first interval of the new MAS-VV tier if it is a consonant for VV tier 
	## overlapping
	repeat
		labPhone$ = Get label of interval: 4, 2 
			if labPhone$ = "B" or labPhone$ = "CH" or labPhone$ = "D" or labPhone$ = "DH" or labPhone$ = "F" or labPhone$ = "G"
			... or labPhone$ = "HH" or labPhone$ = "JH" or labPhone$ = "K" or labPhone$ = "L" or labPhone$ = "M" or labPhone$ = "N" or labPhone$ = "NG" 
			... or labPhone$ = "P" or labPhone$ = "R" or labPhone$ = "S" or labPhone$ = "SH" or labPhone$ = "T" or labPhone$ = "TH" or labPhone$ = "V"
			... or labPhone$ = "W" or labPhone$ = "Y" or labPhone$ = "Z" or labPhone$ = "ZH" 
				Remove left boundary: 4, 2
			endif
		labPhone$ = Get label of interval: 6, 2 
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
	## overlapping VV and MAS-VV tiers
	selectObject: "TextGrid merged"
	a = 2
	repeat
		n_intVV = Get number of intervals... 6
		selectObject: "TextGrid merged"
		startVV = Get start time of interval... 5 'a'
		endVV = Get end time of interval... 5 'a'
		durVV = endVV - startVV
		startPhone = Get start time of interval... 6 'a'
		endPhone = Get end time of interval... 6 'a'
		durPhone = endPhone - startPhone
			if 'durPhone:3' < 'durVV:3'
				Remove right boundary... 6 'a'
			elsif 'durPhone:3' >= 'durVV:3'
				a = a + 1
			endif
		n_intPhone = Get number of intervals... 5
		n_intVV = Get number of intervals... 6
	until a = n_intVV

	Copy... "TextGrid merged"
	Rename... 'mausMasVV$'
	
	select TextGrid 'mausMasVV$'
	Duplicate tier: 5, 5, "VV units"
	Remove tier: 6

	selectObject: "TextGrid merged"
	Duplicate tier: 5, 1, "VowelOnsets"
	repeat
 		ntiers = Get number of tiers
		t = 4
		selectObject: "TextGrid merged"
		Remove tier: 't'
		ntiers = Get number of tiers
	until ntiers = 3

	select TextGrid 'sound_file$'
	Remove

	## Labeling VV tier as "VowelOnset" tier
	#Duplicate tier: 3, 1, "VowelOnsets"
	#Remove tier: 4
	
	## Saving TextGrid files
	if save_TextGrid_files = 1
		@saveTextGrid
		@percentFit
		@dataSummary
	else
		selectObject: "TextGrid merged"
		Rename... 'sound_file$'
		@percentFit
		@dataSummary
	endif
	
	#####-----#####-----#####-----#####-----#####-----#####
	procedure saveTextGrid
		select TextGrid 'maus$'
		Write to text file... 'maus$'.TextGrid
		#
		select TextGrid 'mausMasVV$'
		Write to text file... 'mausMasVV$'.TextGrid
		#
		selectObject: "TextGrid merged"
		Rename... 'sound_file$'
		Write to text file... 'sound_file$'.TextGrid
	endproc
	#####-----#####-----#####-----#####-----#####-----#####
	
	## Counting new tier intervals
	#####-----#####-----#####-----#####-----#####-----#####
	procedure percentFit
		select TextGrid 'mausMasVV$'
		vCount = Count intervals where: 1, "is equal to", "V"
		cCount = Count intervals where: 1, "is equal to", "C"
		vvCount = Count intervals where: 5, "is equal to", "VV"
		pauseCount = Count intervals where: 1, "is equal to", "#"
		phonoSylCount = Count intervals where: 3, "is equal to", "PhonoSyl"
		perc_fit = abs((phonoSylCount - vvCount))*100/(vvCount)
		perc_fit = 'perc_fit:1'
	endproc
	#####-----#####-----#####-----#####-----#####-----#####

	## Data summary
	#####-----#####-----#####-----#####-----#####-----#####
	procedure dataSummary
		appendInfoLine: soundname$, "/.TextGrid"
		appendInfoLine: ""
		appendInfoLine: 'vCount', " vowels"
		appendInfoLine: 'cCount', " consonants"
		appendInfoLine: 'pauseCount', " pauses"
		appendInfoLine: ""
		appendInfoLine: 'vvCount', " VV units"
		appendInfoLine: 'phonoSylCount', " Phonological syllables"
		appendInfoLine: "Syllable fit correction: ", 'perc_fit', "%"
		appendInfoLine: ""
		if y < numberOfFiles
			appendInfoLine: "#####"
		endif
		select TextGrid 'sound_file$'_V
			plus PointProcess 'sound_file$'_V
		Remove
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