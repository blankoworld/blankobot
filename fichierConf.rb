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
attr_accessor :utilisateursAutorises

  def initialize(fichier)
    @fic = fichier
    @lu = false
    # Valeurs par défaut
    @serveur = "localhost"
    @port = "6667"
    @canal = "#testbot"
    @pseudo = "Robot#{rand(1000)}"
    begin
      @config = File.open( @fic )
      contenu = YAML::load_documents( @config ) { |doc|
        # untaint permet d'éviter un bug lors de l'évaluation dans le bot IRC
        @serveur = doc['serveur'].untaint
        @port = doc['port']
		    @canal = doc['canal']
        @pseudo = doc['pseudo']
        @mdp = doc['mdp']
        @utilisateursAutorises = Array.new
		    doc['utilisateursAutorises'].each do |u|
			    @utilisateursAutorises << u
		    end
      }
    rescue
      puts "Fichier introuvable ou verrolé" if true & @@DEBUG
      @lu = false
      return false
    else
      puts "Lecture réussie avec succès" if true & @@DEBUG
      @lu = true
      return true
    ensure
      @config.close unless @config.nil?
    end
  end

  def afficher()
    return "Serv: #{@serveur} | port: #{@port} | canal: #{@canal} | pseudo: #{@pseudo} | mdp: #{@mdp}"
  end

  def lectureReussie?
    if true & @lu
      return true
    else
      return false
    end
  end
end
