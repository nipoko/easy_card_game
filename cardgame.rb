class CardGame
  CARD_MAX_NUM = 5
  CARD_TYPE_NUM = 3
  HAND_NUM = 7
  WIN_POINT = 3

  # 
  # 初期化
  # 
  # @return [nil]
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

    @discard_pile = {player1: [], player2: []}
    @point = {player1: 0, player2: 0}
  end

  attr_reader :card_pile, :hand, :discard_pile, :point

  def main
    HAND_NUM.times do
      self.put_result
      result = self.cpu_turn(:player1)
      unless result.nil? then
        return result
      end
      puts
      self.put_result
      result = self.cpu_turn(:player2)
      unless result.nil? then
        return result
      end
      puts
    end

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

    puts "#{winner} wins!"
    self.put_result
    return winner
  end

  def player_turn(side)
    # 捨て札選択
    begin
      hand = @hand[side]
      puts "#{side}: your hand: #{hand}"
      print "#{side}: which card do you discard?: "
      discard = gets.to_i
    end while @hand[side].find_index(discard).nil?
    # 捨て札処理
    @hand[side].delete_at(@hand[side].find_index(discard))
    @discard_pile[side] << discard
    # ポイント獲得処理
    if @discard_pile[side].count(discard) + @discard_pile[opponent(side)].count(discard) == 3 then
      @point[side] += 1
    end
    if @point[side] >= WIN_POINT then
      puts "Player1 wins!"
      self.put_result
      return side
    end

    return nil
  end

  def cpu_turn(side, mode = "normal")
    discard = (mode == "kuso") ? self.cpu_ai_kuso(side) : self.cpu_ai(side)
    @hand[side].delete_at(@hand[side].find_index(discard))
    @discard_pile[side] << discard
    puts "#{side}: discard a card: #{discard}"
    # ポイント獲得処理
    if @discard_pile[side].count(discard) + @discard_pile[opponent(side)].count(discard) == 3 then
      @point[side] += 1
    end
    if @point[side] >= WIN_POINT then
      puts "#{side} wins!"
      self.put_result
      return side
    end

    return nil
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

  def cpu_ai(side)
    uniq_list = @hand[side].uniq
    my_cards = @hand[side].dup.concat(@discard_pile[side])
    all_cards = my_cards.dup.concat(@discard_pile[opponent(side)])
    priority = Hash.new

    uniq_list.each do |n|
      priority[n] = case true
      when all_cards.count(n) == 3 then 1000
      when my_cards.count(n) == 2 && @hand[side].count(n) == 2 then 500
      when my_cards.count(n) == 2 then 10
      when @hand[side].count(n) == 1 && @discard_pile[opponent(side)].count(n) == 0 then 200
      when @hand[side].count(n) == 1 then -10
      else 0
      end
    end

    puts "debug: #{side} cpu_priority: #{priority}"

    return priority.sort_by{|k, v| v}.last[0].to_i
  end

  def cpu_ai_kuso(side)
    return @hand[side].sample
  end

  def opponent(side)
    if side == :player1 then return :player2
    else return :player1
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
