# Use multi-stage building
FROM python:3-stretch as builder

# set workdir
WORKDIR /build

# install dependencies
RUN apt-get update && apt-get install -y \
    liblivemedia-dev \
    libjson-c-dev

# clone code
RUN git clone https://github.com/miguelangel-nubla/videoP2Proxy.git .

# build code
RUN ./autogen.sh
RUN make

# Build the production container
FROM python:3-stretch

# expose port
EXPOSE 8554

# install dependencies
RUN apt-get update && apt-get install -y \
    libjson-c3 \
    libbasicusageenvironment1 \
    libgroupsock8 \
    liblivemedia57 \
    libusageenvironment3 \
 && rm -rf /var/lib/apt/lists/*

# install python dependencies
RUN pip3 install python-miio

# Copy the compiled videoP2Proxy
COPY --from=builder /build/videop2proxy /usr/local/bin/
COPY --from=builder /build/lib/Linux/x64/*.so /usr/local/lib/

ENTRYPOINT videop2proxy --ip $IP --token $TOKEN --rtsp 8554
