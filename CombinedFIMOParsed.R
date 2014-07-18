###############################################################
###	COMBINED PARSED RESULTS FROM FIMO
###############################################################
setwd("F:/NU/CODES/SEQUENCE_GENERATION/GATA1_RESULTS")
#Provide the name of the TF that you want to build the sequence for-Bea
motifofinterest<-"GATA1" 
namemotifTRANSFAC<-"GATA1_04"
#Identify all the files with sequences
listFIMO<-list.files()[grep("Results",list.files())]
ii=8
namefile<-strsplit(listFIMO[ii],"Results")[[1]][2]
print(paste("namefile",namefile))
namefile<-strsplit(namefile,".txt")[[1]][1]
listMATRIXFIMO<-list.files()[grep(paste("Parsed_",namefile,"_",sep=""),list.files())] 
matrixFIMO<-NULL
for (jj in 1:length(listMATRIXFIMO)){
	print (jj)
	tmp<-read.table(file=listMATRIXFIMO[jj],header=TRUE,sep="\t")
	if (jj==1){
		matrixFIMO<-tmp
	} else {
		matrixFIMO<-rbind(matrixFIMO,tmp)
	}
}
Zmotifspecific=tapply(matrixFIMO[,"Zmotifspecific"],matrixFIMO[,"sequence_name"],sum)
Zmotif=tapply(matrixFIMO[,"Zmotif"],matrixFIMO[,"sequence_name"],sum)
Zothermotifs=tapply(matrixFIMO[,"Zothermotifs"],matrixFIMO[,"sequence_name"],sum)
nselspecificmotifs=tapply(matrixFIMO[,"nselspecificmotifs"],matrixFIMO[,"sequence_name"],sum)
nselmotifs=tapply(matrixFIMO[,"nselmotifs"],matrixFIMO[,"sequence_name"],sum)
nallmotifs=tapply(matrixFIMO[,"nallmotifs"],matrixFIMO[,"sequence_name"],sum)
matrixFIMO<-cbind(Zmotifspecific,Zmotif,Zothermotifs,nselspecificmotifs,nselmotifs,nallmotifs)
matrixFIMO<-data.frame(matrixFIMO)
matrixFIMO[,"SensitivitySpecific"]<-apply(matrixFIMO,1,function(x){
	zmotif<-as.numeric(x[grep("Zmotifspecific",colnames(matrixFIMO))])
	nselmotifs<-as.numeric(x[grep("nselmotifs",colnames(matrixFIMO))])
	sensitivity<-zmotif/nselmotifs
	return(sensitivity)
})
matrixFIMO[,"SelectivitySpecific"]<-apply(matrixFIMO,1,function(x){
	zmotifspecific<-as.numeric(x[grep("Zmotifspecific",colnames(matrixFIMO))])
	zmotif<-as.numeric(x[grep("Zmotif",colnames(matrixFIMO))[2]])
	Zothermotifs<-as.numeric(x[grep("Zothermotifs",colnames(matrixFIMO))])
	selectivity<-zmotifspecific/(Zothermotifs+zmotif)
	return(selectivity)
})
matrixFIMO[,"TotalSpecific"]<-matrixFIMO[,"SensitivitySpecific"]*matrixFIMO[,"SelectivitySpecific"]
matrixFIMO[,"Sensitivity"]<-apply(matrixFIMO,1,function(x){
	zmotif<-as.numeric(x[grep("Zmotif",colnames(matrixFIMO))[2]])
	nselmotifs<-as.numeric(x[grep("nselmotifs",colnames(matrixFIMO))])
	sensitivity<-zmotif/nselmotifs
	return(sensitivity)
})
matrixFIMO[,"Selectivity"]<-apply(matrixFIMO,1,function(x){
	zmotif<-as.numeric(x[grep("Zmotif",colnames(matrixFIMO))[2]])
	Zothermotifs<-as.numeric(x[grep("Zothermotifs",colnames(matrixFIMO))])
	selectivity<-zmotif/(Zothermotifs+zmotif)
	return(selectivity)
})
matrixFIMO[,"Total"]<-matrixFIMO[,"Sensitivity"]*matrixFIMO[,"Selectivity"]
matrixFIMO<-matrixFIMO[with(matrixFIMO, order(-matrixFIMO[,"TotalSpecific"],-matrixFIMO[,"nselspecificmotifs"])),]
namefile<-strsplit(listFIMO[ii],"Results")[[1]][2]
sequencesfile<-read.table(strsplit(listFIMO[ii],"Results")[[1]][2],sep="\t",as.is = TRUE,
		fill=FALSE,blank.lines.skip = FALSE,stringsAsFactors = FALSE,skip=0,header=FALSE)	
sequencesfile2<-data.frame(sequence_names=sequencesfile[seq(1,nrow(sequencesfile),by=2),],sequence=sequencesfile[seq(2,nrow(sequencesfile),by=2),])
sequencesfile2[,"sequence_names_mod"]<-apply(sequencesfile2,1,function(x){
	rr<-strsplit(as.character(x[1]),">")[[1]][2]
	return(rr)
})
matrixFIMO<-data.frame(matrixFIMO,sequence=sequencesfile2[match(rownames(matrixFIMO),sequencesfile2[,3]),2])
namefile<-strsplit(namefile,".txt")[[1]][1]
write.table(matrixFIMO, file = paste("Parsed_",namefile,"_nseq_",nrow(matrixFIMO),".txt",sep=""), 
		sep = "\t", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
		col.names = TRUE)