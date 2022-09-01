<div align="center">
<h1>Hệ thống dịch máy từ <i>Tiếq Việt</i> sang <i>Tiếng Việt</i></h1>
<h3>Hệ wốq zịc máy từ <i>Tiếq Việt</i> saq <i>Tiếng Việt</i></h3>
</div>

# Vì sao lại có cái này?
- Mình muốn làm một toy project để nghịch chút xíu để chuẩn bị cho khóa luận sắp tới về dịch máy thống kê (SMT).
- Mình không biết ngoại ngữ nào khác ngoài tiếng Anh và tiếng Nhật nên khó đánh giá chất lượng của mô hình sau khi train xong. Corpus song ngữ của Anh/Việt/Nhật thì kiếm hơi khó, hơn nữa chúng khác typology nên chất lượng mô hình nếu không tune thì sẽ cho kết quả không cao. Nên mình chọn con đường "dễ" hơn chút: dịch tiếng Việt Bùi Hiền (_tiếq Việt_) về lại tiếng Việt. 

- Để dịch từ _tiếng Việt_ sang _tiếq Việt_ thì khá dễ, cách đây vài năm đã có nhiều người viết các công cụ tương tự rồi. Dễ thấy, ánh xạ từ _tiếng Việt_ sang _tiếq Việt_ là one-to-one, có nghĩa là một chữ trong _tiếng Việt_ chỉ dịch ra được một chữ tương ứng trong _tiếq Việt_. Hệ thống dịch siêu đơn giản này được implement ở file [tieqviet.cpp](tieqviet.cpp).
- Ngược lại, ánh xạ từ _tiếq Việt_ sang _tiếng Việt_ lại là one-to-many, ví dụ: _"cuq"_ có thể là _"trung"_ hoặc _"chung"_. Ta không thể tạo ra một hệ thống luật đơn giản để dịch được, mà phải dựa vào các từ xung quanh (ngữ cảnh). Ví dụ: _"cuq kư"_ thì chỉ có thể là _"chung cư"_.

- Hệ thống dịch được sử dụng là [Moses](http://www2.statmt.org/moses/). Mô hình mình làm ở đây chỉ là baseline, không tune gì cả nhưng BLEU score được tận 95.93. Cũng dễ hiểu vì tiếq Việt và tiếng Việt vốn là... cùng một ngôn ngữ.

# Ngữ liệu 
- **Tiếng Việt**: ngữ liệu được lấy từ V1 [binhvq/news-corpus](https://github.com/binhvq/news-corpus) gồm khoảng 100 triệu câu.
- **Tiếq Việt**: tổng hợp từ ngữ liệu tiếng Việt.

# Thành phần trong repository này
- `tieqviet.cpp`: module "dịch" từ tiếng Việt sang tiếq Việt, là bản port C++ của module [phanan/tieqviet](https://github.com/phanan/tieqviet).   
  Regex của Python rất chậm nên mình không dùng Python để làm việc này.
- `tok.py`: module thực hiện tokenize câu tiếng Việt. Cần cài dependency: `pip install underthesea`.

# Chuẩn bị môi trường 

1. Cài đặt moses. Ở đây cho nhanh thì mình sử dụng Docker image [amake/moses-smt](https://hub.docker.com/r/amake/moses-smt).
   ```bash
   docker pull amake/moses-smt:base
   ```

# Sử dụng mô hình train sẵn 
Đây là mô hình đã được mình train và binarize trên 200.000 câu sample từ tập dữ liệu trên, 10.000 câu để test với BLEU score 95.93.

1. Tải file `tieqviet-tiengviet.tar.gz` ở mục releases.
2. Chạy container
   ```bash 
   docker run --name tieqviet --rm -it amake/moses-smt:base /bin/bash
   ```
3. Giải nén và copy model vào `~/binarised-model` trong container. 
4. Tạo file `~/binarised-model/test.bh`, ghi mỗi câu tiếng Bùi Hiền trên 1 dòng. Lưu ý các câu này phải đúng "định dạng": các từ ghép phải có gạch dưới `_`, và các dấu câu phải cách các từ bên trái và bên phải bằng khoảng trắng. Một số ví dụ:

    | Tiếq Việt | Tiếng Việt (được dịch) |
    | -- | -- |
    | Coq cườq_hợp kủa Ủy_ban , xi fải zải_cìn' các_n'iệm cướk Cín'_fủ qĩa_là họ n'ân_zan'_lợi_íc kủa Cín'_fủ | Trong trường_hợp của Ủy_ban , khi phải giải_trình trách_nhiệm trước Chính_phủ nghĩa_là họ nhân_danh_lợi_ích của Chính_phủ |
    | Tôi là sin'_viên kủa cuờq Đại_họk Xoa_họk Tự_n'iên wàn'_fố Hồ_Cí_Min' | Tôi là sinh_viên của truờng **Đại_họk** Khoa_học Tự_nhiên thành_phố Hồ_Chí_Minh |
    | Kousaka_Honoka là n'ân_vật cín' kủa hàq_loạt sản_fẩm kủa Love Live . Kô là họk_sin' năm hai kủa Cườq Kao cuq Otonokizaka . Honoka kó mái_tók màu kam buộk ở một bên dầu ( cừa fần tók_gáy ) và dôi mắt màu san' biển . Màu_sắk dại_ziện co kô là màu kam , dôi_xi kó một_số qười cọn màu hồq co kô . Kô là n'óm_cưởq kủa hai n'óm n'ạk : μ ' s và một fân n'óm kủa nó là Printemps . | Kousaka_Honoka là nhân_vật chính của hàng_loạt sản_phẩm của Love Live . Cô là học_sinh năm hai của Trường **Cao chung** Otonokizaka . Honoka có mái_tóc màu cam buộc ở một bên đầu ( chừa phần tóc_gáy ) và đôi mắt màu xanh biển . Màu_sắc đại_diện cho cô là màu cam , đôi_khi có một_số người chọn màu hồng cho cô . Cô là nhóm_trưởng của hai nhóm nhạc : μ ' x và một phân nhóm của nó là Printemps .

5. Predict 
   ```bash 
   /opt/bin/moses/bin/moses                    \
        -f ~/binarised-model/moses.ini         \
        < ~/binarised-model/test.bh            \
        > ~/binarised-model/test.predict.vi    
   ```

# Tự train mô hình
## Chuẩn bị dữ liệu

Trước tiên cần chuẩn bị thêm:
1. Tạo một volume để chứa dữ liệu sau khi training, không bị mất sau khi thoát Docker
   ```bash
   docker volume create tieqviet
   ```
2. Biên dịch chương trình `tieqviet`:
   ```bash
   g++ tieqviet.cpp -o tieqviet
   ```

Để dễ minh họa, mình xin gọi file chứa corpus tiếng Việt gốc chúng ta đang có là `corpus.vi`.

Bước chuẩn bị dữ liệu gồm 3 bước nhỏ là:
- **tokenization**: tách từ, thêm khoảng trắng vào giữa các dấu câu. Với tiếng Việt ta còn thêm dấu gạch nối giữa 2 tiếng của cùng một từ. Ví dụ: cảnh sát -> cảnh_sát, nhà nước -> nhà_nước.
- **truecasing**: đưa tất cả từ về case "đúng" với nó nhất. Ví dụ: Cảnh sát -> cảnh sát, việt nam -> Việt Nam.
- **cleaning**: xóa bớt các câu dài.

Ở đây vì tính "đặc biệt" của bài toán nên ta sẽ có một chút khác biệt ở phần tokenize, đó là thay vì chạy tokenizer trên cả 2 ngôn ngữ, thì ta sẽ chỉ chạy tokenize trên tiếng Việt, sau đó "dịch" corpus này sang tiếng Bùi Hiền. Lúc đó corpus tiếng BH thu được cũng đã được tokenize.

1. Tokenize: 
   ```bash
   python3 tok.py corpus.vi corpus.tok.vi
   ```
2. Dịch sang tiếng Bùi Hiền: 
   ```bash 
   ./tieqviet corpus.tok.vi corpus.tok.bh
   ```

3. Khởi động container và copy dữ liệu vào môi trường làm việc
    ```bash 
    docker run --name tieqviet -itv tieqviet:/working amake/moses-smt:base /bin/bash
    ```

  - Tạo symlink cho thư mục chứa moses để dễ gọi:
    ```bash
    ln -s /opt/bin/moses ~/mosesdecoder 
    ln -s /opt/bin/tools ~/mosesdecoder/tools 
    ```
  - Tạo thư mục chứa corpus: 
    ```bash
    cd /working
    mkdir corpus
    ```
  - Mở một tab terminal khác và copy dữ liệu đã chuẩn bị vào: 
      ```bash 
      docker cp corpus.tok.vi tieqviet:/working/corpus
      docker cp corpus.tok.bh tieqviet:/working/corpus
      ```

4. Truecasing 
  - Thống kê tần suất xuất hiện của các trường hợp hoa/thường trong ngữ liệu
    ```
    ~/mosesdecoder/scripts/recaser/train-truecaser.perl   \
      --model /working/corpus/truecase-model.vi --corpus  \
      /working/corpus/corpus.tok.vi

    ~/mosesdecoder/scripts/recaser/train-truecaser.perl   \
      --model /working/corpus/truecase-model.bh --corpus  \
      /working/corpus/corpus.tok.bh
    ```

  - Thực hiện truecasing: 
    ```bash 
    ~/mosesdecoder/scripts/recaser/truecase.perl \
      --model /working/corpus/truecase-model.vi  \
      < /working/corpus/corpus.tok.vi \
      > /working/corpus/corpus.true.vi

    ~/mosesdecoder/scripts/recaser/truecase.perl \
      --model /working/corpus/truecase-model.bh  \
      < /working/corpus/corpus.tok.bh \
      > /working/corpus/corpus.true.bh
    ```

  - Thực hiện cleaning, giới hạn số từ mỗi câu lại thành 40 từ:
    ```bash
    ~/mosesdecoder/scripts/training/clean-corpus-n.perl \
      /working/corpus/corpus.true vi bh                 \
      /working/corpus/corpus.clean 1 40
    ```

## Train mô hình ngôn ngữ 

Bài toán dịch máy thống kê từ câu `f` trong ngôn ngữ `F` sang ngôn ngữ `E` là bài toán tìm câu `e*` sao cho: `e* = argmax(e, p(e|f)) = argmax(e, p(f|e)p(e))`.

Language model cho ta ước lượng xác suất `p(e)`, tức là xác suất một câu `e` nào đó là câu hợp lệ trong ngôn ngữ đích.

1. Ở đây ta sẽ sử dụng mô hình KenLM để xây dựng language model
    ```bash 
    mkdir /working/lm 
    cd /working/lm 
    ~/mosesdecoder/bin/lmplz -o 3 < /working/corpus/corpus.true.vi > corpus.arpa.vi
    ```

2. Language model thu được ở bước trước sẽ ở dạng text. Ta cần convert nó sang dạng binary để quá trình training sau này diễn ra nhanh hơn:
    ```bash 
    ~/mosesdecoder/bin/build_binary    \
        corpus.arpa.vi \
        corpus.blm.vi
    ```
## Train mô hình dịch 

Mô hình dịch (translation model) sẽ cho ta ước lượng của xác suất `p(f|e)` (likelihood), tức xác suất mà câu gốc thực sự là bản dịch của câu ngôn ngữ đích.

```bash 
cd /working

nice ~/mosesdecoder/scripts/training/train-model.perl -root-dir train      \
    -corpus /working/corpus/corpus.clean                                        \
    -f bh -e vi -alignment grow-diag-final-and -reordering msd-bidirectional-fe \
    -lm 0:3:/working/lm/corpus.blm.vi:8                                         \
    -mgiza -mgiza-cpus 12                                                       \
    -parallel                                                                   \
    -external-bin-dir ~/mosesdecoder/tools
```
Quá trình train mất 22 phút trên laptop mình dùng Ryzen 5 4650U (6C12T), 16 GB RAM. Bạn có thể chỉnh số nhân CPU dùng cho MGIZA bằng tham số `-mgiza-cpus`. 

## Tuning 
Xem thêm trong docs của [Moses](http://www2.statmt.org/moses/?n=Moses.Baseline).

## Nén model 
Model thu được rất nặng, ta cần nén lại trước khi gọi moses decoder. Nếu ta load mô hình raw lên thì máy sẽ bị tràn RAM (với RAM 16 GB của mình).

1. Chạy các lệnh
    ```bash 
    mkdir /working/binarised-model
    cd /working

    ~/mosesdecoder/bin/processPhraseTableMin \
        -in train/model/phrase-table.gz -nscores 4 \
        -out binarised-model/phrase-table
        
    ~/mosesdecoder/bin/processLexicalTableMin \
        -in train/model/reordering-table.wbe-msd-bidirectional-fe.gz \
        -out binarised-model/reordering-table
    ```

2. Copy file `moses.ini` từ thư mục chứa model sang `binarises-model`:
   ```bash 
   cp train/model/moses.ini binarised-model
   ```

3. Mở file `binarised-model/moses.ini` lên, sửa lại các thông tin sau:
- Khoảng dòng 21: sửa `PhraseDictionaryMemory` thành `PhraseDictionaryCompact`.
- Ở cùng dòng, sửa `path` lại thành `/working/binarised-model/phrase-table.minphr`
- Ở vài dòng tiếp theo bắt đầu bằng `LexicalReordering`, sửa `path` lại thành `/working/binarised-model/reordering-table`.

4. Khởi động decoder:
    ```bash 
    ~/mosesdecoder/bin/moses -f /working/binarised-model/moses.ini
    ```

5. Nhập câu _tiếq Việt_ vào thôi. 


## Test 
Bằng cách tương tự, ta có thể sample một ít dữ liệu từ corpus gốc để làm test set (ở đây mình lấy 10.000 dòng).

Giả sử 2 file test set mình có được là `test.tok.vi` và `test.tok.bh` 

1. Chạy lại truecaser:
    ```
    cd /working/corpus
    ~/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.vi \
        < test.tok.vi > test.true.vi
        
    ~/mosesdecoder/scripts/recaser/truecase.perl --model truecase-model.bh \
        < test.tok.bh > test.true.bh
    ```

2. Predict  
    ```bash
    nice ~/mosesdecoder/bin/moses                      \
        -f /working/binarised-model/moses.ini          \
        < /working/corpus/test.true.bh                 \
        > /working/test.predict.vi                     \
    ```
3. Tính BLEU score

    ```bash 
    ~/mosesdecoder/scripts/generic/multi-bleu.perl    \
        -lc /working/corpus/test.true.vi              \
        < /working/test.predict.vi
    ```

    Kết quả: 95.93. Khá ấn tượng! Vì đây là mô hình baseline, chưa tune gì cả.