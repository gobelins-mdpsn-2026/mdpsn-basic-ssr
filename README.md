# basic-ssr — todo list en Sinatra + ERB

Une todo list rendue entièrement côté serveur. Pas une ligne de JavaScript :
chaque clic est un formulaire HTML, chaque formulaire est une requête HTTP,
chaque requête renvoie une page complète (ou une redirection vers une page).

Stack : Ruby, [Sinatra](https://sinatrarb.com), ERB pour les vues,
[Sequel](https://sequel.jeremyevans.net) + PostgreSQL pour les données.

## Lire le code

- `app.rb` : les routes. `GET /` rend la liste, les `POST` modifient puis
  redirigent vers `GET /`.
- `views/index.erb` : la page. Regardez les `<form method="post">`.
- `db.rb` : la connexion et la table.

Ouvrez l'onglet Réseau de votre navigateur en cliquant dans l'app : vous
verrez un `POST`, une redirection, puis un `GET`. C'est tout le modèle.

## Lancer en local

```sh
bundle install
cp .env.example .env
docker compose up -d db          # une base PostgreSQL locale
DATABASE_URL=$(grep DATABASE_URL .env | cut -d= -f2-) bundle exec rackup -p 3000
```

Puis <http://localhost:3000>.

Tests (la base doit tourner) :

```sh
DATABASE_URL=postgres://todo:todo@localhost:5432/todo bundle exec ruby -Itest test/app_test.rb
```

## Lancer tout avec Docker

```sh
docker compose up --build
```

## Déployer sur Coolify

New Resource → Application → ce dépôt, branche `main`, build pack
**Docker Compose**. Coolify lit `docker-compose.yml`, crée l'app et sa base.
Donnez un domaine au service `app`, déployez. Aucune variable à renseigner.

## Attention

Aucune authentification : tout le monde voit et modifie la même liste.

## Licence

Domaine public ([Unlicense](https://unlicense.org)).
