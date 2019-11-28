FROM ruby

RUN apt-get install xz-utils -y
RUN apt-get update
RUN apt-get upgrade -y

RUN echo 'gam() { "/app/gam/gam" "$@" ; }' >> ~/.bashrc
RUN echo 'alias depr="ruby /app/lib/identity.rb $*' >> .bashrc
RUN mkdir app
WORKDIR /app

# Install GAM

COPY gam /app/gam
RUN echo GAM_LOCATION="/app/gam"
RUN echo "" > /app/gam/no-update.txt
RUN echo "" > /app/gam/noupdatecheck.txt

# Install Deprovisioner

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install
COPY lib /app/lib
COPY lib/identity /app/lib/identity
COPY README.md /app/
COPY spec /app/spec
COPY units.sh /app/
COPY config.prod.yml /app/config.yml
COPY run.sh /app/run.sh
