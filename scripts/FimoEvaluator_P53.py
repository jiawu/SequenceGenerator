#!/usr/bin/python

import sys
from CandidateSequences_P53 import CandidateSequences

#main runtime, passes in the FIMO result pipe from shell script
#overall idea is to process the entries and sort them as them come in.
if __name__ == "__main__":
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

  #after the results are aggregated, perform calculations
  sequence_container.calculate_senspec()
  #insert to model
  #sequence_container.insert_contents(Model)
  sequence_container.insert_contents()

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


