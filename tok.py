import sys
import traceback
from tqdm import tqdm
from underthesea import word_tokenize

def main(argv):
  input_file = argv[1]
  output_file = argv[2]

  try:
    fi = open(input_file,'rt')
    fo = open(output_file, 'wt')

    first = True
    for line in tqdm(fi.readlines()):
      tokenized = word_tokenize(line, format='text')
      
      if first:
        first = False
      else: 
        fo.write('\n')

      fo.write(tokenized)
  except Exception:
    print(traceback.format_exc())
  finally:
    fi.close()
    fo.close()

if __name__ == '__main__':
  if len(sys.argv) < 3:
    print('Please specify INPUT and OUTPUT file')
  else:
    main(sys.argv)