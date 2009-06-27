#!/usr/bin/ruby1.8

# botirc.rb

## Decouvert sur : http://snippets.dzone.com/posts/show/1785
## Puis complete grace a : 
##  http://zefredz.frimouvy.org/dotclear/index.php?2006/03/17/111-un-bot-irc-elementaire-en-ruby
## Le script de base proviendrait de ruby-irc
##  disponible ici : http://rubyforge.org/projects/ruby-irc/

## Auteur actuel (pour les fonctionnalites suivantes) : Blankoworld

## RFC : http://www.ietf.org/rfc/rfc1459.txt

## Requiert : 
## - fichier_conf.rb
## - message_irc.rb
## - personne.rb
## - config.yml

require "socket"
require "fichier_conf"
require "message_irc"
require "personne"

# Don't allow use of "tainted" data by potentially dangerous operations
$SAFE=1

# The irc class, which talks to the server and holds the main event loop
class IRC

# En mode DEBUGGAGE
@@DEBUG=true

	def initialize(config)
		@server = config.serveur
		@port = config.port
		@nick = config.pseudo
		@channel = config.canal
		@password = config.mdp
    
    @nom_utilisateur = config.nom_utilisateur
    @nom_hote = config.nom_hote
    @nom_serveur = config.nom_serveur
    @nom_reel = config.nom_reel
		## Tableau des utilisateurs
		@authorized_users = []
		
    config.utilisateurs_autorises.each do |u|
      @authorized_users << Personne.new(u)
    end

		## Utilise pour diverses choses
		@whois_actif = false
		@whois_pseudo = ""
		@registered_users = {}
	end

  def afficher_params()
    return "S:#{@server.class}P:#{@port.class}N:#{@nick.class}C:#{@channel.class}MdP:#{@password.class}"
  end

	def envoi(s)
	# Send a message to the irc server and print it to the screen
		puts "--> #{s}"
		@irc.send "#{s}\n", 0 
	end

	def connect()
	# Connect to the IRC server
		@irc = TCPSocket.new @server, @port
    # USER <username> <hostname> <servername> :<realname>
		envoi "USER nopseudo dossmann.net ordyz :Dave Null"
		envoi "NICK #{@nick}"
		envoi "JOIN #{@channel}"
		envoi "PRIVMSG NickServ :identify #{@password}"
	end

	def evaluate(s)
	# Make sure we have a valid expression (for security reasons), and
	# evaluate it if we do, otherwise return an error message
		if s =~ /^[-+*\/\d\s\eE.()]*$/ then
			begin
				s.untaint
				return eval(s).to_s
			rescue Exception => detail
				puts detail.message()
			end
		end
		return "Error"
	end

#######
###
###  Fonctions diverses
###
#######

  def debug(msg)
  # Utile pour la période de développement
    puts msg if @@DEBUG
  end

  def nbreMots(chaine)
  # Defini le nombre de mots contenus dans la chaîne
    if chaine.nil?
      resultat = 0
    else
      resultat = chaine.split(' ').length
    end
    return resultat.to_i
  end

  def utilisateur_autorise?(util)
  # définit si l'utilisateur est autorisé à utiliser des fonctions spécifiques
    utilisateurs = []
    @authorized_users.each do |u| 
      utilisateurs << u.nom
    end
    return utilisateurs.include?(util.to_s)
  end

  def utilisateur_enregistre?(util)
  # définit si l'utilisateur est enregistré sur le programme, 
  #  et donc a fait la demande de vérification
    if @registered_users[util.to_s].nil? or !@registered_users[util.to_s]
      return false
    else
      return true
    end
  end

#######
###
### FIN Fonctions diverses
###
#######

#######
###
###  Fonctions de vérifications en tous genres
###
#######

	def verification_pseudo(pseudo)
  # envoie un ensemble de commande au serveur qui permettront de savoir si 
  #  l'utilisateur est enregistré sur le serveur
		puts "[ VERIFICATION PSEUDO: #{pseudo} ]"
    if utilisateur_autorise?(pseudo)
      @whois_actif = true
      m = Message.new
  		# ligne pour les serveurs ayant la commande STATUS disponible (exemple: irc.evolu.net)
  		envoi m.statut(pseudo, "NickServ")
  		# ligne pour tout les serveurs informant l'enregistrement d'un utilisateur
  		envoi m.whois(pseudo)
      puts "WHOIS et STATUS envoyés pour #{pseudo}"
    else
      puts "#{pseudo} NON CONNU"
    end
	end

	def valide_pseudo_evolu(utilisateur, niveau)
		# mettre ici de quoi valider le pseudo de quelqu'un avec un chiffre
		# à la rigueur afficher plusieurs résultat 0, 1, 2, 3
		# à 3, on est bon.
    # Testé sur irc.evolu.net
  	puts "[ ETUDE STATUT de #{utilisateur}  ]"
		if @whois_actif && utilisateur_autorise?(utilisateur) && niveau.to_i == 3
			puts "#{utilisateur} ACCEPTÉ, niveau #{niveau}"
			@whois_actif = false
      p = Personne.new(utilisateur)
      p.autorise = true
			@registered_users[p.nom] = p.autorise
      m = Message.new
			msg = "Tu as été enregistré sur mon robot IRC. Si tu n'en a pas fait la demande, merci de me contacter à l'adresse suivante : blanko@blanko.fr.st . J'aviserais."
      envoi m.prive(utilisateur, utilisateur, msg)
		elsif !@whois_actif
			puts "AUCUNE DEMANDE POUR #{utilisateur}."
    elsif !utilisateur_autorise?(utilisateur)
      puts "#{utilisateur} NON AUTORISÉ par #{@nick}."
    else
      puts "NIVEAU #{niveau} insuffisant."
		end
	end

  def valide_pseudo(utilisateur)
  # Pour la validation de toutes les identifications autres que par STATUS
  # Testé sur irc.freenode.net
  	puts "[ VALIDATION de l'enregistrement de #{utilisateur}  ]"
		if @whois_actif && utilisateur_autorise?(utilisateur)
			puts "#{utilisateur} ACCEPTÉ"
			@whois_actif = false
      p = Personne.new(utilisateur)
      p.autorise = true
			@registered_users[p.nom] = p.autorise
      m = Message.new
			msg = "Tu as été enregistré sur mon robot IRC. Si tu n'en a pas fait la demande, merci de me contacter à l'adresse suivante : blanko@blanko.fr.st . J'aviserais."
      envoi m.prive(utilisateur, utilisateur, msg)
		elsif !@whois_actif
			puts "AUCUNE DEMANDE POUR #{utilisateur}."
    else !utilisateur_autorise?(utilisateur)
      puts "#{utilisateur} NON AUTORISÉ par #{@nick}."
		end
  end

#######
###
### FIN Fonctions de vérifications en tous genres
###
#######

#######
###
###  Fonctions liées aux commandes lancées par l'utilisateur
###
#######

  def commande_non_connue(exp, dest, cmd)
  # Notifie l'utilisateur qu'il a saisi une commande inconnue
   puts "[ COMMANDE INCONNUE ]"
   m = Message.new
   msg = "Commande `#{cmd}` inconnue. Taper !aide pour en savoir plus."
   # on envoir délibéremment à l'expediteur pour ne pas charger le canal
   envoi m.prive(exp, exp, msg)
 	 puts msg
  end

  def commande_aide(exp, cmd, arg)
  # Envoi un message d'aide
  # Contient:
  # - soit l'aide sur les commandes
  # - soit l'aide sur une commande particulière
  # - ou bien le fait qu'une commande soit inconnue
    puts "[ COMMANDE !aide ]"
    m = Message.new
    msg = []
    nbre = nbreMots(arg)
    if nbre > 1
      # La commande aide n'accepte qu'un maximum d'un paramètre
      msg << "Trop de paramètres. Tapez !aide pour en savoir plus."
    elsif nbre > 0
      # On demande de l'aide sur UNE commande particulière
      # Décrire ici l'aide pour chacune des commandes
      case arg
      when "aide"
        msg << "Utilisation : "
        msg << "!aide, renvoie l'ensemble des commandes disponibles."
      when "de"
        msg << "Utilisation : "
        msg << "!de <nbreFace>, avec nbreFace compris entre 1 et 100, renvoie le résultat d'un lancé de dé à <nbreFace> faces."
      when "msg"
        msg << "Utilisation : "
        msg << "!msg <destination> <message>, envoi le contenu de <message> à l'utilisateur/canal <destination>."
      when "salut"
        msg << "Utilisation : "
        msg << "!salut, vous salue dans le canal courant."
        msg << "!salut <pseudo>, salue la personne <pseudo> de votre part dans le canal courant."
        msg << "!salut <pseudo> <message>, salue la personne <pseudo>, avec le contenu de <message>, en message privé."
      when "il"
        msg << "Utilisation : "
        msg << "!il <message d'action>, fait agir le robot #{@nick}"
        msg << ""
        msg << "Exemple : "
        msg << "!il fonctionne correctement."
        msg << "renvoie le message suivant : '#{@nick} fonctionne correctement."
      when "identifie"
        msg << "Utilisation : "
        msg << "!identifie <pseudo>, permet de vérifier la permission de l'utilisateur <pseudo> à utiliser le robot."
        msg << "Il faut que l'utilisateur <pseudo> soit enregistré d'une quelconque manière sur le réseau."
        msg << "Si c'est le cas, il recevra un message privé lui indiquant qu'il s'est identifié sur le robot."
      when "quitte"
        if utilisateur_enregistre?(exp)
          msg << "Utilisation : "
          msg << "!quitte <message>, permet au robot de quitter le serveur en laissant le message <message>."
          msg << ""
          msg << "Exemple : "
          msg << "!quitte Perdu dans la fracture numérique."
          msg << "fait quitter le robot en laissant le message `Perdu dans la fracture numérique` derrière lui."
        end
      else
        # La commande est inconnue
        msg << "Commande inconnue."
        msg << "Tapez !aide pour obtenir une liste des commandes."
      end
    else
      # On affiche l'ensemble des commandes disponibles
      msg << ""
      msg << "Commandes disponibles: "
      msg << "aide, de, identifie, il, msg, salut"
      msg << "privées: quitte, s" if utilisateur_enregistre?(exp)
      msg << ""
      msg << "Tapez !aide <commande> pour plus d'informations sur une commande."
    end
    msg.each do |content|
      envoi m.prive(exp, exp, "#{content}")
    end
    debug("Nombre d'arguments : #{nbre}")
  end

  def commande_de(joueur, dest, args)
  # Lance un dé à <val> faces et affiche le résultat dans le canal du joueur
  # Nombre de faces comprises entre 1 et <valeurMax>
    puts "[ COMMANDE !de ]"
		valeurMax = 100
    m = Message.new
    nbre = nbreMots(args)
    faces = args.to_i
		if faces.between?(1,valeurMax) then
			resultat = 1 + rand(faces)
			msg = "#{joueur} lance un dé #{faces} et fait #{resultat}"
    elsif faces == 0
      msg = "Vous devez indiquer le nombre de faces du dé, Cf. l'aide apportée en message privé."
      commande_aide(joueur, "aide", "de")
		else
			msg = "Le nombre de faces possibles pour un dé est compris entre 1 et #{valeurMax}."
		end
		puts "[ FONCTION dé à #{faces} faces ]"
  	envoi m.prive(dest, joueur, msg)
  end

	def commande_salut(exp, dest, args)
  # saluer une personne, optionnellement en lui envoyant un message personnalisé 
    puts "[ COMMANDE !salut ]"
    m = Message.new
    nbreArgs = nbreMots(args)
    if nbreArgs > 1
      # Théoriquement on donne le pseudo de quelqu'un en argument un
      # Puis le message par la suite
      beneficiaire = args.split(' ')[0]
      msg = args.split("#{beneficiaire} ")[1]
      # bug de la fonction PRIV, donc deux fois beneficiaire
      envoi m.prive(beneficiaire, beneficiaire, msg)
    elsif nbreArgs == 1
      # Un argument seulement a été donné : la personne (normalement)
      # On envoie un message sur le canal en cours
      msg = "#{args}, #{exp} te salue !"
      envoi m.prive(dest, exp, msg)
    else
      msg = "Salut à toi, #{exp}"
      envoi m.prive(dest, exp, msg)
    end
	end

  def commande_il(exp, dest, args)
  # faire faire quelque chose à notre robot
    puts "[ COMMANDE !il ]"
    m = Message.new
    msg = args.to_s
    puts "[ ACTION | #{@nick} #{args} ]"
    envoi m.action(dest, exp, msg)
  end

  def commande_quitte(exp, dest, msg)
  # permet de fermer le robot IRC, 
  #  mais seulement si l'utilisateur est identifié
    puts "[ COMMANDE !quitte ]"
    m = Message.new
    if utilisateur_enregistre?(exp)
      envoi m.depart(msg)
    else
      msg = "Vous n'êtes pas autorisé à utiliser cette commande."
      # On force l'envoi à l'utilisateur (dest) en l'utilisant deux fois
      envoi m.prive(exp, exp, msg)
    end
    puts "MESSAGE : #{msg}"
  end

  def commande_msg(exp, dest, msg)
  # envoi un message privé au destinataire (dest)
    m = Message.new
    envoi m.prive(dest, exp, msg)
  end

#######
###
### FIN Fonctions liées aux commandes utilisateurs
###
#######

#######
###
###  A TRIER - Fonctions
###
#######

### Fonctions à trier, compléter, supprimer une fois inutiles, etc.

  def envoi_chaine_serveur(chaine)
  # envoi tel quel une chaîne de caractères sur le serveur
    envoi chaine
  end

#######
###
### FIN A TRIER - Fonctions
###
#######

	def handle_server_input(s)
		# This isn't at all efficient, but it shows what we can do with Ruby
		# (Dave Thomas calls this construct "a multiway if on steroids")
		case s.strip
		when /^PING :(.+)$/i
			# This is for the bot not being kick by servers
			puts "[ Server ping ]"
			envoi "PONG :#{$1}"
		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
			puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
			envoi "NOTICE #{$1} :\001PING #{$4}\001"
		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
			puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
			envoi "NOTICE #{$1} :\001VERSION Ruby-irc v0.042\001"
		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:EVAL (.+)$/i
			puts "[ EVAL #{$5} from #{$1}!#{$2}@#{$3} ]"
			envoi "PRIVMSG #{(($4==@nick)?$1:$4)} :#{evaluate($5)}"
    ## Evaluation des WHOIS
		# :clarke.freenode.net 320 NoPseudo Personne :is identified to services <= freenode
		when /^:(.+?)\s(.+?)\s#{@nick}\s(.+)\s:(.+?)identified(.+?)$/i
			puts "[ ETUDE WHOIS sur #{@whois_pseudo} ]"
      valide_pseudo($3)
		# :NickServ!services@evolu.net NOTICE NoPseudo :STATUS Personne 3 <= EVOLU.net
		when /^:(.+?)!(.+?)@(.+?)\sNOTICE\s#{@nick}\s:STATUS\s(.+)\s(.+?)$/i
      valide_pseudo_evolu($4, $5)
    when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:!(.+)$/i
      # Permet de capter les commandes !nom_de_ma_commande arguments[]
      puts "[ COMMANDE ENVOYÉE par #{$1} : #{$5} ]"
			expediteur = $1
			cible = $4
			commande = $5
      arguments = commande[/[^\s]+ +(.+)/, 1]
			case commande
			when /^aide/                #!aide => affiche l'aide
        commande_aide(expediteur, commande, arguments)
			when /^de/                  #!de => lance un dé à <args> faces
        commande_de(expediteur, cible, arguments)
			when /^salut/               #!salut => dit bonjour au canal, à une personne, ou donne un message personnalisé
        commande_salut(expediteur, cible, arguments)
      when /^il/                  #!il => fait agir le robot sur le canal (ACTION)
        commande_il(expediteur, cible, arguments)
			when /^identifie\s(\S+)$/i  #!identifie => lance l'identification du pseudo
				verification_pseudo($1)
			when /^msg\s(\S+)\s(.+)$/i   #!mp => envoie un message à quelqu'un ou à un canal
        commande_msg(expediteur, $1, $2)
			when /^s(.+)$/i             #!s => envoie une chaîne de caractère au serveur
        envoi_chaine_serveur($1)
      when /^quitte/              #!quitte => quitte le serveur irc
        commande_quitte(expediteur, cible, arguments)
			# autres commandees
			else
        commande_non_connue(expediteur, cible, commande)
			end
		else
			puts s
		end
	end
	
	def main_loop()
		# Just keep on truckin' until we disconnect
		while true
			ready = select([@irc, $stdin], nil, nil, nil)
			next if !ready
			for s in ready[0]
				if s == $stdin then
					return if $stdin.eof
					s = $stdin.gets
					envoi s
				elsif s == @irc then
					return if @irc.eof
					s = @irc.gets
					handle_server_input(s)
				end
			end
		end
	end
end

# The main program

# Version du programme
version="0.1.1"

aide = []
aide << "botirc version #{version}"
aide << ""
aide << "Utilisation : ruby botirc.rb [--aide] fichierConfiguration"
aide << "Par défaut le programme requièrt l'utilisation d'un fichier de configuration"
aide << ""
aide << "Exemples : "
aide << "ruby botirc.rb --aide     => renvoie la présente aide."
aide << "ruby botirc.rb config.yml => lance le robot IRC à l'aide du fichier de configuration config.yml"

nbreArgs = ARGV.length
if nbreArgs != 1
  # Nous avons plus d'un argument
  puts "Nombre d'arguments invalide. Tapez ruby botirc.rb --aide pour en savoir plus."
  exit
else
  # Nous avons un argument
  puts ARGV[0]
  case (cmd = ARGV[0])
  when "--aide"
    aide.each do |l|
      puts l
    end
    exit
  when /(\w+.yml)/
    # Notre fichier de configuration
    puts "nous avons un fichier YML #{$1}"
    fichier = $1.untaint
  else
    puts "Commande #{cmd} inconnue. Tapez ruby botirc.rb --aide pour en savoir plus."
    exit
  end
end

#fichier = "config.yml"
conf = FichierConf.new( fichier )
if conf.lecture_reussie? == false
  puts "Un problème est survenu sur le fichier #{fichier}, vérifier que le fichier existe."
  exit
else
  # If we get an exception, then print it out and keep going (we do NOT want
  # to disconnect unexpectedly!)
###  irc = IRC.new('localhost', 6667, 'NoIdea', '#testbot', 'anything')
  irc = IRC.new(conf)
  irc.connect()

  begin
  	irc.main_loop()
  rescue Interrupt
  rescue Exception => detail
  	puts detail.message()
	  print detail.backtrace.join("\n")
	  retry
  end
end
