FROM ruby:2.3.1
MAINTAINER emdentec ltd. <docker@emdentec.com>

RUN mkdir -p /root/.ssh

ENV WORK_DIR /usr/lib/heaven

RUN mkdir -p $WORK_DIR

COPY Gemfile $WORK_DIR/Gemfile
COPY Gemfile.lock $WORK_DIR/Gemfile.lock
RUN cd $WORK_DIR && bundle install

COPY . $WORK_DIR

WORKDIR $WORK_DIR
EXPOSE 80

ENTRYPOINT ["bundle", "exec"]
CMD ["unicorn", "-p", "80", "-c", "config/unicorn.rb"]
