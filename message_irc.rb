#!/usr/bin/ruby

# messageIRC.rb

## Permet de générer les chaînes de caractères à envoyer sur IRC

class Message
  def initialize()
  end

  def est_un_canal?(destination)
  # définit si l'argument est un canal ou pas
    if destination.to_s.include?("#") or destination.to_s.include?("&")
      return true
    else
      return false
    end
  end

  def destination(dest, exp)
  # retourne le bon destinataire :
  # - si c'est un canal, on prend (dest)
  # - sinon retour à l'envoyeur
    if est_un_canal?(dest)
      return dest
    else
      return exp
    end
  end

  def prive(dest, exp, msg)
  # envoie un message privé (msg) à un canal (dest) ou une personne (exp)
    if dest.to_s.include?("#") or dest.to_s.include?("&")
      chaine = "PRIVMSG #{dest} :#{msg}"
    else
      chaine = "PRIVMSG #{exp} :#{msg}"
    end
    return chaine
  end

  def joindre(dest)
  # rejoint le canal donné en paramètre (dest)
    return "JOIN #{dest}"
  end

  def action(dest, exp, msg)
  # agir sur le canal donné en paramètre (dest)
    return "PRIVMSG #{destination(dest, exp)} :\001ACTION #{msg}"
  end

  def depart(msg)
  # quitte le serveur irc en laissant un message (msg)
    msg = "Perdu dans la fracture numérique" if msg.nil?
    return "QUIT #{msg}"
  end

  def ferme(dest, msg)
  # ferme le canal donné en paramètre (dest)
    msg = "" if msg.nil?
    return "PART #{dest} :#{msg}"
  end

  def invite(dest, inv)
  # invite une personne (inv) à rejoindre le canal (dest)
    return "INVITE #{inv} #{dest}"
  end
end
