#include <iostream>
#include <string>
#include <boost/numeric/ublas/matrix.hpp>
#include <regex>
#include <boost/regex.hpp>
#include <boost/algorithm/string/find.hpp>
#include "strtk.hpp"

//Gameplan:
//read pwm file
//create PWM array
//typedefs go here
typedef boost::mt19937 RNGType;

struct Pwm_Info {
  std::string motif_name;
  int width;
  //boost::numeric::ublas::matrix<double> PWM();
  std::vector<double> pwm;
  Pwm_Info() : motif_name(0), width(0), pwm(0) {}
}TF_info;

//forward declarations go here
std::string make_binding_site(Pwm_Info tf_info, boost::variate_generator<RNGType, boost::uniform_int<>> random_gen);

std::string make_spacer(boost::variate_generator <RNGType, boost::uniform_int<>> random_gen);

std::string make_polya_tail(boost::variate_generator<RNGType, boost::uniform_int<>> random_gen);

bool check_length(std::string seq, int max_seq_length) {
  if (seq.length() >= max_seq_length)
    return false;
  else
    return true;
}

//functions go down here
std::string generate_likely_sequence(struct Pwm_Info tf_info, int max_seq_length, boost::variate_generator <RNGType, boost::uniform_int<>> random_gen) {
  std::string final_seq;
  double outcome;
  //Add first sequence with 50% chance of adding a spacer.
  outcome = 1 + round(random_gen()/100.0 * 1.0);
  random_gen();

  if (outcome == 1) {
    final_seq = final_seq + make_spacer(random_gen);
    random_gen();
    final_seq = final_seq + make_binding_site(tf_info, random_gen);
    random_gen();
  } else {
    final_seq = final_seq + make_binding_site(tf_info, random_gen);
  }

  //Adding the second sequence with 80% chance
  random_gen();
  outcome = 1 + round(random_gen()/100.0 * 10.0);
  random_gen();  
  if (outcome < 9) {
    if (check_length(final_seq, max_seq_length)) {
      outcome = 1 + round(random_gen()/100.0 * 1.0);
      random_gen();
      if(outcome == 1) {
        final_seq = final_seq + make_spacer(random_gen);
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      } else {
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      }
    }
  }
  //Adding the third sequence with 80% chance
  random_gen();
  outcome = 1 + round(random_gen()/100.0 * 10.0);
  random_gen();  
  if (outcome < 9) {
    if (check_length(final_seq, max_seq_length)) {
      outcome = 1 + round(random_gen()/100.0 * 1.0);
      random_gen();
      if(outcome == 1) {
        final_seq = final_seq + make_spacer(random_gen);
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      } else {
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      }
    }
  }

  //Adding the fourth seqeuence with 33% chance;
  random_gen();
  outcome = 1 + round(random_gen()/100.0 * 2.0);
  random_gen();  
  if (outcome ==1) {
    if (check_length(final_seq, max_seq_length)) {
      outcome = 1 + round(random_gen()/100.0 * 1.0);
      random_gen();
      if(outcome == 1) {
        final_seq = final_seq + make_spacer(random_gen);
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      } else {
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      }
    }
  }
  //Adding the 5th sequence with 10% chance;
  random_gen();
  outcome = 1 + round(random_gen()/100.0 * 9.0);
  random_gen();  
  if (outcome ==1) {
    if (check_length(final_seq, max_seq_length)) {
      outcome = 1 + round(random_gen()/100.0 * 1.0);
      random_gen();
      if(outcome == 1) {
        final_seq = final_seq + make_spacer(random_gen);
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      } else {
        random_gen();
        final_seq = final_seq + make_binding_site(tf_info,random_gen);
      }
    }
  }

  if(check_length(final_seq, max_seq_length)) {
    outcome = 1 + round(random_gen()/100.0 * 1.0);
    random_gen();
    if(outcome == 1) {
      final_seq = final_seq + make_spacer(random_gen);
    }
  }
  // mutate the sequences randomly
  int current_seq_length = final_seq.length();
  int max_mutation = round(max_seq_length * 0.05);
  std::string possible_nucleotides = "ACGT";
  std::vector<int> result;
  for (int i = 0; i <= current_seq_length; ++i)
  {
    result.push_back(i);
  }
  std::srand(random_gen());
  std::random_shuffle(result.begin(), result.end());

  // Truncate to the requested size.
  result.resize(max_mutation);
  
  int current_index;
  std::string current_nucleotide;
  std::string mutated_nucleotide;
  random_gen();
  for ( int x = 0; x < result.size(); x++ ) {
    current_index = result[x];
    current_nucleotide = final_seq[current_index];
    mutated_nucleotide = current_nucleotide;
    while (mutated_nucleotide == current_nucleotide) {
      outcome = round(random_gen()/100.0 * 3.0);
      //pick a random number
      mutated_nucleotide = possible_nucleotides[outcome];
    }
    final_seq.replace(current_index,1, mutated_nucleotide);
  }

  //fuck. i didn't make random_gen something that's global and resets itself
  //so here i am resetting the seed. sorry. its either this or pass back
  //random_gen() from the function call.
  return final_seq;
}

std::string make_polya_tail(boost::variate_generator<RNGType, boost::uniform_int<>> random_gen) {
  std::string polya_seq;
  polya_seq.reserve(12);
  double outcome;
  outcome = random_gen()/100.0 * 12.0;
  while (outcome < 5.0) {
    outcome = random_gen()/100.0 * 12.0;
  }
  for(int ii = 0; ii < outcome; ii++) {
    polya_seq = polya_seq + "A";
  }
  return polya_seq;
}

std::string make_binding_site(Pwm_Info tf_info, boost::variate_generator<RNGType, boost::uniform_int<>> random_gen) {
  std::string binding_seq;
  
  int width = tf_info.width;
  std::vector<double> pwm = tf_info.pwm;
  double outcome; // our "dice"
  
  binding_seq.reserve(width);

  for (int position = 0; position < width; position++) {
    //so pwms are a list of X numbers. 0 + X*4, 1+ X*4, 2+X*4, 3+X*4
    double A = pwm[position*4];
    double C = pwm[position*4 +1];
    double G = pwm[position*4 +2];
    double Tt = pwm[position*4 +3];
    //not sure why it's Tt, this is an artifact from the R code
    outcome = random_gen()/100.0;
    if(outcome <= A) { binding_seq = binding_seq + "A";}
    if(outcome <= A+C and outcome > A) { binding_seq = binding_seq + "C";}
    if(outcome <= A+C+G and outcome > A+C) { binding_seq = binding_seq + "G";}
    if(outcome <= A+C+G+Tt and outcome > A+C+G) { binding_seq = binding_seq + "T";}
  }
  return binding_seq;
}

std::string make_spacer(boost::variate_generator<RNGType, boost::uniform_int<>> random_gen) {
  int n_spacer = 1+round((random_gen()/100.0)*5.0);
  std::string spacer_seq;
  spacer_seq.reserve(n_spacer);
  int outcome;
  for (int i = 0; i < n_spacer; i++) {
    outcome = 1+round((random_gen()/100.0)*4.0);
    if(outcome == 1) {spacer_seq.append("A");}
    if(outcome == 2) {spacer_seq.append("T");}
    if(outcome == 3) {spacer_seq.append("C");}
    if(outcome == 4) {spacer_seq.append("G");}  
  }
  return spacer_seq;
}


Pwm_Info get_pwm_info(std::string library_data, std::string motif_name) {

  //Here's the part where it takes me a million lines to find a motif
  std::string motif_pattern = "MOTIF " + motif_name;

  int motif_start = library_data.find(motif_pattern);
  
  int motif_end = library_data.find("MOTIF ", motif_start+1);
  
  std::string motif_block;
  std::string pwm_block;

  if (motif_start != std::string::npos && motif_end != std::string::npos) {
    motif_block = library_data.substr(motif_start, motif_end-motif_start-1);
  }
  else {
    std::cout << "markers missing" << std::endl;
  }
  //std::cout << motif_block << std::endl;

  //start the regex. find w= for width
  //then find second \n, which is the start of the PWM.
  //then find the WIDTH-th \n, which is the end of the PWM

  boost::regex w_pattern("w= ([0-9]+)");
  boost::smatch width;
  std::string::const_iterator start,end;
  start = motif_block.begin();
  end = motif_block.end();
  
  //search the text for the width
  if (boost::regex_search(motif_block, width, w_pattern)) {
  }
  else
  {
    std::cout << "Can't find width" << std::endl;
  }
  int n_width = std::stoi(width[1]);
  //find second \n and nwidth-th row
  
  boost::iterator_range<std::string::iterator> r = boost::find_nth(motif_block, "\n", 1);
  boost::iterator_range<std::string::iterator> t = boost::find_nth(motif_block, "\n", n_width + 1);

  int pwm_start = std::distance(motif_block.begin(), r.begin());
  int pwm_end = std::distance(motif_block.begin(), t.begin());

  if (pwm_start != std::string::npos && pwm_end != std::string::npos) {
    pwm_block = motif_block.substr(pwm_start+1, pwm_end-pwm_start-1);
  }
  else {
    std::cout << "markers missing" << std::endl;
  }
  //std::cout << pwm_block << std::endl;

  //int x = std::stoi(width[1]) + 1;
  //std::cout << x << std::endl;
  
  //Okay time to split up PWM block into arrays...
  std::vector<double> double_list;
  strtk::parse(pwm_block," \n\r", double_list);
  //std::cout << double_list.size() << std::endl;

  //cast the vector into a 2D array
  //maybe I will do this in the future, for now it will be a 1D vector double
  
  Pwm_Info TF_info;

  // pwm_info: motif_name, width, pwm
  TF_info.motif_name = motif_name;
  TF_info.width = n_width;
  
  TF_info.pwm = double_list;

  //std::cout << TF_info.pwm[1] << std::endl;
  //TF_info.pwm.assign(double_list.begin(), double_list.end());

  return TF_info;
}



