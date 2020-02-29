FROM alpine

ENV LANG C.UTF-8

RUN apk add --no-cache tzdata jq openssh autossh

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]