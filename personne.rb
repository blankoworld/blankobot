#!/usr/bin/ruby

class Personne

	attr_accessor :nom
	attr_accessor :autorise

	def initialize(nom)
		@nom = nom
		@autorise = false
	end

	def estAutorise?()
		return true if @autorise == true
	end
end

