#ifndef SEQUENCEGENERATOR_H
#define SEQUENCEGENERATOR_H

#include <iostream>
#include <string>
#include <boost/numeric/ublas/matrix.hpp>
#include <regex>
#include <boost/regex.hpp>
#include <boost/algorithm/string/find.hpp>
#include <boost/random.hpp>
#include <boost/generator_iterator.hpp>

struct Pwm_Info {
  std::string motif_name;
  int width;
  //boost::numeric::ublas::matrix<double> PWM();
  std::vector<double> pwm;
}tf_info;

Pwm_Info get_pwm_info(std::string library_data, std::string motif_name);

typedef boost::mt19937 RNGType;

std::string generate_likely_sequence(struct Pwm_Info tf_info, int max_seq_length, boost::variate_generator<RNGType, boost::uniform_int<>> random_gen);

#endif
