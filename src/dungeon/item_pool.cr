module Dungeon
  class ItemPool
    def self.generate_item_pool(item_pool_chart)
      item_pool = [] of NamedTuple(chance_max: Int32, klass: String)
      item_pool_chance_max = 0

      item_pool_chart.each do |item_pool_type|
        chance = 100 * item_pool_type[:chance] + item_pool_chance_max

        item_pool_type[:items].each do |item_chance|
          chance_max = (100 * item_pool_type[:chance] * item_chance[:chance] + item_pool_chance_max).to_i
          item_pool_chance_max = chance

          if item_pool_chance_max > 100
            raise "item pool over 100% chance (#{item_pool_chance_max}: #{item_chance[:klass]})"
          end

          item_pool << {chance_max: chance_max, klass: item_chance[:klass].to_s}
        end
      end

      item_pool.sort_by! { |item| item[:chance_max] }

      if Game::DEBUG
        puts "Chest item pool:"
        item_pool.each do |ic|
          puts ic
        end
      end

      item_pool
    end

    def self.get_new_item(item_pool, rand : Int32, room : Room, player : Player)
      item_pool.each do |item|
        if item[:chance_max] >= rand
          return new_item(item[:klass], room, player)
        end
      end
    end

    def self.new_item(klass : String, room : Room, player : Player)
      case (klass)
      when Key.to_s
        Key.new(loc: Location.new, player: player)
      when FullHeart.to_s
        FullHeart.new(loc: Location.new, player: player)
      when HalfHeart.to_s
        HalfHeart.new(loc: Location.new, player: player)
      when BombItem.to_s
        BombItem.new(loc: Location.new, player: player)
      when ArrowItem.to_s
        ArrowItem.new(loc: Location.new, player: player)
      when Chest.to_s
        Chest.new(loc: Location.new, room: room, player: player)
      when LockedChest.to_s
        LockedChest.new(loc: Location.new, room: room, player: player)
      end
    end
  end
end
