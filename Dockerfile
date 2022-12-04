FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y  build-essential wget git clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev autoconf autogen asciidoc libarchive-dev pkg-config liblzma-dev
ADD . /pixz
WORKDIR /pixz
RUN ./autogen.sh
RUN ./configure CC=afl-clang CXX=afl-clang++
RUN make
RUN make install
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/tar/small_archive.tar
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-1-check-sha256.xz
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-0-empty.xz
RUN wget https://github.com/strongcourage/fuzzing-corpus/blob/master/xz/good-1-block_header-1.xz

FROM fuzzers/afl:2.52
RUN apt-get update && apt-get install -y libarchive-dev
COPY --from=builder /pixz/src/pixz /
COPY --from=builder /pixz/*.xz /testsuite/
COPY --from=builder /usr/local/lib/* /usr/local/lib/

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite/", "-o", "/xzOut"]
CMD  ["/pixz", "@@", "/dev/null"]
