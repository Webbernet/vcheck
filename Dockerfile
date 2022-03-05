FROM ruby:3.1.1-slim-bullseye

COPY vcheck.rb ./vcheck.rb

CMD ["ruby", "./vcheck.rb"]

