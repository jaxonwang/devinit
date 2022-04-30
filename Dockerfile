FROM ubuntu:latest
COPY ./setup.sh ./setup.sh
RUN bash ./setup.sh
CMD bash
