FROM debian:bookworm-slim

RUN apt update && apt install -y git && apt clean

EXPOSE 22