###############################################################
##        IDENTIFY THE APPROPIATE NUMBER OF SEQUENCES
###############################################################
setwd("~/SEQUENCE_GENERATOR/")
#Provide the name of the TF that you want to build the sequence for-Bea
motifofinterest<-"GATA1" 
namemotifTRANSFAC<-"GATA1_04"
#Identify all the files with sequences
listFIMO<-list.files()[grep("Results",list.files())]
ii=19
breakn=10
totalbreaks=10
# Read the connection and initialize all the parameters
con  <- file(listFIMO[ii], open = "r")
dataFIMO<-NULL
matrixFIMO<-NULL
sequencesall<-c()
# Start the looping
oneLine <- readLines(con, n = -1L, warn = FALSE) 
totalFile<-length(oneLine)
dataFIMO<-oneLine[(1+round((breakn-1)*totalFile/totalbreaks,0)):round(breakn*totalFile/totalbreaks,0)]
linesread=0
endbreak=length(dataFIMO)
interval<-10000
while (linesread<endbreak) {
	print(paste("linesread",linesread,sep=" "))
	linesend=ifelse((linesread+interval)<endbreak,(linesread+interval),endbreak)
	if (linesread==0){
		dataFIMOtable<-read.table(textConnection(dataFIMO[(linesread+1):linesend]),sep="\t",as.is = TRUE,header=FALSE,
			fill=FALSE,blank.lines.skip = FALSE,stringsAsFactors = FALSE,skip=1)
	} else {
		dataFIMOtable<-read.table(textConnection(dataFIMO[(linesread+1):linesend]),sep="\t",as.is = TRUE,header=FALSE,
			fill=FALSE,blank.lines.skip = FALSE,stringsAsFactors = FALSE,skip=0)
	}
	dataZtmp<-apply(dataFIMOtable,1,function(x){
				rr<-ifelse(as.numeric(x[7])>0.5,0,-qnorm(as.numeric(x[7])))
				return(rr)
	})
	# Sequences
	sequences<-unique(dataFIMOtable[,2])	
		# Generate the tables as per MATCH
	for (ll in 1:length(sequences)){
		posid<-which(dataFIMOtable[,2]==sequences[ll])
		datatmp<-dataFIMOtable[posid,]
		dataZ<-dataZtmp[posid]
		Zmotifspecific=sum(dataZ[grep(namemotifTRANSFAC,datatmp[,1])])
		Zmotif=sum(dataZ[grep(motifofinterest,datatmp[,1])])
		Zothermotifs=sum(dataZ)-sum(dataZ[grep(motifofinterest,datatmp[,1])])
		nallmotifs=length(dataZ)
		nselmotifs=length(grep(motifofinterest,datatmp[,1]))
		nselspecificmotifs=length(grep(namemotifTRANSFAC,datatmp[,1]))		
		if (is.null(matrixFIMO)){
			matrixFIMO<-matrix(0,nrow=1,ncol=7)
			colnames(matrixFIMO)<-c("sequence_name","Zmotifspecific","Zmotif","Zothermotifs","nselspecificmotifs","nselmotifs","nallmotifs")
			matrixFIMO[1,"sequence_name"]=sequences[ll]
			matrixFIMO[1,"Zmotifspecific"]=Zmotifspecific
			matrixFIMO[1,"Zmotif"]=Zmotif
			matrixFIMO[1,"Zothermotifs"]=Zothermotifs
			matrixFIMO[1,"nselspecificmotifs"]=nselspecificmotifs
			matrixFIMO[1,"nselmotifs"]=nselmotifs
			matrixFIMO[1,"nallmotifs"]=nallmotifs
		} else{
			if (!sequences[ll]%in%sequencesall){
				sequence_name=sequences[ll] 
				matrixFIMO<-rbind(matrixFIMO,c(sequence_name,Zmotifspecific,Zmotif,Zothermotifs,nselspecificmotifs,
					nselmotifs,nallmotifs))
			} else {
				posll<-which(matrixFIMO[,"sequence_name"]==sequences[ll])
				matrixFIMO[posll,"Zmotifspecific"]<-as.numeric(matrixFIMO[posll,"Zmotifspecific"])+Zmotifspecific
				matrixFIMO[posll,"Zmotif"]=as.numeric(matrixFIMO[posll,"Zmotif"])+Zmotif
				matrixFIMO[posll,"Zothermotifs"]=as.numeric(matrixFIMO[posll,"Zothermotifs"])+Zothermotifs
				matrixFIMO[posll,"nselspecificmotifs"]=as.numeric(matrixFIMO[posll,"nselspecificmotifs"])+nselspecificmotifs
				matrixFIMO[posll,"nselmotifs"]=as.numeric(matrixFIMO[posll,"nselmotifs"])+nselmotifs
				matrixFIMO[posll,"nallmotifs"]=as.numeric(matrixFIMO[posll,"nallmotifs"])+nallmotifs
			}
		}
		sequencesall<-unique(c(sequencesall,sequences[ll]))
		}
		linesread=linesread+interval
	}
	close(con)
	matrixFIMO<-data.frame(matrixFIMO)
	namefile<-strsplit(listFIMO[ii],"Results")[[1]][2]
	namefile<-strsplit(namefile,".txt")[[1]][1]
	write.table(matrixFIMO, file = paste("Parsed_",namefile,"_",breakn,".txt",sep=""), 
		sep = "\t", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
		col.names = TRUE)
		matrixFIMO<-NULL

			
	