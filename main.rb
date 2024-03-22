require 'yaml'

class Hangman
  attr_reader :random_word, :revealed_word, :guesses_left

  def initialize
    @words = File.readlines('words.txt')
    @filtered_words = @words.select { |word| word.strip.length > 4 && word.strip.length < 13 }
    @random_word = @filtered_words.sample.strip
    @revealed_word = "_" * @random_word.length
    @incorrect_letters = []
    @guesses_left = 7
  end

  def guess_letter
    puts "Incorrect Letters: #{@incorrect_letters}"
    print "Guess a letter or enter 'save' to save your game: "

    guess = gets.chomp.downcase

    if guess == "save"
      save_game
    elsif @random_word.include?(guess)
      update_revealed_word(guess)
    else
      @incorrect_letters << guess unless @incorrect_letters.include?(guess)
      @guesses_left -= 1
    end
  end

  def game_over
    if @guesses_left == 0 
      puts "Game over! The word was #{@random_word}"
      return true
    elsif @revealed_word == @random_word
      puts "You got it! The word was #{@random_word}"
      return true
    else
      return false
    end
  end

  def save_game
    puts 'Game saved!'
    saved_data = {
      random_word: @random_word,
      revealed_word: @revealed_word,
      incorrect_letters: @incorrect_letters,
      guesses_left: @guesses_left
    }
    File.open("#{@revealed_word}.yaml", 'w') { |file| file.write(saved_data.to_yaml) }
  end

  private

  def update_revealed_word(letter)
    @random_word.chars.each_with_index do |char, index|
      @revealed_word[index] = letter if char == letter
    end
  end
end

def load_game(revealed_word)
  if File.exist?("#{revealed_word}.yaml")
    saved_data = YAML.load(File.read("#{revealed_word}.yaml"))
    Hangman.new.tap do |game|
      game.instance_variable_set(:@random_word, saved_data[:random_word])
      game.instance_variable_set(:@revealed_word, saved_data[:revealed_word])
      game.instance_variable_set(:@incorrect_letters, saved_data[:incorrect_letters])
      game.instance_variable_set(:@guesses_left, saved_data[:guesses_left])
    end
  else
    puts "No saved game found for '#{revealed_word}'."
    nil
  end
end

puts "Welcome to Hangman!"

puts "Do you want to start a new game or load a saved game? (new/load)"
response = gets.chomp.downcase

game = if response == 'new'
         Hangman.new
       elsif response == 'load'
         print "Enter the revealed word: "
         revealed_word = gets.chomp.downcase
         load_game(revealed_word)
       else
         puts "Invalid response."
         exit
       end

if game
  until game.game_over do
    puts "Revealed word: #{game.revealed_word}"
    game.guess_letter
    puts "Guesses left: #{game.guesses_left}"
  end
end
