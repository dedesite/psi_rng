# Introduction

Passionné par la parapsychologie (l'étude des phénomènes dit « paranormaux ») depuis des années, je me suis lancé il y a maintenant un an dans la réplication de certaines expériences.
Elles tentent de mesurer l'influence de l'intention humaine ou animal sur la matière.
Pour cela, un générateur de nombres aléatoires électronique est utilisé, si le hasard est modifié (c'est à dire non conforme aux prédictions statistiques) alors c'est qu'il y a eu influence.

L'expérience la plus « impressionnante » est celle réalisée sur des poussins (mais aussi sur l'homme) en 1986 par René Peoc'h pour sa thèse en médecine :

http://www.dailymotion.com/video/xb6zgf_l-esprit-et-la-matiere_tech

Voici aussi un lien vers sa thèse pour ceux qui souhaiteraient plus d'information (ça se lit très bien et très vite) :

http://psiland.free.fr/savoirplus/theses/theses.html#RenePeoch

D'autres expériences très intéressantes ont été faites par le Pear (Princeton Engineering Anomalies Research) dans les années 70 puis répliquées dans les années 2000 avec peu de succès (j'ai ma petite idée pourquoi et comment y remédier).

http://www.metapsychique.org/Correlations-of-Random-Binary.html (là c'est moins sexy et c'est en anglais)

Une présentation des travaux du labo en français :

http://www.paranormal-info.com/Les-recherches-au-PEAR-sur-les.html

Lien vers toutes leurs publications :

http://www.princeton.edu/~pear/pdfs/

Un autre projet se rapproche beaucoup de ce que j'aimerai faire : le Gobal Consciousness Project
https://www.youtube.com/watch?v=itQMALL__bE

# Le projet

J'aimerai donc reproduire, dans l'essence, ces expériences mais a une bien plus large échelle en passant par internet. Au lieu de faire passer les expériences dans un labo à quelques dizaines ou centaines de personnes, tout le monde pourra le faire devant son ordi ou encore mieux sur son téléphone portable.
Mon but est fournir un site web ou une application mobile permettant à la personne de tester ses capacités psi (« paranormales »), d'en avoir un récapitulatif et de pouvoir si possible s'améliorer. Plus on aura d'utilisateur, plus on aura de données et plus la preuve de l'existence, ou non, du phénomène sera pertinente.
Afin de maintenir les utilisateurs concentrés sur leur tâches, l'idée est de rendre les expérimentations attractives et ludiques par le biai de jeux et de scoring.

Vous allez me dire, mais comment cela peut marcher si le générateur de nombres aléatoires n'est pas à côté de la personne ? Et c'est là le meilleur, c'est que normalement, le générateur pourrait être à des milliers de kilomètres et ça marcherait quand même. C'est le principe de non localité très cher à la physique quantique qui semble ici s'exprimer.

J'aimerai insister sur le fait que ce projet est A BUT NON LUCRATIF et que le code est sous licence GPL V3. Mon seul but est de faire avancer la recherche (et les mentalités) dans ce domaine.

## Où j'en suis ?

J'ai réalisé ce qu'on pourrait appeler une preuve de concept en fabriquant mon générateur selon ces plans (si vous avez le temps lisez cet article en entier c'est très instructif) :

http://holdenc.altervista.org/avalanche/

Ensuite, je récupère ma suite de 0 et de 1 sur un raspberry pi qui me sert aussi de serveur de websocket codé en C (avec libwebsocket) pour envoyer le tout sur une page web sur laquelle on réalise les expérimentations.
Pour l'instant, il s'agit d'une bête page HTML qui liste les XP que j'ai créé. Le stockage des données n'est pas fonctionnel et certaines XP sont plus des essais qu'autre chose mais dans le principe ça fonctionne.
Mon plus gros travail a été de reproduire à l'identique le fonctionnement du Tychoscope, le robot utilisé par René Peoc'h pour ses recherches. J'ai un soucis c'est que le robot ne se comporte pas comme en vrai car je n'ai pas les mêmes résultat sur la phase de test de l'aléatoire du robot (quand il n'y a pas de poussins).

Voici le github du projet (ne faite pas attention à la qualité du code, j'ai fais ça principalement le soir entre minuit et 5H du mat' quand j'en avais la possibilité) :

https://github.com/dedesite/psi_rng

## Que reste-t-il à faire ?

Plein de choses ! Le projet étant assez vaste et diversifié, il y a du travail potentiel pour beaucoup de personnes.

### En électronique
Pour l'instant, j'ai fais mon montage électronique sur une bread board de manière totalement amateur. Si on veut avoir un site sur lequel des centaines, voir des milliers de personnes vont chaque jour, il nous faudrait sans doute plusieurs dizaines de générateurs. Il faudrait donc fabriquer un circuit imprimé qui s'encastre facilement sur le raspberry. Si on prend des composants miniaturisés, on peut imaginé avoir plusieurs générateurs (autant que le raspberry peut en gérer) sur un même circuit.

### En embarqué

Le code du raspberry ne gère pour l'instant qu'un générateur. J'espère qu'il sera possible d'en gérer plusieurs sur un même Raspberry histoire d'économiser de l'argent. Il faudra donc faire des tests pour voir quelle est la limite du nombre de générateur par machine sans gêner la génération de nombre et l'envoie via websocket.

Il faudrait aussi rendre la procédure d'installation et de mise en marche la plus simple possible. Un joli paquet Rasbian et un démon qui se lance automatiquement serait les bienvenus.

Si le projet prend de l'envergure, il pourrait être bien aussi d'inciter d'autres possesseurs de Raspberry à faire partie de notre réseau de générateur en simplifiant aussi l'ajout de nouvelle machine dans le réseau et en fournissant des méthodes de test fiables et faciles pour le générateur de nombres aléatoires.

### Le site web

Ca serait trop cool d'avoir un site web (international) qui donne envie aux personnes de passer les expérimentations, de challenger leurs amis (via facebook par exemple) et de donner le maximum d'informations sur elle même afin de pouvoir faire des lien entre les résultats et les personnes.
Par exemple, il serait intéressant de voir si la tranche d'age, le sexe, la latéralité (gaucher ou droitier) ou encore la croyance en ce type de phénomène influence les résultats.

Pour avoir un tel site, il nous faut déjà un bon design avec une bonne idée, un truc genre « devient toi même un jedi » pour titiller le côté geek qui est en nous.

Côté technique, j'ai une grosse préférence pour le langage Ruby (pas forcément avec Rails) et j'aimerai vraiment que le site soit codé dans ce langage, histoire que si j'ai a reprendre le projet seul un jour, je ne me tire pas une balle avec du Zend framework ou autres immondices.

Niveau BDD je serai bien tenté d'utiliser PostgreSQL qui semble vraiment solide, performant et pas sous l'égide d'une multinationale de merde comme Oracle. Après, MySQL est très bien aussi.
Pour l'hébergement, je tablerais sur une plateforme cloud genre Heroku histoire d'avoir quelque chose de gratuit et pratique au début pour les tests et de pouvoir facilement monter en charge quand le site sera en prod.

### Les XP

Les expérimentations seront sous forme de jeux vidéo codés en Javascript (ou coffeescript) et utilisant les websockets pour récupérer les nombres du générateur. J'ai déjà pas mal d'idées reprenant des concepts de jeux existants.
Etant donné qu'une personne à la fois peut utiliser un générateur, il faudra gérer, côté serveur web, une liste d'attente. A la fin de chaque XP, les résultats sont stockés dans la BDD.

### Sur Mobile

On peut imaginer une application mobile (que je préférerai web pour éviter une redondance de code avec la partie desktop et les différents OS mobiles) sur laquelle on pourrait faire des XP adaptées à ce type de terminaux.
Par exemple, faire l'XP du Tychoscope, en le mettant au bout de la table et en l' « appelant » mentalement pour voir s'il va venir. Ce type d'XP n'est pas réalisable avec un écran d'ordinateur classique.

### Analyse des résultats

Un gros travail d'analyse statistique doit aussi être effectué pour que ces XP aient un quelconque intérêt. C'est moins sexy mais c'est nécessaire pour valider la recherche et aller plus loin par la suite.
J'ai peut-être dégoté un mathématicien capable de nous aider sur cette partie là :).

### Partenariats

Vous vous en doutez, pour que le projet prenne de l'ampleur il va nous falloir des fonds. Cela servira à payer l’électronique, les raspberry et l'hébergement du serveur web qui pourra vite devenir onéreux en cas de buzz.

Je pensai contacter l'Institut Métapsychique International (http://www.metapsychique.org/) dans lequel j'ai des contacts dans l'espoir qu'ils nous donne un peu d'argent et peut-être des conseils en terme de recherche.

Ces sujets de recherche étant assez tabou en France, je n'ai pas bien d'autres idées de partenariat. Une campagne de crowd funding ? Du mécénat privé ? Je suis ouvert à toutes les bonnes idées.

# Conclusion

Il s'agit d'un projet d’envergure et assez atypique mais qui a mon avis est réalisable en quelques mois si l'on s'y met à plusieurs. Si vous êtes intéressez, merci de m'envoyer un mail pour me dire quelle partie vous intéresse le plus et quelles sont vos compétences. Débutants acceptés :).