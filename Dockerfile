FROM ruby:2.3
MAINTAINER emdentec ltd. <docker@emdentec.com>

ENV WORK_DIR /usr/lib/heaven

RUN mkdir -p $WORK_DIR

COPY Gemfile $WORK_DIR/Gemfile
RUN cd $WORK_DIR && bundle install

COPY . $WORK_DIR

WORKDIR $WORK_DIR
EXPOSE 80

ENTRYPOINT ["bundle", "exec"]
CMD ["unicorn" "-p" "80" "-c" "config/unicorn.rb"]
