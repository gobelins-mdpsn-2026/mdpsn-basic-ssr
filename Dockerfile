FROM ruby:3.4-slim

RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without "test" && bundle install

COPY . .

ENV RACK_ENV=production
ENV PORT=3000
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD ruby -rnet/http -e "exit(Net::HTTP.get_response(URI('http://127.0.0.1:3000/healthz')).code == '200' ? 0 : 1)"

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
