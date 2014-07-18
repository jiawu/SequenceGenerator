#include <iostream>
#include <string>
#include <fstream>
#include "SequenceGenerator.h"
#include "boost/random.hpp"
#include "boost/generator_iterator.hpp"

int main(int argc, char* argv[])
{
  //Print Usage Information
  if (argc < 2) {
    std::cerr << "Usage:\n" << "seqGen outputfile libraryfile motifname #_of_seqs seq_length" << std::endl;
    return 1;
  }

  //Run Program
  std::string library_file;
  std::string motif_name;
  std::string library_data;
  std::string line;
  std::string out_file_name;
  Pwm_Info tf_info;
  int max_number_of_sequences = 100;
  int max_seq_length = 50;

  out_file_name = argv[1];
  library_file = argv[2];
  motif_name = argv[3];
  max_number_of_sequences = atoi(argv[4]);
  max_seq_length = atoi(argv[5]);

  std::ofstream outfile(out_file_name);
  if(!outfile.is_open()) {
    std::cerr << "Couldn't open 'output.txt'" << std::endl;
    return -1;
  }
  //std::cout << library_file << std::endl;
  
  std::ifstream infile (library_file.c_str());
  if (infile.is_open())
  {
    while (std::getline(infile, line))
    {
      library_data += line;
      library_data.push_back('\n');
    }
    infile.close();
  }
  //std::cout << library_data << std::endl;
  
  //use that get_pwm_info function
  tf_info = get_pwm_info(library_data, motif_name);

  std::string seq;
  //initiate a random number generator and use it back and forth multiple times

  typedef boost::mt19937 RNGType;
  RNGType rng;
  rng.seed(std::time(NULL) + getpid());
  boost::uniform_int<> one_to_hundred(1,100);
  boost::variate_generator< RNGType, boost::uniform_int<> > random_gen(rng, one_to_hundred);
  
  //random number test block
  //for (int tt = 0; tt < 8; tt++) {
  //  int n = random_gen();
  //  std::cout << n << std::endl;
  //}
  //
  std::clock_t start;
  start = std::clock();
  double duration;
  for (int ss = 0; ss < max_number_of_sequences; ss++) {
    random_gen();
    seq = generate_likely_sequence(tf_info, max_seq_length, random_gen);   
    outfile << ">" << motif_name<<"_s"<<ss<< "\n";
    outfile << seq << "\n";
    //std::cout << seq << "\n";
  }
  duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
  std::cout<<"printf: "<< duration <<'\n';
  outfile.close();
  
  return 0;
}


