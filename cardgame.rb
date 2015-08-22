class CardGame
  CARD_MAX_NUM = 5
  CARD_TYPE_NUM = 3
  HAND_NUM = 7
  WIN_POINT = 3

  def initialize
    # カードの束を生成
    @card_pile = []
    (1..CARD_MAX_NUM).each do |card|
      CARD_TYPE_NUM.times do
        @card_pile << card
      end
    end

    # シャッフル
    @card_pile.sort_by!{rand}

    # 手札を配る（無駄にちゃんと上から1枚ずつ配る）
    @hand = {player1: [], player2: []}
    HAND_NUM.times do
      @hand[:player1] << @card_pile.shift
      @hand[:player2] << @card_pile.shift
    end
    # 理牌
    @hand[:player1].sort!
    @hand[:player2].sort!

    # プレイヤー生成
    @player1 = Player.new(:player1, @hand[:player1])
    @player2 = Player.new(:player2, @hand[:player2])
    @turn_player = @player1

    # 捨て札置き場とポイントの初期化
    @discard_pile = {player1: [], player2: []}
    @point = {player1: 0, player2: 0}
  end

  attr_reader :card_pile, :hand, :discard_pile, :point, :turn_player
  attr_accessor :player1, :player2

  def main
    # ラウンド処理
    begin
      wins = self.turn(@turn_player)
      if wins then
        puts "#{turn_player.side} wins!"
        return turn_player.side
      end
      self.put_result
      self.switch_player(@turn_player)
    end until @hand[:player1].empty? and @hand[:player2].empty?

    # 終了処理
    return self.game_end
  end

  def turn(player)
    discard = player.turn(@discard_pile)
    # 捨て札処理
    self.discard(player, discard)
    # ポイント獲得処理
    self.get_point(player, discard)
    # 勝利判定
    return self.victory?(player)
  end

  def discard(player, card)
    @discard_pile[player.side] << card
  end

  def get_point(player, card)
    if @discard_pile[player.side].count(card) + @discard_pile[player.opponent].count(card) == 3 then
      @point[player.side] += 1
    end
  end

  def victory?(player)
    if @point[player.side] >= WIN_POINT then
      return true
    else
      return false
    end
  end

  def game_end
    remain_card = @card_pile[0]
    puts "remain card bonus! => #{remain_card}"
    if @discard_pile[:player1].rindex(remain_card) == nil then
      @point[:player2] += 1
      winner = :player2
    elsif @discard_pile[:player2].rindex(remain_card) == nil then
      @point[:player1] += 1
      winner = :player1
    elsif @discard_pile[:player1].rindex(remain_card) > @discard_pile[:player2].rindex(remain_card) then
      @point[:player1] += 1
      winner = :player1
    else
      @point[:player2] += 1
      winner = :player2
    end

    puts "#{winner} wins!!"
    self.put_result
    return winner
  end

  def put_result
    # 捨て札を表示
    discard_p1 = @discard_pile[:player1]
    point_p1 = @point[:player1]
    puts "player1 discard pile: #{discard_p1} point: #{point_p1}"
    discard_p2 = @discard_pile[:player2]
    point_p2 = @point[:player2]
    puts "player2 discard pile: #{discard_p2} point: #{point_p2}"
    puts
  end

  def switch_player(player)
    @turn_player = case player.side
    when :player1 then @player2
    when :player2 then @player1
    end
  end
end

class Player
  def initialize(side, hand)
    @side = side
    @hand = hand
    @mode = :cpu
  end

  attr_reader :side, :hand
  attr_accessor :mode

  def turn(discard_pile)
    discard = case @mode
    when :play then self.play
    when :kuso_cpu then self.cpu_ai_kuso
    else self.cpu_ai(discard_pile)
    end
    @hand.delete_at(@hand.find_index(discard))
    puts "#{@side}: discard a card: #{discard}"

    return discard
  end

  def play
    begin
      puts "#{@side}: your hand: #{@hand}"
      print "#{@side}: which card do you discard?: "
      card = gets.to_i
    end while @hand.find_index(card).nil?

    return card
  end

  def cpu_ai(discard_pile)
    uniq_list = @hand.uniq
    my_cards = @hand.dup.concat(discard_pile[@side])
    all_cards = my_cards.dup.concat(discard_pile[self.opponent])
    priority = Hash.new

    uniq_list.each do |n|
      priority[n] = case true
      when all_cards.count(n) == 3 then 1000
      when my_cards.count(n) == 2 && hand.count(n) == 2 then 500
      when my_cards.count(n) == 2 then 10
      when hand.count(n) == 1 && discard_pile[self.opponent].count(n) == 0 then 200
      when hand.count(n) == 1 then -10
      else 0
      end
    end

    puts "debug: #{@side} cpu_priority: #{priority}"

    return priority.sort_by{|k, v| v}.last[0].to_i
  end

  def cpu_ai_kuso(side)
    return @hand[side].sample
  end

  def opponent
    return case @side
    when :player1 then :player2
    when :player2 then :player1
    end
  end
end

try_num = (ARGV == []) ? 100 : ARGV[0].to_i

result = {player1: 0, player2: 0}

try_num.times do |n|
  puts ":::Game #{n}:::"
  game = CardGame.new
  wins = game.main
  result[wins] += 1
end

puts "#{try_num} time games' result: #{result}"
