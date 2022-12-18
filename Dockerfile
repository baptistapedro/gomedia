FROM ubuntu:20.04 as builder

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get install -y build-essential tzdata pkg-config \
	wget clang git

RUN wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

ADD . /gomedia
WORKDIR /gomedia
ADD fuzzers/fuzz_mp4demux.go ./fuzzers/
WORKDIR ./fuzzers/
RUN go mod init myfuzz
RUN go get github.com/dvyukov/go-fuzz/go-fuzz-dep
RUN go get github.com/yapingcat/gomedia/go-mp4
RUN go build -o ./fuzzMp4demux

RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/mp4/h264-aac-publicdomain-sample.mp4
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/mp4/mozilla/A4.mp4
RUN wget https://github.com/strongcourage/fuzzing-corpus/raw/master/mp4/mozilla/aac-sample.mp4

FROM ubuntu:20.04
COPY --from=builder /gomedia/fuzzers/fuzzMp4demux /
COPY --from=builder /gomedia/fuzzers/*.mp4 /testsuite/

ENTRYPOINT []
CMD ["/fuzzMp4demux", "@@"]
