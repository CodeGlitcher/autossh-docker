FROM alpine

ENV LANG C.UTF-8

RUN apk add --no-cache tzdata jq openssh autossh bash
COPY run.sh /
RUN mkdir /example
COPY config-example.json /example
RUN chmod a+x /run.sh
VOLUME [ "/data" ]
CMD ["/run.sh" ]