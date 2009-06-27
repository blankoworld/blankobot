#!/usr/bin/ruby

# personne.rb

# Copyright 2009 by 413x (http://snippets.dzone.com/user/413x) and Olivier DOSSMANN (Blankoworld)

# This file is part of BlankoBot.
# 
# BlankoBot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# BlankoBot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with BlankoBot.  If not, see <http://www.gnu.org/licenses/>.

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

