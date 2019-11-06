FROM centos:7
FROM node:6
RUN apt-get update
RUN apt-get upgrade -y

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
                tcl \
                tk \
                vim \
        && rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D

# Capture the GAM client secrets

# Install Java
RUN apt-get update
RUN apt-get install default-jre -y
RUN apt-get install unzip -y

RUN mkdir app
WORKDIR /app

# Install Jruby

RUN curl -o jruby-complete-9.1.16.0.jar https://s3.amazonaws.com/jruby.org/downloads/9.1.16.0/jruby-complete-9.1.16.0.jar
RUN mv jruby-complete-9.1.16.0.jar /app/jruby.jar
RUN ls -al

# Install GAM

ADD https://github.com/jay0lee/GAM/archive/v4.70.zip gam.zip
RUN unzip gam.zip
RUN mv GAM-4.70 gam
RUN echo GAM_LOCATION="/gam"
RUN echo "" > gam/src/no-update.txt
RUN echo "" > gam/src/noupdatecheck.txt
RUN echo 'alias gam="python /app/gam/src/gam.py"' >> ~/.bashrc

# Downloading gcloud package
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz

# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh

# Adding the package path to local
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# Install Deprovisioner

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN mkdir -p gems/jruby/2.3.0
ENV GEM_HOME=/app/gems/jruby/2.3.0
ENV GEM_PATH=/app/gems/jruby/2.3.0/bin
ENV PATH=$PATH:$GEM_PATH
RUN java -jar jruby.jar -S gem install bundler --install-dir gems/jruby/2.3.0
RUN java -jar jruby.jar -S bundle install --path gems
RUN echo 'alias idm="java -jar jruby.jar -S /app/lib/identity.rb $1 $2 $3 $4 $5 $6 $7 $8 $9 $A $B $C $D $E $F $G $H $I"' >> ~/.bashrc
RUN echo 'alias gam="python /app/gam/src/gam.py"'
COPY lib /app/lib 
COPY lib/identity /app/lib/identity
COPY config.yml /app/
COPY run.sh /app/
COPY gam.sh /app/
COPY README.md /app/
COPY spec /app/spec
COPY units.sh /app/

