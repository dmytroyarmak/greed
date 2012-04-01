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
	end
	def score
		score = 0
		no_valuable = @values.size
		@values.group_by {|n| n}.each do |key, value|
			len = value.length
			if len >= 3
				score += (key == 1)? 1000 : key * 100
				len -= 3
				no_valuable -= 3
			end
			if key == 5
				score += len * 50
				no_valuable -= len
			elsif key == 1
				score += len * 100
				no_valuable -= len
			end
		end
		no_valuable = 5 if no_valuable == 0
		return score, no_valuable
	end	
end

class GreedGame
	
	def initialize(a_player_list)
		raise ArgumentError, "Argument must be array of player" unless a_player_list.is_a?(Array) && a_player_list.size > 0
		@player_list = a_player_list
		@dice_set = DiceSet.new
	end

	def step_of_game(player)
		current_score = 0
		puts "\n#{player.name}! It's your step! Your score: #{player.score}"
		number_of_rolls = 5
		while true
			@dice_set.roll(number_of_rolls)
			tmp_score, number_of_rolls = @dice_set.score
			current_score += tmp_score
			puts "\t#{player.name} roll #{@dice_set.values} (#{tmp_score}). Turn score: #{current_score}!"
			if tmp_score == 0
				puts "Fail!!! Zero-point roll."
				break
			end
			if current_score >= 300	
				print "\t\tYou have #{number_of_rolls} roll(s)! Continue? (y/n): "
				answer = STDIN.gets
				if answer =~ /^n/
					player.add_to_score(current_score)
					puts "#{player.name} has #{player.score} points."
					break
				end
			end
		end #while
	end

	def start
		puts "Game started"
		already_have_above_3000 = nil
		while already_have_above_3000.nil?
			@player_list.each do |player|
				step_of_game(player)
				if player.score > 3000
					puts "\n#{player.name} already have #{player.score} points!"
					already_have_above_3000 = player
					break
				end
			end
		end
		# Final round
		puts "\nFinal round"
		@player_list.each { |player| step_of_game(player) if player != already_have_above_3000}
		# Who won?
		winner = already_have_above_3000
		@player_list.each{ |player| winner = player if player.score > winner.score}
		puts "\nСongratulation!!! #{winner.name} won with score: #{winner.score}"
	end

end

game = GreedGame.new([Player.new("Dima"), Player.new("Misha")])
game.start