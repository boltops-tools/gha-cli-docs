FROM ruby:3.2

# RUN gem install cli-docs

COPY cli-docs cli-docs
RUN cd cli-docs && bundle install
RUN cd cli-docs && rake install

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
