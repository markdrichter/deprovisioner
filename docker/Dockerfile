FROM ruby:latest

RUN apt-get update
RUN apt-get upgrade -y

RUN mkdir app
WORKDIR /app

# Install GAM

COPY gam /app/gam
RUN echo GAM_LOCATION="/app/gam"
RUN echo "" > /app/gam/no-update.txt
RUN echo "" > /app/gam/noupdatecheck.txt

# Install Deprovisioner

RUN gem update bundler
COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install

ADD lib /app/lib/
ADD spec /app/spec/
COPY units.sh /app/
ARG CONFIG
COPY config.yml /app/config.yml
RUN echo 'gam() { "/app/gam/gam" "$@" ; }' >> ~/.bashrc
ENV PORT 8080
EXPOSE 8080
