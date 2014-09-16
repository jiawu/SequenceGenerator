#!/usr/bin/python
from pymongo import MongoClient

def remove_from_collection(self, db_name, collection_name, search_string):
  mongo_client = MongoClient('hera.chem-eng.northwestern.edu',27017)
  db = mongo_client[db_name]
  collection = db[collection_name]

  collection.remove({'sequence_name':search_string})


