#include <iostream>
#include <string>
#include <fstream>
#include <regex>
#include <vector>
#include <tuple>

using namespace std;

string translateToBH(string);

int main(int argc, char** argv) {
  if (argc < 3) {
    cout << "Please specify INPUT and OUTPUT files" << endl;
    return 1;
  }

  string inputFilename = argv[1];
  string outputFilename = argv[2];

  ifstream inputStream;
  inputStream.open(inputFilename);
  if (!inputStream.is_open()) {
    cout << "INPUT file cannot be opened" << endl;
  }

  ofstream outputStream;
  outputStream.open(outputFilename);
  if (!outputStream.is_open()) {
    cout << "OUTPUT file cannot be opened" << endl;
  }

  while(!inputStream.eof()) {
    string line;
    getline(inputStream, line);
    line = translateToBH(line);
    outputStream << line << endl;
  }

  inputStream.close();
  outputStream.close();
}

vector<pair<regex, string>> mappingRules {
  {regex("x"), "s"},
  {regex("X"), "S"},
  {regex("k(h|H)"), "x"},
  {regex("K(h|H)"), "X"},
  {regex("c(?!(h|H))|q"), "k"},
  {regex("C(?!(h|H))|Q"), "K"},
  {regex("t(r|R)|c(h|H)"), "c"},
  {regex("T(r|R)|C(h|H)"), "C"},
  {regex("d|g(i|I)|r"), "z"},
  {regex("D|G(i|I)|R"), "Z"},
  {regex("g(i|ì|í|ỉ|ĩ|ị|I|Ì|Í|Ỉ|Ĩ|Ị)"), "z$1"},
  {regex("G(i|ì|í|ỉ|ĩ|ị|I|Ì|Í|Ỉ|Ĩ|Ị)"), "Z$1"},
  {regex("đ"), "d"},
  {regex("Đ"), "D"},
  {regex("p(h|H)"), "f"},
  {regex("P(h|H)"), "F"},
  {regex("n(g|G)(h|H)?"), "q"},
  {regex("N(g|G)(h|H)?"), "Q"},
  {regex("(g|G)(h|H)"), "$1"},
  {regex("t(h|H)"), "w"},
  {regex("T(h|H)"), "W"},
  {regex("(n|N)(h|H)"), "$1'"}
};

string translateToBH(string input) {
  for (auto pair : mappingRules) {
    auto regx = pair.first;
    auto replace = pair.second;

    input = regex_replace(input, regx, replace);
  }

  return input;
}