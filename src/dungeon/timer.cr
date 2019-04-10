module Dungeon
  class Timer
    getter time
    getter? active

    def initialize(@length : Float64 | Float32 | Int32)
      @active = false
      @time = 0_f32
    end

    def start
      @active = true
    end

    def done?
      active? && @time >= @length
    end

    def reset
      @active = false
      @time = 0_f32
    end

    def restart
      reset
      start
    end

    def increase(delta_t : Float32)
      start unless active?
      @time += delta_t
    end

    def percentage
      @time / @length
    end
  end
end
