FROM harbor.intgdc.com/tools/gdc-java-8-jre:b057b53

ARG GIT_COMMIT=unspecified
LABEL image_name="GDC LCM Bricks"
LABEL maintainer="LCM <lcm@gooddata.com>"
LABEL git_repository_url="https://github.com/gooddata/gooddata-ruby/"
LABEL parent_image="harbor.intgdc.com/tools/gdc-java-8-jre:b057b53"
LABEL git_commit=$GIT_COMMIT

# which is required by RVM
RUN yum install -y curl which \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby=jruby-9.1.14.0

# Switch to directory with sources
WORKDIR /src
ENV HOME=/src

# login shell is required by rvm
RUN /bin/bash -l -c ". /usr/local/rvm/scripts/rvm && gem update --system \
    && gem install bundler rake"

ENV GOODDATA_RUBY_COMMIT=$GIT_COMMIT

ADD ./bin ./bin
ADD ./lib ./lib
ADD ./Gemfile .
ADD ./gooddata.gemspec .

RUN /bin/bash -l -c ". /usr/local/rvm/scripts/rvm && bundle install"

CMD [ "./bin/hello_world.sh" ]
