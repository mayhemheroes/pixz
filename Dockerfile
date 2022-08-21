FROM fuzzers/afl:2.52

RUN apt-get update
RUN apt install -y  build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev libjpeg-dev  autoconf autogen asciidoc libarchive-dev pkg-config liblzma-dev
RUN  git clone    https://github.com/vasi/pixz.git
WORKDIR /pixz
RUN ./autogen.sh
RUN ./configure CC=afl-clang CXX=afl-clang++
RUN make
RUN make install
RUN mkdir /xzCorpus
RUN wget  https://github.com/strongcourage/fuzzing-corpus/blob/master/tar/small_archive.tar
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-1-check-sha256.xz
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-0-empty.xz
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-1-block_header-1.xz
RUN mv *.xz /xzCorpus


ENTRYPOINT ["afl-fuzz", "-i", "/xzCorpus", "-o", "/xzOut"]
CMD  ["/pixz/src/pixz", "@@", "out.tpxz"]
