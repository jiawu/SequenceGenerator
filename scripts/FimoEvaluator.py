#!/usr/bin/python

import sys
import getopt
from CandidateSequences import CandidateSequences

#motif_family="P53_family.txt"
#collection_base_name="P53_01_1_10000"
#main runtime, passes in the FIMO result pipe from shell script
#overall idea is to process the entries and sort them as them come in.
#class Usage(Exception):
#  def __init__(self, msg):
#    self.msg = msg


if __name__ == "__main__":
#  sys.exit(main())
  
#def main(argv=None):
#  if argv is None:
#    argv = sys.argv
#  try:
#    
#    try:
#      opts, args = getopt.getopt(argv[1:],"h",["help","motiffam=","collection="])
#      for o, a in opts:
#        if o in ("--motiffam"):
#          motif_family_file = a
#          with open(motif_family_file, 'r') as motif_file:
#            motif_family = motif_file.read().splitlines()
#        elif o in ("--collection"):
#          collection_base_name = a
#    except getopt.error, msg:
#      raise Usage(msg)
#  
#  except Usage, err:
#    print >>sys.stderr, err.msg
#    print >>sys.stderr, "for help use --help"
#    return 2

  result_list = []
  #instead of a pure dict, instantiate a object that holds a dict and contains a
  #number of methods
  sequence_container = CandidateSequences()
  for place,line in enumerate(sys.stdin):
    #skip the first line
    if place:
      #create a dict, store entries in the dict
      #pass in old dict into function and line, 
      #pdb.set_trace()
      is_valid = sequence_container.add_entry(line)
      #function parses line, and appends entry to the key
      result_list.append(line)

  #print(result_list[0])
  seq_name=result_list[0].split()
  seq_name=seq_name[1]
  seq_name = seq_name.split("_")
  motif_family_file = seq_name[0] + "_family.txt"
  
  with open(motif_family_file, 'r') as motif_file:
    motif_family = [line.strip() for line in motif_file]
    
  collection_base_name = "_".join(seq_name[0:4])
  motif_name = "_".join(seq_name[0:-3])
  #after the results are aggregated, perform calculations
  #print("HELLOWORLD")
  #print("CHECKING THE FAMILY")
  motif_family_scores = sequence_container.calculate_senspec(motif_family,True,True)
  #print(motif_family_scores)
  #print("CHECKING THE INDIVIDUAL")
  #print(motif_name)
  #print(seq_name)
  #motif_name = "SMAD3_02"
  #motif_name = "P53_01"
  motif_indiv_scores = sequence_container.calculate_senspec([motif_name], True, True)
  #get non-overlapping means only get motifs that don't overlap
  #
  
  #print(motif_indiv_scores)
  #insert to model
  #sequence_container.insert_contents(Model)
  #collection_base_name = "new_P53_seqs"
  sequence_container.insert_contents(collection_base_name, motif_family_scores, motif_indiv_scores)

  #big_dict = sequence_container.get_dict()
  #with open('testing.txt','w') as testfile:
    #for key in big_dict:
      #testfile.write(key + '\n')
    #testfile.write("".join(result_list))

#write parseline helper function that belongs to dict object

#write parse line exceptions function that removes '+' strand
#write/create dict object that stores keys
#insert entries and return summary count


#when all insertion is done:

#summarize results from FIMO file. get sequence score
#get on target and off target motifs
#calculate sensitivity and specificity, return that information or store it?
#these methods should be stored in the FIMOData object
#access functions, getScores, getBlah

#finally, insert database into mongo

#should I write a model wrapper? nah its okay for now
#use pymongo as a model wrapper
#insert summarized batch into mongodb database


