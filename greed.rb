class Player
	attr_reader :name, :score
	def initialize(name)
		@name = name
		@score = 0
	end
	def add_to_score(n)
		@score += n
	end
end

class DiceSet
	attr_reader :values
	def initialize
		@values = Array.new
	end
	def roll(n)
		@values.clear
		n.times { @values << rand(6) + 1 }
		score
	end
	def score
		score = 0
		no_valuable = @values.size
		@values.group_by {|n| n}.each do |key, value|
			quantity = value.length
			if quantity >= 3
				score += ( key == 1 ) ? 1000 : key * 100
				quantity -= 3
				no_valuable -= 3
			end
			if key == 5
				score += quantity * 50
				no_valuable -= quantity
			elsif key == 1
				score += quantity * 100
				no_valuable -= quantity
			end
		end
		no_valuable = 5 if no_valuable == 0
		return score, no_valuable
	end	
end

class GreedGame
	def initialize(player_list)
		raise ArgumentError, "Argument must be array of player" unless player_list.is_a?(Array) && player_list.size > 0
		@player_list = player_list
		@dice_set = DiceSet.new
	end
	def step_of_game(player)
		step_score = 0
		puts "\n#{player.name}, It's your turn! Your score: #{player.score}"
		number_of_throws = 5
		while true
			throw_score, number_of_throws = @dice_set.roll(number_of_throws)
			step_score += throw_score
			puts "\t#{player.name} throw #{@dice_set.values} (#{throw_score}). Score of step: #{step_score}!"
			if throw_score == 0
				puts "Failure! Score of throw is zero."
				break
			end
			if step_score >= 300	
				print "\t\tYou have #{number_of_throws} throw(s)! Continue? (y/n): "
				answer = gets.downcase
				if answer =~ /^n/
					player.add_to_score(step_score)
					puts "#{player.name} already has #{player.score} points."
					break
				end
			end
		end #while
	end
	def play
		puts "Game started"
		already_have_above_3000 = nil
		while already_have_above_3000.nil?
			@player_list.each do |player|
				step_of_game(player)
				if player.score > 3000
					already_have_above_3000 = player
					break #exit from each loop
				end
			end #each
		end #while
		puts "\nFinal round"
		winner = already_have_above_3000
		@player_list.each do |player| 
			if player != already_have_above_3000
				step_of_game(player)
				winner = player if player.score > winner.score
			end 
		end
		puts "\nCongratulation!!! #{winner.name} win by a score #{winner.score}"
	end
end

game = GreedGame.new([Player.new("Dima"), Player.new("Misha")])
game.play