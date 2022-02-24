FROM golang:1.16 as builder
WORKDIR /go/src/github.com/oliver006/drone-gcf

ARG SHA1
ENV SHA1=$SHA1
ARG TAG
ENV TAG=$TAG

ADD . /go/src/github.com/oliver006/drone-gcf/
RUN BUILD_DATE=$(date +%F-%T) && CGO_ENABLED=0 GOOS=linux go build -o drone-gcf \
    -ldflags "-s -w -extldflags \"-static\" -X main.BuildHash=$SHA1 -X main.BuildTag=$TAG -X main.BuildDate=$BUILD_DATE" .
RUN ./drone-gcf -v


FROM       gcr.io/google.com/cloudsdktool/cloud-sdk:374.0.0-slim as release
RUN        apt-get -y install ca-certificates
COPY       --from=builder /go/src/github.com/oliver006/drone-gcf/drone-gcf /bin/drone-gcf
ENTRYPOINT /bin/drone-gcf
