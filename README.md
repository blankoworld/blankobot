# Présentation 

BlankoBot est un robot IRC écrit en Ruby. Il ne présente actuellement que très peu de commandes telles que : 

  * aide
  * de
  * identifie
  * il
  * msg
  * salut

J'aurai aimé un jour y voir les fonctions suivantes : 

  * résultat d'un moteur de recherche
  * résultat des dernières nouvelles d'un flux RSS/ATOM
  * statut Mastodon (ou Ostatus)
  * VDM aléatoire (viedemerde.fr)
  * etc.

Il ne tient qu'à vous de le faire évoluer puis d'en publier les résultats, puisque le blankobot est sous licence GPLv3.

# Configuration 

Un exemple de fichier de configuration est disponible : **config.yml**.

Vous pouvez soit l'utiliser en le modifiant, soit en le copiant. Dans notre exemple, pour le réseau evolu.net, nous avons copié le fichier config.yml en un fichier **evolu_config.yml**.

Voici son contenu : 

```yaml
serveur:          irc.evolu.net
port:             6667
canal:            "#testbot"
pseudo:           NoIdea
mdp:              anything
nom_utilisateur:  noidea
nom_hote:         olivier.dossmann.net
nom_serveur:      blankoworld
nom_reel:         "Olivier DOSSMANN"
utilisateurs_autorises:
1. Blankoworld
2. Olivier1234
```

Ceci indique que le robot se connectera sur le serveur *irc.evolu.net* sur le port *6667* et entrera dans le canal *#testbot* (on ne peut mettre qu'un canal). Il aura le pseudo *NoIdea* et donnera le mot de passe *anything*. Son nom réel, affiché aux utilisateurs, sera *Olivier DOSSMANN*, et son nom d'utilisateur sur le réseau sera *noidea*.

On apprend également que les personnes ayant des autorisations particulières sur le robot sont les suivantes : 

  * Blankoworld
  * Olivier1234

Ils pourront notamment utiliser la commande **!quitte <message>**, après s'être identifié via *!identifie <monPseudo>*.

# Utilisation 

:exclamation: Nous considérons que vous avez un minimum de connaissance en IRC, au moins pour utiliser un client IRC, savoir ce qu'est un serveur, un port, et comment les utiliser.

Rien de trop compliqué, pour lancer le script il suffit de faire : 

```yaml
ruby botirc.rb config.yml
```

Où *config.yml* correspond au fichier de configuration que vous souhaitez utiliser.

:exclamation: Attention, pour l'instant le fichier de configuration doit être au format **.yml** et se trouver dans le répertoire du robot IRC. Dans le cas contraire le robot ne se lancera pas.

**NB** : Si vous voulez laisser le robot allumé en permanence, il va falloir [utiliser Tmux](https://fr.wikipedia.org/wiki/Tmux).

Une fois sur un réseau, il est évident que vous accédez au robot en tant qu'utilisateur du réseau.

Pour l'utiliser, faites : 

  * rejoignez le canal où se trouve votre robot
  * parlez lui en message privé
  * dans la fenêtre de message privé, tapez **!aide**

Le robot donne un ensemble de commande et des explications sur comment les utiliser.
