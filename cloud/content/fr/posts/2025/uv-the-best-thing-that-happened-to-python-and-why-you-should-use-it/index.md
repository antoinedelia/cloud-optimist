---
title: "uv : La meilleure chose qui soit arrivée à Python - et pourquoi vous devriez l'utiliser"
date: 2025-06-04T07:30:00+02:00
author: Antoine Delia
draft: true
tags:
    - Python
categories: [ Python ]
image: uv.jpeg
---

# Introduction

Dans le monde merveilleux (et parfois un peu chaotique) de l'outillage Python, on est constamment à la recherche de l'outil qui va nous simplifier la vie, nous faire gagner du temps, et si possible, nous redonner le sourire face à des `pip install` interminables. Si vous avez déjà entendu parler de `ruff` (le linter/formateur ultra-rapide qui a conquis le cœur de nombreux développeurs Python, dont le mien !), alors préparez-vous à rencontrer son petit frère tout aussi impressionnant : `uv`.

Créé par la même équipe talentueuse chez Astral, `uv` est présenté comme un installateur et résolveur de paquets Python "extrêmement rapide". Et croyez-moi, le terme "extrêmement" n'est pas galvaudé ! Depuis que je l'ai intégré dans mes projets et même dans nos guidelines d'entreprise, je ne peux plus m'en passer.

Alors, qu'est-ce que `uv` a de si spécial ? Pourquoi cet engouement ? C'est ce que nous allons décortiquer ensemble. Accrochez-vous, vous pourriez bien avoir un nouveau coup de foudre !

_(Petite note : Ce guide se base sur mon expérience avec `uv` et les exemples ont été testés avec la version 0.6.16. Selon votre configuration, notamment sous Windows ou derrière certains proxys d'entreprise, vous pourriez avoir besoin d'ajouter l'option `--native-tls` à certaines commandes `uv` si vous rencontrez des soucis de connexion SSL.)_


# `uv`, c'est quoi au juste ?

En quelques mots, `uv` est un outil en ligne de commande qui ambitionne de remplacer `pip`, `pip-tools`, `venv`, et même une partie de `virtualenv` et `pipx`, tout en étant beaucoup, _beaucoup_ plus rapide. Il est écrit en Rust, ce qui explique en grande partie ses performances fulgurantes.

Son objectif principal est de gérer l'installation et la résolution des dépendances de vos projets Python, mais il fait bien plus que ça, comme nous allons le voir.


### Installation : Mettre le pied à l'étrier

L'installation de `uv` est un jeu d'enfant. Vous avez plusieurs options, choisissez celle qui vous convient le mieux (la documentation officielle est [ici](https://docs.astral.sh/uv/getting-started/installation/) si besoin) :

```sh
# Sur macOS et Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Sur Windows (avec PowerShell)
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Avec pip (si vous avez déjà un environnement Python)
pip install uv

# Avec pipx (recommandé si vous utilisez pipx)
pipx install uv

# Avec Homebrew (pour les utilisateurs macOS)
brew install uv
```

Une fois installé, vous pouvez le mettre à jour très simplement :

```sh
uv self update
```

Et voilà, `uv` est prêt à l'emploi !


### Gérer les versions de Python avec `uv` ? Oui, c'est possible !

Une des fonctionnalités sympathiques de `uv` est sa capacité à installer des versions spécifiques de Python. Plus besoin de jongler avec `pyenv` ou d'autres outils si vos besoins sont simples.

Pour installer la dernière version stable de Python :

```
uv python install
```

Besoin d'une version particulière ? Pas de problème :

```
# Installer Python 3.9
uv python install 3.9
```

Vous pouvez ensuite utiliser cette version pour exécuter un script :

```
uv run --python 3.9 python mon_script.py
```

Ou même pour créer un environnement virtuel basé sur cette version :

```
# Crée un venv avec Python 3.9, sans chercher de projet pyproject.toml
uv run --no-project --python 3.9 uv venv
source .venv/bin/activate # Ou .venv\Scripts\activate sous Windows

# Et hop, vous êtes sous Python 3.9 dans ce venv !
python -V
# Output: Python 3.9.x (la version exacte installée par uv)
```

Attention cependant : Les versions de Python installées par `uv` ne sont pas disponibles "globalement" sur votre système via la simple commande `python`. Pour les utiliser, il faut passer par `uv run --python <version>` ou les activer dans un environnement virtuel créé avec cette version spécifique.


### Environnements Virtuels : La Simplicité Retrouvée

Fini les `python -m venv .venv` un peu verbeux. Avec `uv`, c'est direct :

```
uv venv
```

Cette commande crée un environnement virtuel nommé `.venv` dans votre répertoire courant. Pour l'activer :

```
# Sur macOS et Linux
source .venv/bin/activate

# Sur Windows
.venv\Scripts\activate
```

Une fois l'environnement activé, vous pouvez installer des paquets comme vous le feriez avec `pip`, mais en utilisant la commande `uv pip` (et en profitant de la vitesse `uv` !) :

```
uv pip install flask                 # Installer Flask
uv pip install -r requirements.txt   # Installer depuis un requirements.txt
uv pip install -e .                  # Installer le projet courant en mode éditable
uv pip install "flask[dotenv]"       # Installer Flask avec l'extra "dotenv"
```


### `uvx` : Exécuter des outils à la volée

Vous connaissez `pipx run` ou `npx` dans le monde JavaScript ? `uvx` est l'équivalent proposé par `uv`. Il permet d'exécuter une commande CLI Python (comme `ruff`, `black`, `ipython`, etc.) dans un environnement temporaire avec les dépendances spécifiées, sans polluer votre projet ou votre système.

Par exemple, pour lancer une version spécifique de `ruff` :

```
uvx --python 3.12 ruff@0.9.6 check mon_fichier.py
```

Ou pour lancer `ipython` avec `requests` disponible temporairement :

```
uvx --with requests -p 3.13 ipython
```

Extrêmement pratique pour des one-shots ou pour tester des outils !


### `uv` au Cœur de Vos Projets : Le Workflow Moderne

C'est ici que `uv` brille vraiment et modernise la gestion de projet Python.


#### Démarrer un nouveau projet

Pour initialiser un nouveau projet avec `uv` :

```
uv init
```

Cette commande va créer quelques fichiers pour vous :

- `.python-version` : Spécifie la version de Python à utiliser pour ce projet (par exemple, `3.11`).

- `main.py` : Un fichier Python d'exemple.

- `pyproject.toml` : Le fichier central pour la configuration de votre projet, y compris ses dépendances. C'est le standard moderne en Python.


#### Gérer les dépendances avec `pyproject.toml`

Avec `uv`, le `pyproject.toml` devient votre source de vérité pour les dépendances.

Pour ajouter une nouvelle dépendance à votre projet :

```
uv add requests
uv add "fastapi[all]" # Avec des extras
```

Pour ajouter une dépendance de développement (uniquement pour le dev, comme `ruff` ou `pytest`) :

```
uv add ruff --dev
uv add pytest --dev
```

Très important : La première fois que vous ajoutez une dépendance, `uv` va générer un fichier `uv.lock`. Ce fichier contient les versions exactes de toutes vos dépendances (directes et indirectes) qui ont été résolues. Ce fichier `uv.lock` est crucial et DOIT être commité dans votre dépôt Git. Il garantit des installations reproductibles pour tous les collaborateurs et en CI/CD.

Une fois vos dépendances (notamment de dev) ajoutées, vous pouvez les utiliser avec `uv run` :

```
uv run ruff format .
uv run pytest
```

Pour supprimer un paquet :

```
# Pour une dépendance normale
uv remove requests

# Pour une dépendance de développement (notez le --group dev)
uv remove ruff --group dev
```

_Petite parenthèse sur les index de paquets :_ Par défaut, `uv` utilise PyPI. Si vous travaillez dans un environnement d'entreprise avec un Artifactory ou un autre index privé, vous pouvez configurer `uv` pour l'utiliser via le fichier `pyproject.toml`. Consultez la [documentation `uv` sur les index](https://docs.astral.sh/uv/configuration/indexes/) pour les détails. C'est très flexible !


#### Migrer un projet existant vers `uv`

Vous avez un projet avec un bon vieux `requirements.txt` ? La migration est assez simple :

1. Si vous n'avez pas de `pyproject.toml`, créez-en un. Vous pouvez lancer `uv init` dans le répertoire de votre projet existant ; il détectera la présence d'un projet et vous aidera.

2. Pour chaque paquet dans votre `requirements.txt` (et `requirements-dev.txt` si vous en avez un), ajoutez-le avec `uv add <nom_du_paquet>` ou `uv add <nom_du_paquet> --dev`. `uv` se chargera de résoudre les versions et de mettre à jour `pyproject.toml` et `uv.lock`.

3. Une fois toutes les dépendances migrées, vous pouvez supprimer vos anciens fichiers `requirements.txt`.

Et voilà, votre projet est propulsé par `uv` !


#### Rejoindre un projet qui utilise déjà `uv`

Si vous clonez un projet qui est déjà géré par `uv` (il aura un `pyproject.toml` et un `uv.lock`), la mise en place est d'une simplicité enfantine. Après avoir activé votre environnement virtuel (`uv venv` puis `source .venv/bin/activate`) :

```
uv sync
```

Cette commande magique va lire le fichier `uv.lock` et installer _exactement_ les mêmes versions de tous les paquets qui y sont listées. Fini les "ça marche sur ma machine" à cause de versions de dépendances différentes !


### Construire et Publier votre paquet

`uv` ne s'arrête pas là et propose aussi des commandes pour le build et la publication :

Pour construire votre paquet (wheel et sdist) :

```
uv build
```

Pour publier sur PyPI (ou un index privé configuré) :

```
uv publish
# Pour un index privé, vous pourriez avoir besoin de spécifier l'URL
# uv publish --repository-url https://mon-artifactory.corp/api/pypi/mon-repo-local
```

Et pour tester rapidement si votre paquet fraîchement construit s'installe et s'importe correctement :

```
# Remplacez <MON_PAQUET> par le nom de votre paquet
uv run --with <MON_PAQUET>-<VERSION>.whl --no-project --python -c "import <MON_PAQUET>"
```


### Un Coup de Propre : Nettoyer le Cache

Avec le temps, `uv` (comme `pip`) accumule un cache de paquets téléchargés. Pour le nettoyer :

```
uv cache clean
```


### Démarrage Rapide de Projets avec Cookiecutter et `uv`

Si vous êtes adepte de `cookiecutter` pour générer des squelettes de projets, sachez que `uv` s'y intègre parfaitement. Vous pouvez créer des templates Cookiecutter qui incluent déjà un `pyproject.toml` configuré pour `uv` et même un `uv.lock` initial si vous le souhaitez. Cela permet de démarrer de nouveaux projets encore plus vite, avec toutes les bonnes pratiques `uv` déjà en place. Pensez à un template qui inclut `ruff`, `pytest`, et `uv` dans ses `[tool.uv.dev-dependencies]` !


### Pourquoi je suis Conquis et Pourquoi Vous Devriez l'Essayer

Vous l'aurez compris, `uv` n'est pas juste "un autre gestionnaire de paquets". C'est une véritable bouffée d'air frais.

- La Vitesse : C'est le premier argument qui frappe. Les installations, les résolutions, tout est incroyablement plus rapide que `pip`. Sur de gros projets, le gain de temps est phénoménal.

- L'Unification : `uv` regroupe des fonctionnalités qui nécessitaient auparavant plusieurs outils (`pip`, `venv`, `pip-tools`, voire `pyenv` pour des besoins basiques). Avoir une seule interface cohérente simplifie grandement le workflow.

- La Modernité : Il embrasse pleinement `pyproject.toml` et les standards modernes de packaging Python.

- La Fiabilité : Le système de lockfile (`uv.lock`) assure des builds reproductibles, un point essentiel pour le travail en équipe et l'intégration continue.

Depuis que j'utilise `uv`, mes interactions avec la gestion des dépendances Python sont devenues plus rapides, plus simples et plus agréables. C'est le genre d'outil qui, une fois adopté, vous fait vous demander comment vous faisiez avant.

Alors, si vous cherchez à moderniser votre outillage Python et à gagner en productivité (et en sérénité !), je ne peux que vous encourager à donner sa chance à `uv`. L'essayer, c'est très souvent l'adopter !


### Pour Aller Plus Loin (Références)

- Documentation officielle `uv` : [https://docs.astral.sh/uv](https://docs.astral.sh/uv)
- Repo GitHub `uv` : [https://github.com/astral-sh/uv](https://github.com/astral-sh/uv)
- [A year of uv: pros, cons, and should you switch? (bitecode.dev)](https://www.bitecode.dev/p/a-year-of-uv-pros-cons-and-should)
- [uv tricks (bitecode.dev)](https://www.bitecode.dev/p/uv-tricks)


