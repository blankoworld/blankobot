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
		@authorized_users = Array.new
		
		[ "od-", "Personne", "Blankoworld", "Blanko" ].each do |u|
			@authorized_users << Personne.new(u)
		end

		## Utilise pour diverses choses
		@whois_actif = false
		@whois_pseudo = ""
		@registered_users = Array.new
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

#######
###
### FIN Fonctions diverses
###
#######

#######
###
###  Fonctions liées aux commandes lancées par l'utilisateur
###
#######

  def commande_aide(exp, cmd, arg)
  # Envoi un message d'aide
  # Contient:
  # - soit l'aide sur les commandes
  # - soit l'aide sur une commande particulière
  # - ou bien le fait qu'une commande soit inconnue
    puts "[ COMMANDE !aide ]"
    m = Message.new
    msg = Array.new
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
      when "mp"
        msg << "Utilisation : "
        msg << "!mp <destination> <message>, envoi le contenu de <message> à l'utilisateur/canal <destination>."
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
      when "pseudo"
        msg << "Utilisation : "
        msg << "!pseudo <pseudo>, permet de vérifier la permission de l'utilisateur <pseudo> à utiliser le robot."
        msg << "Il faut que l'utilisateur <pseudo> soit enregistré d'une quelconque manière sur le réseau."
      else
        # La commande est inconnue
        msg << "Commande inconnue."
        msg << "Tapez !aide pour obtenir une liste des commandes."
      end
    else
      # On affiche l'ensemble des commandes disponibles
      msg << ""
      msg << "Commandes disponibles: "
      msg << "aide, de, mp, salut, il, pseudo"
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
    m = Message.new
    msg = args.to_s
    puts "[ ACTION | #{@nick} #{args} ]"
    envoi m.action(dest, exp, msg)
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

	def whois(pseudo)
		envoi "WHOIS #{pseudo}"
		@@WHOIS = 10
	end

	def verif_pseudo(pseudo)
		puts "[ VERIFICATION PSEUDO: #{pseudo} ]"
		if @authorized_users.include?("#{pseudo}") then
			msg = "CONNU"
			resultat = true
		else
			msg = "NON CONNU"
			resultat = false
		end
		debug("L'utilisateur #{pseudo} est #{msg} de ce robot")
		@whois_actif = true
		@whois_pseudo = "#{pseudo}"
		debug(@whois_pseudo)
		# ligne pour irc.freenode.net par exemple
		envoi "WHOIS #{pseudo}"
		# ligne pour irc.evolu.net
		envoi "PRIVMSG NickServ STATUS #{pseudo}"
		return resultat
	end

	def pseudo_valide()
		# mettre ici de quoi valider le pseudo de quelqu'un avec un chiffre
		# à la rigueur afficher plusieurs résultat 0, 1, 2, 3
		# à 3, on est bon.
    # N'est utile que pour evolu.net pour le moment
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
		# :clarke.freenode.net 320 NoPseudo Personne :is identified to services <= freenode
		when /^:(.+?)\s(.+?)\s#{@nick}\s#{@whois_seudo}\s:(.+?)identified(.+?)$/i
			puts "[ ETUDE WHOIS sur #{@whois_pseudo} ]"
		# :NickServ!services@evolu.net NOTICE NoPseudo :STATUS Personne 3 <= EVOLU.net
		when /^:(.+?)!(.+?)@(.+?)\sNOTICE\s#{@nick}\s:STATUS\s#{@whois_pseudo}\s(.+?)$/i
			puts "[ ETUDE STATUT sur #{@whois_pseudo}  ]"
			if true && @whois_actif
				puts "Tu es repéré #{$4}"
				@whois_actif = false
				@registered_users << Personne.new(@whois_pseudo)
				envoi "PRIVMSG #{@whois_pseudo} :Tu as été enregistré sur mon robot IRC. Si tu n'en a pas fait la demande, merci de me contacter à l'adresse suivante : blanko@blanko.fr.st . J'aviserais."
			else
				puts "Aucune demande n'a été faite."
			end
		when /:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:!(.+)/
      puts "[ COMMANDE ENVOYÉE par #{$1} : #{$3} ]"
			expediteur = $1
			cible = $2
			commande = $3
      arguments = commande[/[^\s]+ +(.+)/, 1]
			case commande
			when /^aide/
        commande_aide(expediteur, commande, arguments)
			when /^de/
        debug("[ COMMANDE !de --> #{s} ]")
        nbreFaces = $1
        commande_de(expediteur, cible, arguments)
			when /^salut/
        puts "[ COMMANDE !salut ]"
        commande_salut(expediteur, cible, arguments)
      when /^il/
        puts "[ COMMANDE !il ]"
        commande_il(expediteur, cible, arguments)
			when /^pseudo\s(.+)$/i
				verif_pseudo($1)
			when /^mp/
				msg = "/msg #{arguments} Salut" if arguments
				debug(msg)
				envoi "PRIVMSG :#{arguments}"
			when /^s/
				msg = "#{arguments}" if arguments
				puts msg
				envoi msg
			when /^qui/
				if expediteur == "Personne"
					msg = "tu as le droit"
				else
					msg = "tu N'as PAS le droit"
				end
			# autres commandees
			else
        m = Message.new
        msg = m.prive(cible, "UTILISATEUR #{expediteur} LANCE #{commande}")
        envoi msg
				puts msg
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

aide = Array.new
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
