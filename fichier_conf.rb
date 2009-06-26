#!/usr/bin/ruby

# fichierConf.rb

require 'yaml'

class FichierConf

@@DEBUG = false

attr_accessor :serveur
attr_accessor :port
attr_accessor :canal
attr_accessor :pseudo
attr_accessor :mdp
attr_accessor :nom_utilisateur
attr_accessor :nom_hote
attr_accessor :nom_serveur
attr_accessor :nom_reel
attr_accessor :utilisateurs_autorises

  def initialize(fichier)
    @fic = fichier
    @lu = false
    # Valeurs par défaut
    @serveur = "localhost"
    @port = "6667"
    @canal = "#testbot"
    @pseudo = "Robot#{rand(1000)}"
		@nom_utilisateur = "@pseudo"
		@nom_hote = "mydomain.com"
		@nom_serveur = "mycomputer"
		@nom_reel = "Dave Null"
    begin
      @config = File.open( @fic )
      contenu = YAML::load_documents( @config ) { |doc|
        # untaint permet d'éviter un bug lors de l'évaluation dans le bot IRC
        @serveur = doc['serveur'].untaint
        @port = doc['port'].untaint
		    @canal = doc['canal'].untaint
        @pseudo = doc['pseudo'].untaint
        @mdp = doc['mdp'].untaint
        @nom_utilisateur = doc['nom_utilisateur'].untaint
        @nom_hote = doc['nom_hote'].untaint
        @nom_serveur = doc['nom_serveur'].untaint
        @nom_reel = doc['nom_reel'].untaint
        @utilisateurs_autorises = Array.new
		    doc['utilisateurs_autorises'].each do |u|
			    @utilisateurs_autorises << u
		    end
      }
    rescue
      debug("Fichier introuvable ou verrolé")
      @lu = false
      return false
    else
      debug("Lecture réussie avec succès")
      @lu = true
      return true
    ensure
      @config.close unless @config.nil?
    end
  end

  def debug(msg)
    puts msg if @@DEBUG
  end

  def afficher_params()
    return "Serv: #{@serveur} | port: #{@port} | canal: #{@canal} | pseudo: #{@pseudo} | mdp: #{@mdp}"
  end

  def lecture_reussie?
    if @lu
      return true
    else
      return false
    end
  end
end
