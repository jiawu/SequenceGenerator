##Functions
##All functions' input is the list that contains the nucleotide sequence and their output is a substring
#Check length of sequence so it does not exceed 60
checkLength<-function(sequence, sequenceLength){
	ifelse(length(sequence)>=sequenceLength,return(TRUE),return(FALSE))}
	
#Parse of matrix.dat file from TRANFAC to generate the input for the sequence generator
parseTRANSFACdatabase<-function(data,filterVertebrates=TRUE){
	# Read all the data
	data<-file(data,"rt")
	dataLines<-readLines(data,n = -1L,ok=TRUE)
	close(data)
	# Identify all the sequences present
	MOTIFID<-grep("ID ",dataLines)
	PWMSTART<-grep("P0      A",dataLines)
	# Loop for each of the sequence
	FIMOINPUT<-list()
	kk=0
	for (ii in 1: length(MOTIFID)){
		tmplist<-list()
		#Motif name
		tmplist1<-strsplit(dataLines[MOTIFID[ii]],"$",fixed=TRUE)[[1]]
		Vpre<-grep(" V",tmplist1[1],fixed=TRUE)
		if (filterVertebrates && length(Vpre)==0){
			next
		}
		kk=kk+1
		tmplist[[1]]<-strsplit(dataLines[MOTIFID[ii]],"$",fixed=TRUE)[[1]][2]
		#PWM
		if (ii!=length(MOTIFID)){
			finalPWM<-grep("XX",dataLines[PWMSTART[ii]:MOTIFID[ii+1]],fixed=TRUE)
		} else {
			endlines<-length(dataLines)
			finalPWM<-grep("XX",dataLines[PWMSTART[ii]:endlines],fixed=TRUE)
		}
		PWMraw<-dataLines[(PWMSTART[ii]+1):(PWMSTART[ii]-2+finalPWM[1])]
		PWM<-read.table(textConnection(PWMraw),sep="")
		PWM<-PWM[,2:5]
		#Probabilistic PWM
		PWM<-PWM/rowSums(PWM)
		tmplist[[2]]<-PWM
		w<-nrow(PWM)
		tmplist[[3]]<-w
		nstemp<-as.numeric(strsplit(dataLines[(PWMSTART[ii]+finalPWM[1])]," ",fixed=TRUE)[[1]][3])
		if (!is.na(nstemp)){
			nsites=nstemp
		} else {
			nsites=1
		}
		tmplist[[4]]=nsites
		FIMOINPUT[[kk]]<-tmplist
	}
	print.matrix <- function(m){
		write.table(format(m, justify="right"),
		row.names=F, col.names=F, quote=F)
	}
	#Create the output file
	sink("TRANSFAC2FIMO.txt")
	cat("MEME version 4","\n", sep="")
	cat("","\n", sep="")
	cat("ALPHABET= ACGT","\n", sep="")
	cat("","\n", sep="")	
	cat("strands: + -","\n", sep="")
	cat("","\n", sep="")	
	cat("Background letter frequencies","\n", sep="")
	cat("A 0.303 C 0.183 G 0.209 T 0.306","\n", sep="")
	cat("","\n", sep="")
	for (jj in 1:kk){
		cat(paste("MOTIF", FIMOINPUT[[jj]][[1]],sep=" "),"\n", sep="")
		cat(paste("letter-probability matrix: alength= 4 w= ",
			FIMOINPUT[[jj]][[3]], " nsites= ", FIMOINPUT[[jj]][[4]], " E= 1e-100",
			sep=""),"\n"
		)
		PWM<-FIMOINPUT[[jj]][[2]]
		print.matrix(PWM)
		cat("","\n", sep="")
	}
	sink()
	return("TRANSFAC2FIMO.txt")
}
		
#Generate TFBS list by reading the PWM probabilites, and randomly choosing a number
#ie a random number out of 100 is chosen and then a nucleotide is chosen based on the probability of that number being chosen
TFBSfunction<-function(PWM, width){
	TFBSlist2<-list()
	for(y in 1:width){
		A<-PWM[[1]][[y]]
		C<-PWM[[2]][[y]]
		G<-PWM[[3]][[y]]
		Tt<-PWM[[4]][[y]]
		TFBSlist<-c(A,C,G,Tt)
		rando<-(sample(1:100,1))/100
		if(rando<=TFBSlist[1]){TFBSlist2[length(TFBSlist2)+1]<-"A"}
		if(rando>TFBSlist[1]){
			if(rando<=(TFBSlist[2]+TFBSlist[1])){TFBSlist2[length(TFBSlist2)+1]<-"C"}}
		if(rando>(TFBSlist[2]+TFBSlist[1])){
			if(rando<=(TFBSlist[3]+TFBSlist[2]+TFBSlist[1])){TFBSlist2[length(TFBSlist2)+1]<-"G"}}
		if(rando>(TFBSlist[3]+TFBSlist[2]+TFBSlist[1])){
			if(rando<=1){TFBSlist2[length(TFBSlist2)+1]<-"T"}}
	}
	return(TFBSlist2)}

#Generate most likely TFBS occurance for each PWM by reading the probability for each nucleotide and appending the one with the highest probability
TFBSmax<-function(PWM, width){
	TFBSlist2<-list()
	for(y in 1:width){
		A<-PWM[[1]][[y]]
		C<-PWM[[2]][[y]]
		G<-PWM[[3]][[y]]
		Tt<-PWM[[4]][[y]]
		TFBSlist<-c(A,C,G,Tt)
		max_index = which(TFBSlist==max(TFBSlist))
		# for length of max_index, sample 1
		if (length(max_index) > 1) {
			nucleotide = sample(max_index,1)
		} else {
			nucleotide = max_index
		}
		if(nucleotide == 1) {TFBSlist2 = c(TFBSlist2,"A")}
		if(nucleotide == 2) {TFBSlist2 = c(TFBSlist2,"C")}
		if(nucleotide == 3) {TFBSlist2 = c(TFBSlist2,"G")}
		if(nucleotide == 4) {TFBSlist2 = c(TFBSlist2,"T")}
	}
	max_TFBS = unlist(TFBSlist2)
	return(max_TFBS)
	}


#Generate a random spacer to append to the sequence 
spacerfunction<-function(){
	spacer<-list()
	for(i in 1:sample(1:5,1)){
		rando<-sample(1:4,1)
		if(rando==1){spacer[i]<-"A"}
		if(rando==2){spacer[i]<-"T"}
		if(rando==3){spacer[i]<-"C"}
		if(rando==4){spacer[i]<-"G"}}
	return(spacer)}

#Generate poly-adenylation sequence
PolyAfunction<-function(){
	PolyA<-list()
	for(j in 1:sample(5:12,1)){PolyA[j]<-"A"}
	return(PolyA)}

#write getPWMInfo
getPWMInfo <- function( data, motif_name ) {
# RETURNS A LIST(width, PWM)
	# from a giant text file, parse out the beginning and end of PWM information
	# TO DO LIST: NEED TO CODE EXCEPTIONS, ie IF >1 MOTIFS ARE FOUND OR IF NOTHING IS FOUND
	# JIA: in transfac2fimo, how can nsites be one?
	motif_pattern = motif_name
	motif_index = grep(motif_pattern, data, value = FALSE)
	if (length(motif_index)>1){
		motif_pattern=paste(motif_name,"_",sep="")
	}
	motif_name = grep(motif_pattern, data, value = TRUE)
	motif_name = gsub(" ", "", motif_name, fixed = TRUE)
	motif_name = gsub("MOTIF", "", motif_name, fixed = TRUE)
	# line number of where motif name is found = motif
	info_index = motif_index + 1
	# next line = info
	# within next line, get w=
	width = str_match(data[info_index],"w= ([0-9]*)")
	width = as.numeric(width[,2])
	list_PWMs = list()
	#grab the pwm using width
	for(x in 1:length(motif_index)){
		current_info_index = info_index[x]
		current_width = width[x]
		PWM = read.table(textConnection(data[(current_info_index+1):(current_info_index+current_width)]))
		list_PWMs <- c(list_PWMs,list(PWM))
	}
	
	return(list(motif_name, width, list_PWMs))
}

#write generateLikelySequence
generateSequences<-function(PWM, width, max_sequence_length, max_number_of_sequences){
	#Write the first three sequences composed of the most likely nucleotide sequence
	sequence_list = list()
	#one repeat
	max_sequence1 <- TFBSmax(PWM,width)
	sequence_list <- c(sequence_list, toString(max_sequence1))
	#two repeats, really you can cat max_sequence, but if two max sequences are equally likely, you should generate new one each time
	max_sequence2 <- c(TFBSmax(PWM,width), TFBSmax(PWM,width))
	sequence_list <- c(sequence_list, toString(max_sequence2))
	#three repeats
	max_sequence3 <- c(TFBSmax(PWM,width), TFBSmax(PWM,width), TFBSmax(PWM,width))
	sequence_list <- c(sequence_list, toString(max_sequence3))

	for(cc in 1:max_number_of_sequences-3){
	print(cc)
	#Loop through to create the other probablistic sequences
		prob_seq <- generateLikelySequence(PWM,width,max_sequence_length)
		sequence_list <- c(sequence_list, toString(prob_seq))
	}
	return(sequence_list)
}

generateLikelySequence<- function(PWM, width, max_sequence_length = 30){
	#Adding the first sequence with 50% chance of adding a spacer
	if(sample(1:2,1)!=2){
		prob_seq <- spacerfunction()
		prob_seq<-c(prob_seq, TFBSfunction(PWM,width))
	} else{
		prob_seq <- TFBSfunction(PWM,width)
	}
	#Adding the second sequence with 50% chance
	if (sample(1:2,1)!=2){
		#If the sequence is not at the max, add spacer at 50% probability
		if(checkLength(prob_seq,max_sequence_length)==FALSE){
			if(sample(1:2,1)!=2){
				prob_seq <- c(prob_seq, spacerfunction(),TFBSfunction(PWM,width))
			} else {
				prob_seq <- c(prob_seq, TFBSfunction(PWM,width))
			}
		}
	}
	#Adding another sequence with 50% chance
	if (sample (1:2,1)!=2){
		if(checkLength(prob_seq,max_sequence_length)==FALSE){
			if(sample(1:2,1)!=2){
				prob_seq <- c(prob_seq, spacerfunction(),TFBSfunction(PWM,width))
			} else {
				prob_seq <- c(prob_seq, TFBSfunction(PWM,width))
			}
		}
	}
	#The fourth sequence is added with 33% chance
	if (sample (1:3,1)==1){
		if(checkLength(prob_seq,max_sequence_length)==FALSE){
			if(sample(1:2,1)!=2){
				prob_seq <- c(prob_seq, spacerfunction(),TFBSfunction(PWM,width))
			} else {
				prob_seq <- c(prob_seq, TFBSfunction(PWM,width))
			}
		}
	}
	#The fifth sequence is added with 10% chance
	if (sample(1:10,1)==1){
		if(checkLength(prob_seq,max_sequence_length)==FALSE){
			if(sample(1:2,1)!=2){
				prob_seq <- c(prob_seq, spacerfunction(),TFBSfunction(PWM,width))
			} else {
				prob_seq <- c(prob_seq, TFBSfunction(PWM,width))
			}
		}
	}
	#If space permitted added the last spacer with 50%
	if(checkLength(prob_seq,max_sequence_length)==FALSE){
		if(sample(1:2,1)!=2){
			prob_seq <- c(prob_seq, spacerfunction())
		}
	}	
	# "Mutate" the sequence randomly.
	# Jia: this is really too strong of a mutation. 
	sequence_length = length(prob_seq)
	# mutate by 
	# picking a random index to change to a random nucleotide
	# do it such that you loop a random number of times
	#Jia: hardcoded this number, should be a parameter called mutation_rate
	#Jia: optimize by converting to sapply function
	max_mutation = as.integer(max_sequence_length * 0.05)
	mutated_index = sample(1:sequence_length, sample(1:max_mutation,1), replace = FALSE)
	possible_nucleotides = c("A","C","G","T")
	for (x in length(mutated_index)) {
		#mutatedIndex
		current_index = mutated_index[x]
		current_nucleotide = prob_seq[[current_index]]
		#get a random nucleotide that's not the current one
		new_nucleotide = sample(possible_nucleotides[possible_nucleotides != current_nucleotide],1)
		prob_seq[[current_index]] = new_nucleotide
	}
	#if(checkLength(prob_seq,max_sequence_length)==FALSE){ # We added independently of the sequence length
		pospolyA<-sample(1:4,1)
		#Added only at the end
		if(pospolyA==1){
			prob_seq<-c(prob_seq,PolyAfunction())
		} 
		#Added only at the beggining
		if(pospolyA==2){
			prob_seq<-c(PolyAfunction(),prob_seq)
		}
		#Adding both, at the beginning and at the end of the sequence
		if(pospolyA==3){
			prob_seq<-c(PolyAfunction(),prob_seq,PolyAfunction())
		}		
		
	#}
	return(prob_seq)
}
generateSequencesFromDatabase <- function (motif_name, data_struct, max_sequence_length, max_number_of_sequences) {
	#FIND PWM INFO regarding name
	pwm_info<- getPWMInfo(data_struct, motif_name)
	motif_name <- pwm_info[[1]]
	width <- pwm_info[[2]]
	PWM <- pwm_info[[3]]

	sequence_files <- list()
	for (x in 1:length(motif_name)) {
		sequence_list <- generateSequences(PWM[[x]], width[x], max_sequence_length, max_number_of_sequences)

		#Processing, remove commas
		sequence_list <- lapply(sequence_list,gsub,pattern = ", ", replacement="")
		out_name = paste(motif_name[x],format(Sys.time(),"%Y%m%d%H%M%S"),".txt",sep="")

		#Write sequence list to text file
		counter = 1
		if (file.exists(out_name)) {file.remove(out_name)}
		lapply(sequence_list, function(i) {
			write(paste(">",motif_name[x],"_s",counter,sep=""), out_name, append = TRUE, ncolumns=1)
			write(i,out_name,append=TRUE,ncolumns=1)
			counter <<- counter + 1
		})
		sequence_files <- c(sequence_files,list(sequence_list))

		}
	
	return(list(sequence_files, motif_name,PWM, width))
}
