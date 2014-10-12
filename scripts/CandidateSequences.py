#!/usr/bin/python
#i'm thinking about creating an iterator to store my stuff instead...
#add_entry adds a dict to the iterator
import scipy.stats as sci
from pymongo import MongoClient

DB_ADDRESS = "hera.chem-eng.northwestern.edu"
PORT=27017
DB_NAME = "SeqGen_Database2"

class CandidateSequences:

  def __init__(self):
    self.entry_number = 0
    self.sequence_dict = {}
    #self.senspec_scores = {}
    #self.sensitivity_scores = {}
    #self.specificity_scores = {}
    #self.repeat_scores = {}
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
   
  def calculate_senspec(self, motif_family, any_contains=True):
    """returns a score dict, which is a dict of dicts"""
    score_parent_dict = {}
    for key in self.sequence_dict:
      #create a score dict
      score_dict = {}
      
      entry_list = self.sequence_dict[key]
    
      # to calculate sensitivity, get the zscore of the family and divide it by
      # the nonoverlapping number of motifs

      # to calculate specificity, get the zscore of the family and divide it by
      # the nubmer of motifs that bind that are not part of the family

      # to calculate the senspec score, multiply the sensitivity score with the
      # specificity score
      ontarget_list = self.get_ontarget_motifs(entry_list, motif_family,any_contains)
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

      offtarget_list = self.get_offtarget_motifs(entry_list,motif_family, any_contains)
      offtarget_list = list(offtarget_list)
      n_other = len(offtarget_list)
      
      if n_other == 0:
        specificity_score = z_fam/1
      else:
        specificity_score = z_fam/n_other #n_other contains motifs including overlapping
      
      senspec_score = specificity_score * sensitivity_score

      #write to object's collection of dicts
      score_dict["seq_name"] = key
      score_dict["senspec"] = senspec_score
      score_dict["sensitivity"] = sensitivity_score
      score_dict["specificity"] = specificity_score
      score_dict["repeats"] = n_fam
      
      score_parent_dict[key]=score_dict

    return(score_parent_dict)

  def insert_contents(self, collection_base_name, family_scores, individual_scores = None):
    #i need to abstract this later on, and create a settings file
    mongo_client = MongoClient(DB_ADDRESS,PORT)
    db = mongo_client[DB_NAME]

    score_collection_name = "Sequence_Scores_"+ collection_base_name
    score_collection_name_top = "Sequence_Scores_"+ collection_base_name +"_top"
    scores_collection = db[score_collection_name]
    scores_collection_top = db[score_collection_name_top]
    

    #entries_collection = db['Sequence_Entries_P53_01']

    #bulk insert all entries
    #sequence_dict is a dict with the key as the name and the entries as the
    #entries
    #for key in self.sequence_dict:
      #entries_collection.insert(self.sequence_dict[key])

    score_dict_list = []
    #insert scores
    for key in family_scores:
      ref_dict = family_scores[key]
      score_dict = {}
      score_dict['name'] = ref_dict['seq_name']
      score_dict['senspec_fam'] = ref_dict['senspec']
      score_dict['specificity_fam'] = ref_dict['specificity']
      score_dict['sensitivity_fam'] = ref_dict['sensitivity']
      score_dict['repeats_fam'] = ref_dict['repeats']

      if individual_scores:
        additional_info = individual_scores[key]
        score_dict['senspec'] = additional_info["senspec"]
        score_dict['specificity'] = additional_info["specificity"]
        score_dict['sensitivity'] = additional_info["sensitivity"]
        score_dict['repeats'] = additional_info["repeats"]

      score_dict_list.append(score_dict)
    score_dict_list = sorted(score_dict_list, key=lambda k: k['senspec_fam'],reverse=True)
    
    print(score_dict_list)
    #scores_collection_top.insert(score_dict_list[0:100])
    #scores_collection.insert(score_dict_list[100:])
    scores_collection_top.insert(score_dict_list[0:1])
    scores_collection.insert(score_dict_list[1:])
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

  def get_ontarget_motifs(self,entry_list, motif_family, any_contains):
    if any_contains:
      ontargets = (item for item in entry_list if any(motif in item['motif_name'] for motif in motif_family))
    if not any_contains:
      ontargets = (item for item in entry_list if (item['motif_name'].endswith(tuple(motif_family))))
    return ontargets
    # search list of dicts, motif_name section.
    # get all dicts that have a certain motif name

  def get_offtarget_motifs(self,entry_list, motif_family, any_contains):
    if any_contains:
      offtargets = (item for item in entry_list if not any(motif in item['motif_name'] for motif in motif_family))
    if not any_contains:
      offtargets = (item for item in entry_list if not (item['motif_name'].endswith(tuple(motif_family))))
    return offtargets
    # search list of dicts, motif_name section.
    # get all dicts that have a certain motif name

