#!/usr/bin/bash

# Thư mục chứa corpus
CORPUS_DIR=~/corpus

# Tên của 2 loại file corpus cho train và test. Không nhập các phụ tố như .tok, .. vào 2 biến này
# Ở đây mặc định train và test corpus đã được tokenize sẵn, tức các file tồn tại trên hệ thống phải có đuôi .tok.vi, .tok.bh

## SCRIPT NÀY MẶC ĐỊNH TÊN CÁC TẬP TIN ĐƯỢC ĐẶT THEO ĐỊNH DẠNG: train.tok.bh, train.tok.vi, ... 
## VÀ LANGUAGE CODE LÀ bh VÀ vi

TRAIN_CORPUS_BASENAME=train
TEST_CORPUS_BASENAME=test
TUNE_CORPUS_BASENAME= # TBI

# Số nhân CPU dùng cho MGIZA++ (cho quá trình word alignment)
MGIZA_CPUS=8
# Số n-gram dùng khi build language model
LM_NGRAMS=3

# Thư mục chứa model và các file tạm
WORKING_DIR=~/working

## Không sửa 2 biến dưới
LM_DIR=$WORKING_DIR/lm
BIN_LM_DIR=$LM_DIR/binarised-model

CLEANING_MAX_LENGTH=40
CLEANING_MIN_LENGTH=1

MOSES_DIR=/opt/bin/moses
EXTERNAL_BIN_DIR=/opt/bin/tools

if [[ -d "$CORPUS_DIR" ]]; then 
  echo "Corpus directory does not exist. Make sure you specified the correct path and the train/test bitext files are present!"
  exit 1
fi

if [[ -d "$WORKING_DIR" ]]; then 
  mkdir -p $WORKING_DIR
fi

#####################
# TRAIN TRUECASER 

function train_truecaser() {
  local LANG_CODE=$1
  echo "Training truecaser for language $LANG_CODE..."

  $MOSES_DIR/scripts/recaser/train-truecaser.perl   \
  --model "$CORPUS_DIR/truecase-model.$LANG_CODE" --corpus  \
  "$CORPUS_DIR/$TRAIN_CORPUS_BASENAME.tok.$LANG_CODE"
}

#####################
# PERFORM TRUECASING

function perform_truecasing() {
  local LANG_CODE=$1
  local BASE_NAME=$2
  echo "Performing truecasing for language $LANG_CODE..."

  $MOSES_DIR/scripts/recaser/truecase.perl \
    --model "$CORPUS_DIR/truecase-model.$LANG_CODE"  \
    < "$CORPUS_DIR/$BASE_NAME.tok.$LANG_CODE" \
    > "$CORPUS_DIR/$BASE_NAME.true.$LANG_CODE"
}

#####################
# PERFORM CLEANING

function perform_cleaning() {
  local BASE_NAME=$1
  echo "Performing cleaning..."

  $MOSES_DIR/scripts/training/clean-corpus-n.perl   \
    "$CORPUS_DIR/$BASE_NAME.true" vi bh \
    "$CORPUS_DIR/$BASE_NAME.clean" $CLEANING_MIN_LENGTH $CLEANING_MAX_LENGTH
}

#####################
# TRAIN LANGUAGE MODEL

function train_language_model() {
  echo "Training language model for target language..."

  if [[ -d "$LM_DIR "]]; then 
    mkdir -p $LM_DIR 
  fi 

  cd $LM_DIR

  # Train
  $MOSES_DIR/bin/lmplz -o $LM_NGRAMS \
    < "$CORPUS_DIR/$TRAIN_CORPUS_BASENAME.true.vi" \
    > "$LM_DIR/$TRAIN_CORPUS_BASENAME.arpa.vi"
  
  # Binarize
  $MOSES_DIR/bin/build_binary    \
    "$LM_DIR/$TRAIN_CORPUS_BASENAME.arpa.vi" \
    "$LM_DIR/$TRAIN_CORPUS_BASENAME.blm.vi"
}

#####################
# TRAIN TRANSLATION MODEL

function train_translation_model() {
  cd $WORKING_DIR/lm 

  nice $MOSES_DIR/scripts/training/train-model.perl -root-dir train             \
    -corpus "$CORPUS_DIR/$TRAIN_CORPUS_BASENAME.clean"                          \
    -f bh -e vi -alignment grow-diag-final-and -reordering msd-bidirectional-fe \
    -lm "0:3:$LM_DIR/$TRAIN_CORPUS_BASENAME.blm.vi:8"                           \
    -mgiza -mgiza-cpus $MGIZA_CPUS                                              \
    -parallel                                                                   \
    -external-bin-dir $EXTERNAL_BIN_DIR
}

function compress_translation_model() {
  if [[ -d "$BIN_LM_DIR" ]]; then 
    mkdir $BIN_LM_DIR
  fi

  $MOSES_DIR/bin/processPhraseTableMin \
    -in "$LM_DIR/train/model/phrase-table.gz" -nscores 4 \
    -out "$BIN_LM_DIR/phrase-table"
    
  $MOSES_DIR/bin/processLexicalTableMin \
      -in "$LM_DIR/train/model/reordering-table.wbe-msd-bidirectional-fe.gz" \
      -out "$BIN_LM_DIR/reordering-table"

  cp "$LM_DIR/train/model/moses.ini" "$BIN_LM_DIR"
  sed -i "s/PhraseDictionaryMemory/PhraseDictionaryCompact/g" "$BIN_LM_DIR/moses.ini"
  
  sed -iE "s|path=(.*)/phrase-table\.gz|path=$BIN_LM_DIR/phrase-table.minphr|g" \
    "$BIN_LM_DIR/moses.ini"

  sed -iE "s|path=(.*)/reordering-table(.*)\.gz|path=$BIN_LM_DIR/reordering-table|g" \
    "$BIN_LM_DIR/moses.ini"
}

function perform_test() {
  echo "Running test..."
  # Truecase for test data
  perform_truecasing "vi" "$TEST_CORPUS_BASENAME"
  perform_truecasing "bh" "$TEST_CORPUS_BASENAME"

  # Clean
  perform_cleaning "$TEST_CORPUS_BASENAME"

  # Predict
  nice $MOSES_DIR/bin/moses                         \
    -f "$BIN_LM_DIR/moses.ini"                      \
    < "$CORPUS_DIR/$TEST_CORPUS_BASENAME.clean.bh"  \
    > "$WORKING_DIR/predicted.vi"

  # Calculate BLEU
  $MOSES_DIR/scripts/generic/multi-bleu.perl         \
    -lc "$CORPUS_DIR/$TEST_CORPUS_BASENAME.clean.vi" \
    < "$WORKING_DIR/predicted.vi"                    \
    &> "$WORKING_DIR/bleu-score"
}


##############
# MAIN

train_truecaser "vi"
train_truecaser "bh"

perform_truecasing "vi" "$TRAIN_CORPUS_BASENAME"
perform_truecasing "bh" "$TRAIN_CORPUS_BASENAME"

perform_cleaning "$TRAIN_CORPUS_BASENAME"

train_language_model
train_translation_model
compress_translation_model

perform_test