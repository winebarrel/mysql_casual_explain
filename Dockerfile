FROM ruby:3.3

COPY ./ /mnt/
WORKDIR /mnt
RUN git config --global --add safe.directory /mnt
RUN gem update bundler -f && \
  bundle install && \
  bundle exec appraisal install
