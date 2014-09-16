#!/usr/bin/python
MOTIF_FAMILY = ["P53","TP53","P73"]
#i'm thinking about creating an iterator to store my stuff instead...
#add_entry adds a dict to the iterator
import scipy.stats as sci
import pdb
from pymongo import MongoClient

class CandidateSequences:

  def __init__(self):
    self.entry_number = 0
    self.sequence_dict = {}
    self.senspec_scores = {}
    self.sensitivity_scores = {}
    self.specificity_scores = {}
    self.mongo_client = ""
    
  def add_entry(self, line):
    #split the line into a dict
    try:
      entry_dict = self.parse_fimo(line)
    except IndexError:                                     
      return False
    
    #check if the entry is valid
    if self.is_valid(entry_dict):
      #add the key if it does not exist
      key = entry_dict['sequence_name']
      if key not in self.sequence_dict:
        self.sequence_dict[key] = []
      #append the entry to the key-value pair, where the value is a list
      self.sequence_dict[key].append(entry_dict)
      return True
    else:
      return False  
 

  def calculate_senspec(self):
    for key in self.sequence_dict:
      entry_list = self.sequence_dict[key]
    
      # to calculate sensitivity, get the zscore of the family and divide it by
      # the nonoverlapping number of motifs

      # to calculate specificity, get the zscore of the family and divide it by
      # the nubmer of motifs that bind that are not part of the family

      # to calculate the senspec score, multiply the sensitivity score with the
      # specificity score
      
      ontarget_list = self.get_ontarget_motifs(entry_list)
      #print(list(ontarget_list))
      nonoverlapping_ontarget_list = self.get_nonoverlapping_motifs(ontarget_list)
      
      n_fam = len(nonoverlapping_ontarget_list)
      #calculate combined zscore
      z_fam = self.get_combined_zscore(nonoverlapping_ontarget_list)
      
      if n_fam == 0 :
        sensitivity_score = 0
        z_fam = 0
      else:
        sensitivity_score = z_fam/n_fam #n_fam contains non-overlapping motifs

      offtarget_list = self.get_offtarget_motifs(entry_list)
      offtarget_list = list(offtarget_list)
      n_other = len(offtarget_list)
      
      if n_other == 0:
        specificity_score = z_fam/1
      else:
        specificity_score = z_fam/n_other #n_other contains motifs including overlapping
      
      senspec_score = specificity_score * sensitivity_score

      #write to object's collection of dicts

      self.senspec_scores[key]=senspec_score
      self.sensitivity_scores[key] = sensitivity_score
      self.specificity_scores[key] = specificity_score

  def insert_contents(self):
    #i need to abstract this later on, and create a settings file
    mongo_client = MongoClient('hera.chem-eng.northwestern.edu',27017)
    db = mongo_client['SeqGen_Database']
    scores_collection = db['Sequence_Scores_P53_01']
    entries_collection = db['Sequence_Entries_P53_01']

    #bulk insert all entries
    #sequence_dict is a dict with the key as the name and the entries as the
    #entries
    for key in self.sequence_dict:
      entries_collection.insert(self.sequence_dict[key])

    score_dict_list = []
    #insert scores
    for key in self.senspec_scores:
      score_dict = {}
      score_dict['name'] = key
      score_dict['senspec'] = self.senspec_scores[key]
      score_dict['specificity'] = self.specificity_scores[key]
      score_dict['sensitivity'] = self.sensitivity_scores[key]
      score_dict_list.append(score_dict)
    
    scores_collection.insert(score_dict_list)
    mongo_client.close()
    return True  

  #helper methods
  def get_combined_zscore(self, list):
    #if len(list) > 1:
    #else:
      #combined_zscore= sci.norm.ppf(list[0]['p_value'])
    #[sci.norm.ppf(item['p_value']) for item in list]
    combined_zscore = sum(( (-1) * sci.norm.ppf(float(item['p_value'])) ) for item in list)
    return combined_zscore
  
  def parse_fimo(self,line):
    entry_dict = {}
    entry = line.rstrip("\n").split("\t")
    entry_dict['motif_name'] = entry[0]
    entry_dict['sequence_name'] = entry[1]
    entry_dict['start'] = entry[2]
    entry_dict['stop'] = entry[3]
    entry_dict['strand'] = entry[4]
    entry_dict['p_value'] = entry[6]
    entry_dict['matched_sequence'] = entry[8]
    return entry_dict

  def is_valid(self,entry_dict):
    #check if the strand is positive
    positive = '+'
    if entry_dict['strand'] == positive:
      return True    
    else:
      return False
  
  def get_dict(self):
    return self.sequence_dict

  def get_nonoverlapping_motifs(self,entry_list):
    non_overlap_list = []
    filtered_list = []
    #first sort list
    entry_list = sorted(entry_list, key=lambda k: float(k['p_value']))
    if len(entry_list) > 0:
      #pop the first value out, add it to the non_overlap.
      non_overlap_list.append(entry_list.pop(0))
    
    filtered_list = entry_list
    
    while(len(filtered_list) > 0):
      
      current_dict = non_overlap_list[-1]
      #[item for item in iterable if function(item)]
      filtered_list = [dict for dict in filtered_list if self.is_not_overlapping(dict, current_dict)]
      if len(filtered_list) > 0:
        non_overlap_list.append(filtered_list.pop(0))
    
    return non_overlap_list

  def is_not_overlapping(self, dicta, dictb):
    a=[dicta['start'], dicta['stop']]
    b=[dictb['start'], dictb['stop']]
    #a and b are coordinates
    a = list(map(int,a))
    b = list(map(int,b))
    overlap = min(a[1],b[1]) - max(a[0],b[0])
    if (overlap < 0):
      return True
    else:
      return False

  def get_ontarget_motifs(self,entry_list):
    ontargets = (item for item in entry_list if any(motif in item['motif_name'] for motif in MOTIF_FAMILY))
    return ontargets
    # search list of dicts, motif_name section.
    # get all dicts that have a certain motif name

  def get_offtarget_motifs(self,entry_list):
    offtargets = (item for item in entry_list if not any(motif in item['motif_name'] for motif in MOTIF_FAMILY))
    return offtargets
    # search list of dicts, motif_name section.
    # get all dicts that have a certain motif name

