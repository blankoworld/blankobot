#!/usr/bin/ruby

# messageIRC.rb

## Permet de générer les chaînes de caractères à envoyer sur IRC

class Message
  def initialize()
  end

  def prive(dest, exp, msg)
    if dest.to_s.include?("#") or dest.to_s.include?("&")
      chaine = "PRIVMSG #{dest} :#{msg}"
    else
      chaine = "PRIVMSG #{exp} :#{msg}"
    end
    return chaine
  end

  def rejoindre(dest)
    return "JOIN #{dest}"
  end

  def action(dest, msg)
    return "PRIVMSG #{dest} :ACTION #{msg}"
  end
end
