FROM ruby:3.0.3

# Installation des dépendances
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    cron

# Installation de Yarn
RUN npm install -g yarn

# Création du répertoire de l'application
WORKDIR /app

# Copie des fichiers de gestion des dépendances
COPY Gemfile Gemfile.lock package.json yarn.lock ./

# Installation d'une version récente de Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get update && apt-get install -y nodejs

# Vérifiez la version de Node.js
RUN node --version

# Installez une version récente de Yarn
RUN npm install -g yarn
RUN yarn --version

# Installation des dépendances Ruby et Node.js
RUN bundle install
RUN yarn install

# Copie du code de l'application
COPY . .

# Précompilation des assets pour production
RUN RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rails assets:precompile

# Configuration de l'application
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Exposition du port
EXPOSE 3000

# Script de démarrage
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]