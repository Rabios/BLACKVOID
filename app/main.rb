# Written by Rabia Alhaffar in 26/May/2021
# Void, Roguelike-Survival game done in over 6 days with Ruby via DRGTK for DRGTK classics jam: Gauntlet Edition
# Updated: 4/June/2021

# Background: https://wallpaperaccess.com/download/black-space-1268183

# Used stuff from Kenney (https://www.kenney.nl)
# https://www.kenney.nl/assets/space-shooter-redux
# https://www.kenney.nl/assets/sci-fi-sounds

# Used sounds from freesound.org
# https://freesound.org/people/medetix/sounds/177906 
# https://freesound.org/people/Sjonas88/sounds/538548
# https://freesound.org/people/old_waveplay/sounds/399934

# (Licensed under the Creative Commons 0 License.)

# We also used these prompts:
# https://thoseawesomeguys.com/prompts

# Special thanks to:
# @Akzidenz-Grotesk
# @kota
# @amirrajan
# @leviondiscord
# @magiondiscord

def tick args
  setup args
  load_data args
  update_touch args
  
  if args.state.current_scene == 0
    main_menu args
  elsif args.state.current_scene == 1
    credits_menu args
  elsif args.state.current_scene == 2
    how_to_play_menu args
  elsif args.state.current_scene == 3
    select_game_difficulty args
  elsif args.state.current_scene == 4
    if args.state.paused_game == 0
      create_enemies args
      draw_gameplay args
      handle_gameplay_input args
      handle_gameplay_physics args
    end
  elsif args.state.current_scene == 5
    pause_menu args
  end
end

def update_touch args
  if is_mobile
    args.state.touch1_prev = args.state.touch1
    args.state.touch2_prev = args.state.touch2
    
    args.state.touch1 = !args.inputs.finger_one.nil? ? 1 : 0
    args.state.touch2 = !args.inputs.finger_two.nil? ? 1 : 0
  end
end

def play_shoot_sound args
  args.audio[:shoot] ||= {
    input: "audio/177906__medetix__pc-bitcrushed-lazer-beam.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_combo_lose_sound args
  args.audio[:down] ||= {
    input: "audio/sfx_shieldDown.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_destroy_sound args
  args.audio[:crash] ||= {
    input: "audio/explosionCrunch_000.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_lose_sound args
  args.audio[:lose] ||= {
    input: "audio/sfx_twoTone.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_new_wave_sound args
  args.audio[:wave] ||= {
    input: "audio/sfx_zap.ogg",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_select_sound args
  args.audio[:select] ||= {
    input: "audio/399934__old-waveplay__perc-short-click-snap-perc.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def play_back_sound args
  args.audio[:back] ||= {
    input: "audio/538548__sjonas88__select-3.wav",
    x: 0.0,
    y: 0.0,
    z: 0.0,
    gain: 1.0,
    pitch: 1.0,
    paused: false,
    looping: false,
  }
end

def is_mobile
  return ($gtk.platform == "iOS" || $gtk.platform == "Android")
end

def setup args
  args.state.player_x                   ||= (1280 / 2) - 64
  args.state.player_y                   ||= ((720 + 84) / 2)
  args.state.world_center_x             ||= 1280 / 2
  args.state.world_center_y             ||= 720 / 2
  args.state.bullet_speed               ||= 15
  args.state.player_dist                ||= 0
  args.state.angle                      ||= 0
  args.state.angle_offset               ||= 90
  args.state.loaded_saved_game          ||= 0
  args.state.player_rotation_dist       ||= 8
  args.state.played_game_previously     ||= 0
  args.state.access_from_pause_menu     ||= 0
  args.state.game_loaded                ||= 0
  args.state.created_enemies            ||= 0
  args.state.combo                      ||= 0
  args.state.current_scene              ||= 0
  args.state.player_alive               ||= 1
  args.state.score                      ||= 0
  args.state.enemy_count_per_wave       ||= 10
  args.state.enemies_killed             ||= 0
  args.state.paused_game                ||= 0
  args.state.total_killed_enemies       ||= 0
  args.state.wave                       ||= 1
  args.state.menu_selection             ||= 1
  args.state.game_difficulty_selection  ||= 0
  args.state.pause_menu_selection       ||= 0
  args.state.bullets                    ||= []
  args.state.offside_bullets            ||= []
  args.state.enemies                    ||= []
  args.state.touch1                     ||= 0
  args.state.touch2                     ||= 0
  args.state.touch1_prev                ||= 0
  args.state.touch2_prev                ||= 0
  args.state.player_center_x            ||= 0
  args.state.player_center_y            ||= 0
  args.state.vpad_alpha                 ||= 100
  args.state.game_over_label_alpha      ||= 0
  args.state.void_mode                  ||= 0
  args.state.stats_combo                ||= 0
  args.state.stats_score                ||= 0
  args.state.stats_wave                 ||= 0
  args.state.stats_total_killed_enemies ||= 0
  args.state.enemies_max_dist           ||= 8000
  args.state.enemies_min_dist           ||= 1000
  args.state.dev                        ||= 0 # DEV MODE
  
  # DEMO
  args.state.demo_player_x              ||= (1280 / 2) - 64
  args.state.demo_player_y              ||= ((720 + 84) / 2)
  args.state.demo_world_center_x        ||= 1280 / 2
  args.state.demo_world_center_y        ||= 720 / 2
  args.state.demo_bullet_speed          ||= 15
  args.state.demo_player_dist           ||= 0
  args.state.demo_angle                 ||= 0
  args.state.demo_angle_offset          ||= 90
  args.state.demo_created_enemies       ||= 0
  args.state.demo_player_rotation_dist  ||= 8
  args.state.demo_enemy_count_per_wave  ||= 10
  args.state.demo_bullets               ||= []
  args.state.demo_offside_bullets       ||= []
  args.state.demo_enemies               ||= []
  args.state.demo_enemies_killed        ||= 0
  args.state.demo_gun_activated         ||= 0
  args.state.demo_player_center_x       ||= 0
  args.state.demo_player_center_y       ||= 0
  args.state.demo_enemies_max_dist      ||= 8000
  args.state.demo_enemies_min_dist      ||= 1000
  
  args.state.main_menu_recs ||= [
    args.layout.rect({ col: 0.10, row: 9.10,  w: 4.8,  h: 1 }),     # CONTINUE
    args.layout.rect({ col: 0.10, row: 10.3,  w: 8.2,  h: 1 }),     # START NEW GAME
    args.layout.rect({ col: 17.1, row: 10.3,  w: 6.9,  h: 1 }),     # HOW TO PLAY?
    args.layout.rect({ col: 17.1, row: 11.55, w: 4.25, h: 1 }),     # CREDITS
    args.layout.rect({ col: 0.10, row: 11.55, w: 4.6,  h: 1 }),     # BYE BYE!
  ]
  
  args.state.select_game_difficulty_recs ||= [
    args.layout.rect({ col: 4.32, row: 2.3, w: 15.4, h: 4.6 }),     # NORMAL MODE
    args.layout.rect({ col: 4.32, row: 7.3, w: 15.4, h: 4.6 }),     # VOID MODE
    args.layout.rect({ col: -0.4, row: 12,  w: 2.3,  h: 1   }),     # BACK
  ]
  
  args.state.vpad_recs ||= [
    args.layout.rect({ row: 10.1,  col: 19.8, w: 2.5,  h: 2.5 }),   # A
    args.layout.rect({ row: 8.25,  col: 21.7, w: 2.5,  h: 2.5 }),   # B
    args.layout.rect({ row: 7.8,   col: 1.45, w: 1.5,  h: 1.8 }),   # UP
    args.layout.rect({ row: 10.7,  col: 1.4,  w: 1.55, h: 1.8 }),   # DOWN
    args.layout.rect({ row: 9.4,   col: 0,    w: 1.55, h: 1.5 }),   # LEFT
    args.layout.rect({ row: 9.4,   col: 2.8,  w: 1.8,  h: 1.5 }),   # RIGHT
  ]
  
  args.state.pause_menu_recs ||= [
    args.layout.rect({ col: 0, row: 5.92,  w: 5.35, h: 1 }),        # CONTINUE
    args.layout.rect({ col: 0, row: 7.40,  w: 5.92, h: 1 }),        # MAIN MENU
    args.layout.rect({ col: 0, row: 8.82,  w: 7.5,  h: 1 }),        # HOW TO PLAY?
    args.layout.rect({ col: 0, row: 10.25, w: 4.7,  h: 1 }),        # CREDITS
    args.layout.rect({ col: 0, row: 11.7,  w: 5,    h: 1 }),        # BYE BYE!
  ]
end

def rand_img()
  imgarr = [
    "sprites/meteorBrown_big1.png",
    "sprites/meteorBrown_big2.png",
    "sprites/meteorBrown_big3.png",
    "sprites/meteorBrown_big4.png",
    "sprites/meteorGrey_big1.png",
    "sprites/meteorGrey_big2.png",
    "sprites/meteorGrey_big3.png",
    "sprites/meteorGrey_big4.png",
  ]
  
  ri = rand(imgarr.length)
  return imgarr[ri]
end

def draw_background(args)
  args.outputs.primitives << {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    path: "sprites/background.jpg"
  }.sprite!
end

def touch_down(args, idx)
  if (idx == 0)
    return (args.state.touch1 == 1)
  elsif (idx == 1)
    return (args.state.touch2 == 1)
  end
end

def touch_press(args, idx)
  if (idx == 0)
    return ((args.state.touch1 == 1) && (args.state.touch1 != args.state.touch1_prev))
  elsif (idx == 1)
    return ((args.state.touch2 == 1) && (args.state.touch2 != args.state.touch2_prev))
  end
end

def touch_rec(args, idx)
  if (idx == 0)
    return ({ x: args.inputs.finger_one.x, y: args.inputs.finger_one.y, w: 1, h: 1 })
  elsif (idx == 1)
    return ({ x: args.inputs.finger_two.x, y: args.inputs.finger_two.y, w: 1, h: 1 })
  end
end

def rand_between(a, b)
  return (((rand() * (b - a)) + a) | 0)
end

def shoot_forward args
  play_shoot_sound args
  
  args.state.bullets << ({
    x: args.state.player_center_x + 32,
    y: args.state.player_center_y + 32,
    angle: (args.state.angle + args.state.angle_offset) * 3.14 / 180,
  })
end

def shoot_backward args
  play_shoot_sound args
  
  args.state.offside_bullets << ({
    x: args.state.player_center_x + 32,
    y: args.state.player_center_y + 32,
    angle: (args.state.angle + args.state.angle_offset) * 3.14 / 180,
  })
end

def move_left args
  args.state.angle += args.state.player_rotation_dist
end

def move_right args
  args.state.angle -= args.state.player_rotation_dist
end

def handle_player_collision(args, a1)
  if args.state.player_alive == 1
    a1.length.times.map do |i|
      if a1[i]
        px = a1[i].x - args.state.player_center_x
        py = a1[i].y - args.state.player_center_y
    
        if (Math::sqrt((px * px) + (py * py)) <= 64)
          if args.state.void_mode == 0
            if args.state.combo < 2
              play_lose_sound args
              args.state.player_alive = 0
            else
              play_combo_lose_sound args
              a1.delete_at(i)
              args.state.enemies_killed += 1
              args.state.total_killed_enemies += 1
              args.state.combo = 0
            end
          else
            play_lose_sound args
            args.state.player_alive = 0
          end
        end
      end
    end
  end
end

def handle_bullets_collision(args, a1, a2)
  if args.state.player_alive == 1
    if ((a2.length > 0) && (a1.length > 0))
      a2.length.times.map do |i|
        a1.length.times.map do |j|
          if a2[i] && a1[j]
            px = a2[i].x - a1[j].x
            py = a2[i].y - a1[j].y
          
            if (Math::sqrt((px * px) + (py * py)) <= 64)
              play_destroy_sound args
              args.state.enemies_killed += 1
              args.state.total_killed_enemies += 1
              args.state.combo += 1
              args.state.score += 50 * args.state.combo
              a1.delete_at(j)
              a2.delete_at(i)
            end
          end
        end
      end
    end
  end
end

def handle_gameplay_physics args
  handle_bullets_collision(args, args.state.enemies, args.state.bullets)
  handle_bullets_collision(args, args.state.enemies, args.state.offside_bullets)
  handle_player_collision(args, args.state.enemies)
end

def create_new_wave args
  play_new_wave_sound args
  args.state.enemies = []
  args.state.enemies_killed = 0
  args.state.created_enemies = 0
  args.state.wave += 1
  args.state.played_game_previously = 1
  args.state.enemy_count_per_wave += 10
  save_data args
end

def create_enemies args
  if args.state.created_enemies + 1 <= args.state.enemy_count_per_wave
    angle = rand(Math::PI * 40)
    dist = rand_between(args.state.enemies_min_dist, args.state.enemies_max_dist)
    xpos = dist * Math::cos(angle) + (1280 / 2) - 64
    ypos = dist * Math::sin(angle) + (720 - 64) / 2
    
    evx = 4 * Math::cos(angle)
    evy = 4 * Math::sin(angle)
    
    args.state.enemies << {
      x: xpos,
      y: ypos,
      vx: evx,
      vy: evy,
      path: rand_img()
    }
    
    args.state.created_enemies += 1
  end
end

def draw_gameplay args
  draw_background args
  draw_gameplay_enemies args
  
  if args.state.player_alive == 1
    draw_gameplay_bullets args
    draw_gameplay_player args
  end
  
  args.outputs.primitives << {
    x: 16,
    y: 16.from_top,
    text: "DESTROYED ASTEROIDS: #{args.state.enemies_killed}/#{args.state.enemy_count_per_wave}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 8,
    r: 255,
    g: 0,
    b: 0,
    a: 255
  }.label!
  
  args.outputs.primitives << {
    x: 16,
    y: 64.from_top,
    text: "SCORE: #{args.state.score}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 6,
    r: 35,
    g: 155,
    b: 255,
    a: 255
  }.label!
  
  args.outputs.primitives << {
    x: 16,
    y: 96.from_top,
    text: "COMBO: #{args.state.combo}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 6,
    r: 35,
    g: 155,
    b: 255,
    a: 255
  }.label!
  
  args.outputs.primitives << {
    x: 16,
    y: 128.from_top,
    text: "WAVE: #{args.state.wave}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 6,
    r: 35,
    g: 155,
    b: 255,
    a: 255
  }.label!
  
  if !is_mobile
    args.outputs.primitives << {
      x: 12,
      y: 32,
      text: "PRESS ESCAPE KEY TO PAUSE GAME!",
      font: "fonts/kenvector_future.ttf",
      size_enum: 2,
      r: 35,
      g: 155,
      b: 255,
      a: 255
    }.label!
  else
    args.outputs.primitives << {
      x: 1210,
      y: 0.from_top,
      text: "||",
      font: "fonts/kenvector_future.ttf",
      size_enum: 42,
      r: 255,
      g: 255,
      b: 255,
      a: 255
    }.label!
  end
  
  if args.state.player_alive == 0
    args.state.game_over_label_alpha += 3
    
    args.outputs.primitives << {
      x: 250,
      y: 202.from_top,
      text: "GAME OVER!",
      font: "fonts/kenvector_future.ttf",
      size_enum: 48,
      r: 200,
      g: 0,
      b: 255,
      a: args.state.game_over_label_alpha
    }.label!
    
    if args.state.game_over_label_alpha >= 255
      args.outputs.primitives << {
        x: 70,
        y: 402.from_top,
        text: "TAP SCREEN OR PRESS ENTER KEY TO GO TO MAIN MENU",
        font: "fonts/kenvector_future.ttf",
        size_enum: 8,
        r: 255,
        g: 255,
        b: 255,
        a: 255
      }.label!
    end
  end
  
  if args.state.player_alive == 1
    if is_mobile || args.state.dev == 1
      draw_gameplay_vpad args
    end
  end
end

def draw_gameplay_vpad args
  args.outputs.primitives << {
    x: 0,
    y: 16,
    w: 256,
    h: 256,
    path: "sprites/XboxSeriesX_Dpad.png",
    r: 255,
    g: 255,
    b: 255,
    a: args.state.vpad_alpha
  }.sprite!
  
  args.outputs.primitives << args.state.vpad_recs[0].merge({
    path: "sprites/XboxSeriesX_A.png",
    a: args.state.vpad_alpha
  }).sprite!
  
  args.outputs.primitives << args.state.vpad_recs[1].merge({
    path: "sprites/XboxSeriesX_B.png",
    a: args.state.vpad_alpha
  }).sprite!
  
  if args.state.dev == 1 && !is_mobile
    draw_gameplay_vpad_layout args
  end
end

def draw_gameplay_vpad_layout args
  args.state.vpad_recs.length.times.map do |i|
    args.outputs.primitives << args.state.vpad_recs[i].merge({
      r: 255,
      g: 0,
      b: 0,
      a: args.state.vpad_alpha
    }).border!
  end
end

def draw_gameplay_enemies args
  args.state.enemies.length.times.map do |i|
    args.state.enemies[i].x -= args.state.enemies[i].vx
    args.state.enemies[i].y -= args.state.enemies[i].vy
    
    args.outputs.primitives << args.state.enemies[i].merge({
      w: 64,
      h: 64,
    }).sprite!
  end
end

def draw_gameplay_player args
  if args.state.player_alive == 1
    args.outputs.primitives << {
      x: 496,
      y: 512.from_top,
      w: 256,
      h: 256,
      path: "sprites/pass_player.png",
    }.sprite!
  
    args.state.player_center_x = (args.state.world_center_x + args.state.player_dist * Math::cos(args.state.angle * 3.14 / 180)) - 64
    args.state.player_center_y = (args.state.world_center_y.from_top + args.state.player_dist * Math::sin(args.state.angle * 3.14 / 180)) - 72

    args.outputs.primitives << {
      x: args.state.player_center_x,
      y: args.state.player_center_y,
      w: 96,
      h: 96,
      path: "sprites/playerShip3_blue.png",
      angle: args.state.angle
    }.sprite!
  end
end

def draw_gameplay_bullets args
  args.state.bullets.length.times.map do |i|
    args.state.bullets[i].x += args.state.bullet_speed * Math::cos(args.state.bullets[i].angle)
    args.state.bullets[i].y += args.state.bullet_speed * Math::sin(args.state.bullets[i].angle)
    
    args.outputs.primitives << args.state.bullets[i].merge({
      w: 32,
      h: 32,
      path: "sprites/laserBlue08.png"
    }).sprite!
  end
  
  args.state.offside_bullets.length.times.map do |i|
    args.state.offside_bullets[i].x -= args.state.bullet_speed * Math::cos(args.state.offside_bullets[i].angle)
    args.state.offside_bullets[i].y -= args.state.bullet_speed * Math::sin(args.state.offside_bullets[i].angle)
    
    args.outputs.primitives << args.state.offside_bullets[i].merge({
      w: 32,
      h: 32,
      path: "sprites/laserBlue08.png"
    }).sprite!
  end
  
  args.state.bullets.delete_if do |bullet|
    bullet.x < 0 || bullet.x > 1280 || bullet.y < 0 || bullet.y > 720
  end
  
  args.state.offside_bullets.delete_if do |offside_bullet|
    offside_bullet.x < 0 || offside_bullet.x > 1280 || offside_bullet.y < 0 || offside_bullet.y > 720
  end
  
  if args.state.enemies_killed == args.state.enemy_count_per_wave
    create_new_wave args
  end
end

def handle_gameplay_input args
  if args.state.player_alive == 1
    2.times.map do |i|
      
      if touch_press(args, i)
        4.times.map do |j|
          if touch_rec(args, i).intersect_rect?(args.state.vpad_recs[j])
            if ((j == 0) || (j == 2))
              shoot_forward args
            end
            if ((j == 1) || (j == 3))
              shoot_backward args
            end
          end
        end
      end
      
      if touch_down(args, i)
        2.times.map do |j|
          if touch_rec(args, i).intersect_rect?(args.state.vpad_recs[4 + j])
            if ((j + 4) == 4)
              move_left args
            end
            if ((j + 4) == 5)
              move_right args
            end
          end
        end
      end
    end
    
    if args.inputs.keyboard.key_down.up || args.inputs.keyboard.key_down.w || args.inputs.controller_one.key_down.a
      shoot_forward args
    end
  
    if args.inputs.keyboard.key_down.down || args.inputs.keyboard.key_down.s || args.inputs.controller_one.key_down.b
      shoot_backward args
    end
    
    if args.inputs.keyboard.left || args.inputs.controller_one.left
      move_left args
    end
    
    if args.inputs.keyboard.right || args.inputs.controller_one.right
      move_right args
    end
  else
    if args.state.game_over_label_alpha >= 255
      if args.inputs.keyboard.key_down.enter || touch_press(args, 0)
        args.state.current_scene = 0
      
        if (args.state.score >= args.state.stats_score)
          args.state.stats_score = args.state.score
        
          if (args.state.score == args.state.stats_score)
            if ((args.state.combo >= args.state.stats_combo) && (args.state.wave >= args.state.stats_wave) && (args.state.total_killed_enemies >= args.state.stats_total_killed_enemies))
              args.state.stats_combo = args.state.combo
              args.state.stats_wave = args.state.wave
              args.state.stats_total_killed_enemies = args.state.total_killed_enemies
            end
          elsif (args.state.score > args.state.stats_score)
            args.state.stats_combo = args.state.combo
            args.state.stats_wave = args.state.wave
            args.state.stats_total_killed_enemies = args.state.total_killed_enemies
          end
        end
      
        clear_data args
      end
    end
  end
  
  if args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.start || (touch_press(args, 0) && ({ x: args.inputs.finger_one.x, y: args.inputs.finger_one.y, w: 1, h: 1 }).intersect_rect?(args.layout.rect({ col: 22.78, row: -0.70, w: 1.2, h: 1.6 }))) || (args.state.dev == 1 && args.inputs.mouse.click && ({ x: args.inputs.mouse.x, y: args.inputs.mouse.y, w: 1, h: 1 }).intersect_rect?(args.layout.rect({ col: 22.78, row: -0.70, w: 1.2, h: 1.6 })))
    play_back_sound args
    args.state.paused_game = 1
    args.state.access_from_pause_menu = 1
    args.state.current_scene = 5 
  end
end

def draw_selection_rect args
  if args.state.current_scene == 0
    args.outputs.primitives << args.state.main_menu_recs[args.state.menu_selection].merge({
      r: 35,
      g: 155,
      b: 255,
      a: 255,
    }).border!
  elsif args.state.current_scene == 3
    args.outputs.primitives << args.state.select_game_difficulty_recs[args.state.game_difficulty_selection].merge({
      r: 35,
      g: 155,
      b: 255,
      a: 255
    }).border!
  elsif args.state.current_scene == 5
    args.outputs.primitives << {
      x: 0,
      y: (420 + args.state.pause_menu_selection * 75).from_top,
      w: 1280,
      h: 75,
      r: 35,
      g: 155,
      b: 255,
      a: 255,
    }.solid!
  end
end

def selection_rect_input args
  if args.state.current_scene == 0
    if (args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_down.w || args.inputs.controller_one.key_down.left) || (args.inputs.keyboard.key_down.up || args.inputs.controller_one.key_down.up)
      play_select_sound args
      if args.state.played_game_previously == 1
        if args.state.menu_selection == 0
          args.state.menu_selection = args.state.main_menu_recs.length - 1
        elsif args.state.menu_selection == 1
          args.state.menu_selection = 0
        elsif args.state.menu_selection > 1
          args.state.menu_selection -= 1
        end
      else
        if args.state.menu_selection == 1
          args.state.menu_selection = args.state.main_menu_recs.length - 1
        elsif args.state.menu_selection > 1
          args.state.menu_selection -= 1
        end
      end
    end
    
    if (args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_down.s || args.inputs.controller_one.key_down.right) || (args.inputs.keyboard.key_down.down || args.inputs.controller_one.key_down.down)
      play_select_sound args
      
      if args.state.menu_selection == args.state.main_menu_recs.length - 1
        if args.state.played_game_previously == 1
          args.state.menu_selection = 0
        else
          args.state.menu_selection = 1
        end
      else
        args.state.menu_selection += 1
      end
    end
    
    if args.inputs.keyboard.key_down.enter || args.inputs.controller_one.key_down.a
      play_select_sound args
      
      if args.state.menu_selection == 0
        args.state.current_scene = 4
        args.state.paused_game = 0
      elsif args.state.menu_selection == 1
        args.state.game_difficulty_selection = 0
        
        if (args.state.played_game_previously == 0)
          args.state.void_mode = 0
        end
        
        args.state.current_scene = 3
      elsif args.state.menu_selection == 2
        args.state.current_scene = 2
      elsif args.state.menu_selection == 3
        args.state.current_scene = 1
      elsif args.state.menu_selection == 4
        if $gtk.platform != "Emscripten"
          $gtk.exit
        end
      end
      
      args.state.pause_menu_selection = 0
      
      if args.state.played_game_previously == 1
        args.state.menu_selection = 0
      else
        args.state.menu_selection = 1
      end
      
      args.state.game_difficulty_selection = 0
    end
    
    if args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.b
      play_back_sound args
      
      if $gtk.platform != "Emscripten"
        $gtk.exit
      end
    end
  elsif args.state.current_scene == 1
    if (args.inputs.mouse.click && ({ x: args.inputs.mouse.x, y: args.inputs.mouse.y, w: 1, h: 1 }).intersect_rect?(args.layout.rect({ col: 9.4, row: 7.75, w: 5.15, h: 4.3 })))
      play_select_sound args
      $gtk.openurl "https://dragonruby.org/toolkit/game"
    end
    
    if (args.inputs.keyboard.key_down.enter || args.inputs.controller_one.key_down.a) || (args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.b)
      play_back_sound args
      
      if args.state.played_game_previously == 1
        args.state.menu_selection = 0
      else
        args.state.menu_selection = 1
      end
      
      if args.state.access_from_pause_menu == 0
        args.state.current_scene = 0
        args.state.pause_menu_selection = 0
        args.state.game_difficulty_selection = 0
        args.state.access_from_pause_menu = 0
      elsif args.state.access_from_pause_menu == 1
        args.state.current_scene = 5
        args.state.pause_menu_selection = 0
        args.state.game_difficulty_selection = 0
        args.state.access_from_pause_menu = 1
      end
    end
  elsif args.state.current_scene == 2
    if (args.inputs.keyboard.key_down.enter || args.inputs.controller_one.key_down.a) || (args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.b)
      play_back_sound args
      
      if args.state.played_game_previously == 1
        args.state.menu_selection = 0
      else
        args.state.menu_selection = 1
      end
      
      if args.state.access_from_pause_menu == 0
        args.state.current_scene = 0
        args.state.pause_menu_selection = 0
        args.state.game_difficulty_selection = 0
        args.state.access_from_pause_menu = 0
      elsif args.state.access_from_pause_menu == 1
        args.state.current_scene = 5
        args.state.pause_menu_selection = 0
        args.state.game_difficulty_selection = 0
        args.state.access_from_pause_menu = 1
      end
    end
  elsif args.state.current_scene == 3
    if (args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_down.w || args.inputs.controller_one.key_down.left) || (args.inputs.keyboard.key_down.up || args.inputs.controller_one.key_down.up)
      play_select_sound args
      if (args.state.game_difficulty_selection == 0)
        args.state.game_difficulty_selection = args.state.select_game_difficulty_recs.length - 1
      else
        args.state.game_difficulty_selection -= 1
      end
    end
    
    if (args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_down.s || args.inputs.controller_one.key_down.right) || (args.inputs.keyboard.key_down.down || args.inputs.controller_one.key_down.down)
      play_select_sound args
      if (args.state.game_difficulty_selection == args.state.select_game_difficulty_recs.length - 1)
        args.state.game_difficulty_selection = 0
      else
        args.state.game_difficulty_selection += 1
      end
    end
    
    if args.inputs.keyboard.key_down.enter || args.inputs.controller_one.key_down.a
      if args.state.game_difficulty_selection == args.state.select_game_difficulty_recs.length - 1
        play_back_sound args
        args.state.game_difficulty_selection = 0
        args.state.current_scene = 0
      else
        play_select_sound args
        args.state.void_mode = args.state.game_difficulty_selection
        args.state.game_difficulty_selection = 0
        clear_data args
        args.state.current_scene = 4
      end
      args.state.pause_menu_selection = 0
      
      if args.state.played_game_previously == 1
        args.state.menu_selection = 0
      else
        args.state.menu_selection = 1
      end
    end
    
    if args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.b
      play_back_sound args
      args.state.pause_menu_selection = 0
      
      if args.state.played_game_previously == 1
        args.state.menu_selection = 0
      else
        args.state.menu_selection = 1
      end
      
      args.state.game_difficulty_selection = 0
      args.state.current_scene = 0
    end
  elsif args.state.current_scene == 5
    if (args.inputs.keyboard.key_down.left || args.inputs.keyboard.key_down.w || args.inputs.controller_one.key_down.left) || (args.inputs.keyboard.key_down.up || args.inputs.controller_one.key_down.up)
      play_select_sound args
      
      if args.state.pause_menu_selection == 0
        args.state.pause_menu_selection = args.state.pause_menu_recs.length - 1
      else
        args.state.pause_menu_selection -= 1
      end
    end
    if (args.inputs.keyboard.key_down.right || args.inputs.keyboard.key_down.s || args.inputs.controller_one.key_down.right) || (args.inputs.keyboard.key_down.down || args.inputs.controller_one.key_down.down)
      play_select_sound args
      
      if args.state.pause_menu_selection == args.state.pause_menu_recs.length - 1
        args.state.pause_menu_selection = 0
      else
        args.state.pause_menu_selection += 1
      end
    end
    if args.inputs.keyboard.key_down.enter || args.inputs.controller_one.key_down.a
      play_select_sound args
      
      if args.state.pause_menu_selection == 0
        args.state.paused_game = 0
        args.state.access_from_pause_menu = 0
        args.state.current_scene = 4
      elsif args.state.pause_menu_selection == 1
        args.state.access_from_pause_menu = 0
        args.state.current_scene = 0
      elsif args.state.pause_menu_selection == 2
        args.state.access_from_pause_menu = 1
        args.state.current_scene = 2
      elsif args.state.pause_menu_selection == 3
        args.state.access_from_pause_menu = 1
        args.state.current_scene = 1
      elsif args.state.pause_menu_selection == 4
        if $gtk.platform != "Emscripten"
          $gtk.exit
        end
      end
    end
    if args.inputs.keyboard.key_down.escape || args.inputs.controller_one.key_down.b
      play_back_sound args
      
      args.state.paused_game = 0
      args.state.access_from_pause_menu = 0
      args.state.current_scene = 4
    end
  end
end

def distsq_from_center(pt)
  dx = pt.x - 1280 / 2
  dy = pt.y - 720 / 2
  return dx * dx + dy * dy
end

def get_nearest_enemy(arr)
  return arr.min { |a, b| distsq_from_center(a) <=> distsq_from_center(b) }
end

def draw_demo args
  zone = args.layout.rect({ col: 4.9, row: 1.5, w: 14, h: 10 })
  
  args.outputs.primitives << {
    x: 496,
    y: 512.from_top,
    w: 256,
    h: 256,
    path: "sprites/pass_player.png",
  }.sprite!
  
  # Check for collision with this rect and shoot
  if args.state.demo_enemies.length > 0
    nearest_enemy = get_nearest_enemy(args.state.demo_enemies)
  end
  
  if args.state.demo_gun_activated == 1
    if args.state.demo_bullets.length < 1
      play_shoot_sound args
  
      args.state.demo_bullets << ({
        x: args.state.demo_player_center_x + 32,
        y: args.state.demo_player_center_y + 32,
        angle: (args.state.demo_angle + args.state.demo_angle_offset) * 3.14 / 180,
      })
    end
    
    if args.state.demo_offside_bullets.length < 1
      play_shoot_sound args
  
      args.state.demo_offside_bullets << ({
        x: args.state.demo_player_center_x + 32,
        y: args.state.demo_player_center_y + 32,
        angle: (args.state.demo_angle + args.state.demo_angle_offset) * 3.14 / 180,
      })
    end
  end
  
  args.state.demo_gun_activated = nearest_enemy.merge({ w: 64, h: 64 }).intersect_rect?(zone) ? 1 : 0
  
  #args.outputs.primitives << zone.merge({ r: 255, g: 0, b: 0, a: 255 }).border!
  
  args.state.demo_player_center_x = (args.state.demo_world_center_x + args.state.demo_player_dist * Math::cos(args.state.demo_angle * 3.14 / 180)) - 64
  args.state.demo_player_center_y = (args.state.demo_world_center_y.from_top + args.state.demo_player_dist * Math::sin(args.state.demo_angle * 3.14 / 180)) - 72
  
  if args.state.demo_enemies.length > 0 && args.state.demo_gun_activated == 1
    angle_to_enemy = (((args.state.demo_angle - (nearest_enemy.angular * 180 / Math::PI + 90)) % 360) - 180)
    proportional = -angle_to_enemy.clamp(-args.state.demo_player_rotation_dist, args.state.demo_player_rotation_dist)
    args.state.demo_angle += proportional if proportional.abs > 2
  end
  
  args.state.demo_enemies.length.times.map do |i|
    args.state.demo_enemies[i].x -= args.state.demo_enemies[i].vx
    args.state.demo_enemies[i].y -= args.state.demo_enemies[i].vy
    
    args.outputs.primitives << args.state.demo_enemies[i].merge({
      w: 64,
      h: 64,
    }).sprite!
  end
  
  args.state.demo_bullets.length.times.map do |i|
    args.state.demo_bullets[i].x += args.state.demo_bullet_speed * Math::cos(args.state.demo_bullets[i].angle)
    args.state.demo_bullets[i].y += args.state.demo_bullet_speed * Math::sin(args.state.demo_bullets[i].angle)
    
    args.outputs.primitives << args.state.demo_bullets[i].merge({
      w: 32,
      h: 32,
      path: "sprites/laserBlue08.png"
    }).sprite!
  end
  
  args.state.demo_offside_bullets.length.times.map do |i|
    args.state.demo_offside_bullets[i].x -= args.state.demo_bullet_speed * Math::cos(args.state.demo_offside_bullets[i].angle)
    args.state.demo_offside_bullets[i].y -= args.state.demo_bullet_speed * Math::sin(args.state.demo_offside_bullets[i].angle)
    
    args.outputs.primitives << args.state.demo_offside_bullets[i].merge({
      w: 32,
      h: 32,
      path: "sprites/laserBlue08.png"
    }).sprite!
  end
  
  args.state.demo_bullets.delete_if do |bullet|
    bullet.x < 0 || bullet.x > 1280 || bullet.y < 0 || bullet.y > 720
  end
  
  args.outputs.primitives << {
    x: args.state.demo_player_center_x,
    y: args.state.demo_player_center_y,
    w: 96,
    h: 96,
    path: "sprites/playerShip3_blue.png",
    angle: args.state.demo_angle
  }.sprite!
  
  args.state.demo_offside_bullets.delete_if do |offside_bullet|
    offside_bullet.x < 0 || offside_bullet.x > 1280 || offside_bullet.y < 0 || offside_bullet.y > 720
  end
  
  if args.state.demo_created_enemies + 1 <= args.state.demo_enemy_count_per_wave
    angle = rand(Math::PI * 40)
    dist = rand_between(args.state.demo_enemies_min_dist, args.state.demo_enemies_max_dist)
    xpos = dist * Math::cos(angle) + (1280 / 2) - 64
    ypos = dist * Math::sin(angle) + (720 - 64) / 2
    
    evx = 4 * Math::cos(angle)
    evy = 4 * Math::sin(angle)
    
    args.state.demo_enemies << {
      x: xpos,
      y: ypos,
      angular: angle,
      angdist: dist,
      vx: evx,
      vy: evy,
      path: rand_img()
    }
    
    args.state.demo_created_enemies += 1
  end
  
  if args.state.demo_enemies_killed == args.state.demo_enemy_count_per_wave
    args.state.demo_enemies = []
    args.state.demo_enemies_killed = 0
    args.state.demo_created_enemies = 0
  end
  
  # Enemies collision with player
  args.state.demo_enemies.length.times.map do |i|
    if args.state.demo_enemies[i]
      px = args.state.demo_enemies[i].x - args.state.demo_player_center_x
      py = args.state.demo_enemies[i].y - args.state.demo_player_center_y
    
      if (Math::sqrt((px * px) + (py * py)) <= 64)
        play_combo_lose_sound args
        args.state.demo_enemies_killed += 1
        args.state.demo_enemies.delete_at(i)
      end
    end
  end
  
  # Bullets collision with enemies
  if ((args.state.demo_bullets.length > 0) && (args.state.demo_enemies.length > 0))
    args.state.demo_bullets.length.times.map do |i|
      args.state.demo_enemies.length.times.map do |j|
        if args.state.demo_bullets[i] && args.state.demo_enemies[j]
          px = args.state.demo_bullets[i].x - args.state.demo_enemies[j].x
          py = args.state.demo_bullets[i].y - args.state.demo_enemies[j].y
          
          if (Math::sqrt((px * px) + (py * py)) <= 64)
            play_destroy_sound args
            args.state.demo_enemies_killed += 1
            args.state.demo_enemies.delete_at(j)
            args.state.demo_bullets.delete_at(i)
          end
        end
      end
    end
  end
  
  if ((args.state.demo_offside_bullets.length > 0) && (args.state.demo_enemies.length > 0))
    args.state.demo_offside_bullets.length.times.map do |i|
      args.state.demo_enemies.length.times.map do |j|
        if args.state.demo_offside_bullets[i] && args.state.demo_enemies[j]
          px = args.state.demo_offside_bullets[i].x - args.state.demo_enemies[j].x
          py = args.state.demo_offside_bullets[i].y - args.state.demo_enemies[j].y
          
          if (Math::sqrt((px * px) + (py * py)) <= 64)
            play_destroy_sound args
            args.state.demo_enemies_killed += 1
            args.state.demo_enemies.delete_at(j)
            args.state.demo_offside_bullets.delete_at(i)
          end
        end
      end
    end
  end
end

def mobile_selection_input args
  if args.state.current_scene == 0
    if touch_press(args, 0)
      args.state.main_menu_recs.length.times.map do |i|
        if touch_rec(args, 0).intersect_rect?(args.state.main_menu_recs[i])
          if (i == 0)
            if args.state.played_game_previously == 1
              play_select_sound args
              args.state.paused_game = 0
              args.state.enemies_killed = 0
              args.state.created_enemies = 0
              args.state.current_scene = 4
            end
          elsif (i == 1)
            play_back_sound args
            args.state.game_difficulty_selection = 0
        
            if (args.state.played_game_previously == 0)
              args.state.void_mode = 0
            end
        
            args.state.current_scene = 3
          elsif (i == 2)
            play_select_sound args
            args.state.current_scene = 2
          elsif (i == 3)
            play_select_sound args
            args.state.current_scene = 1
          elsif (i == 4)
            play_select_sound args
            
            if $gtk.platform != "Emscripten"
              $gtk.exit
            end
          end
        end
      end
    end
  elsif args.state.current_scene == 1
    if touch_press(args, 0)
      t = args.inputs.finger_one
      if touch_rec(args, 0).intersect_rect?(args.layout.rect({ col: 9.4, row: 7.75, w: 5.15, h: 4.3 }))
        play_select_sound args
        $gtk.openurl "https://dragonruby.org/toolkit/game"
      else
        play_back_sound args
        if args.state.access_from_pause_menu == 1
          args.state.current_scene = 5
        else
          args.state.current_scene = 0
        end
      end
    end
  elsif args.state.current_scene == 2
    if touch_press(args, 0)
      play_back_sound args
      
      if args.state.access_from_pause_menu == 1
        args.state.current_scene = 5
      else
        args.state.access_from_pause_menu = 0
        args.state.current_scene = 0
      end
    end
  elsif args.state.current_scene == 3
    if touch_press(args, 0)
      args.state.select_game_difficulty_recs.length.times.map do |i|
        if touch_rec(args, 0).intersect_rect?(args.state.select_game_difficulty_recs[i])
          if (i == 0) || (i == 1)
            play_select_sound args
            args.state.pause_menu_selection = 0
      
            if args.state.played_game_previously == 1
              args.state.menu_selection = 0
            else
              args.state.menu_selection = 1
            end
      
            args.state.game_difficulty_selection = 0
            args.state.void_mode = i
            clear_data args
            args.state.current_scene = 4
          elsif (i == 2)
            play_back_sound args
            args.state.pause_menu_selection = 0
      
            if args.state.played_game_previously == 1
              args.state.menu_selection = 0
            else
              args.state.menu_selection = 1
            end
      
            args.state.game_difficulty_selection = 0
          
            if (args.state.played_game_previously == 0)
              args.state.void_mode = 0
            end
          
            args.state.current_scene = 0
          end
        end
      end
    end
  elsif args.state.current_scene == 5
    if touch_press(args, 0)
      args.state.pause_menu_recs.length.times.map do |i|
        if touch_rec(args, 0).intersect_rect?(args.state.pause_menu_recs[i])
          if (i == 0)
            args.state.paused_game = 0
            args.state.access_from_pause_menu = 0
            args.state.current_scene = 4
          elsif (i == 1)
            args.state.access_from_pause_menu = 0
            args.state.current_scene = 0
          elsif (i == 2)
            args.state.access_from_pause_menu = 1
            args.state.current_scene = 2
          elsif (i == 3)
            args.state.access_from_pause_menu = 1
            args.state.current_scene = 1
          elsif (i == 4)
            if $gtk.platform != "Emscripten"
              $gtk.exit
            end
          end
        end
      end
    end
  end
end

def main_menu args
  draw_background args
  draw_demo args

  args.outputs.primitives << {
    x: 280,
    y: 32.from_top,
    text: "BLACKVOID",
    font: "fonts/kenvector_future.ttf",
    size_enum: 48,
    r: 200,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  if args.state.played_game_previously == 1
    args.outputs.primitives << {
      x: 32,
      y: 192,
      text: "CONTINUE",
      font: "fonts/kenvector_future.ttf",
      size_enum: 10,
      r: 255,
      g: 255,
      b: 255,
      a: 255,
    }.label!
  end
  
  args.outputs.primitives << {
    x: 32,
    y: 128,
    text: "START NEW GAME",
    font: "fonts/kenvector_future.ttf",
    size_enum: 10,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 920,
    y: 128,
    text: "HOW TO PLAY?",
    font: "fonts/kenvector_future.ttf",
    size_enum: 10,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 920,
    y: 64,
    text: "CREDITS",
    font: "fonts/kenvector_future.ttf",
    size_enum: 10,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 64,
    text: "BYE BYE!",
    font: "fonts/kenvector_future.ttf",
    size_enum: 10,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 350,
    x2: 350,
    y2: 350,
    r: 255,
    g: 0,
    b: 255,
    a: 255,
  }.line!
  
  args.outputs.primitives << {
    x: 32,
    y: 385,
    text: "HIGHEST STATS",
    font: "fonts/kenvector_future.ttf",
    size_enum: 6,
    r: 255,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 340,
    text: "SCORE: #{args.state.stats_score}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 312,
    text: "COMBO: #{args.state.stats_combo}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 286,
    text: "WAVE: #{args.state.stats_wave}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 32,
    y: 258,
    text: "DESTROYED ASTEROIDS: #{args.state.stats_total_killed_enemies}",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  if !is_mobile
    draw_selection_rect args
    selection_rect_input args
  elsif is_mobile
    mobile_selection_input args
  end
end

def credits_menu args
  draw_background args
  
  args.outputs.primitives << {
    x: 280,
    y: 32.from_top,
    text: "BLACKVOID",
    font: "fonts/kenvector_future.ttf",
    size_enum: 48,
    r: 200,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 440,
    y: 202.from_top,
    text: "CREATED BY",
    font: "fonts/kenvector_future.ttf",
    size_enum: 18,
    r: 30,
    g: 140,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 460,
    y: 282.from_top,
    text: "RABIA ALHAFFAR",
    font: "fonts/kenvector_future.ttf",
    size_enum: 8,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 440,
    y: 382.from_top,
    text: "POWERED BY",
    font: "fonts/kenvector_future.ttf",
    size_enum: 18,
    r: 30,
    g: 140,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 510,
    y: 42,
    w: 256,
    h: 256,
    path: "sprites/dragonruby.png"
  }.sprite!
  
  args.outputs.primitives << {
    x: 8,
    y: 32,
    text: is_mobile ? "TAP SCREEN TO BACK" : "PRESS ENTER OR ESCAPE KEY TO BACK",
    font: "fonts/kenvector_future.ttf",
    size_enum: 2,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  if !is_mobile
    selection_rect_input args
  else
    mobile_selection_input args
  end
end

def pause_menu args
  draw_background args
  
  texts = [ "CONTINUE", "MAIN MENU", "HOW TO PLAY?", "CREDITS", "BYE BYE!" ]
  
  args.outputs.primitives << {
    x: 240,
    y: 32.from_top,
    text: "GAME PAUSED!",
    font: "fonts/kenvector_future.ttf",
    size_enum: 36,
    r: 200,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  if !is_mobile
    draw_selection_rect args
  end
  
  texts.length.times.map do |i|
    args.outputs.primitives << {
      x: 32,
      y: (360 + i * 75).from_top,
      text: texts[i],
      font: "fonts/kenvector_future.ttf",
      size_enum: 12,
      r: 255,
      g: 255,
      b: 255,
      a: 255,
    }.label!
  end
  
  if !is_mobile
    selection_rect_input args
  else
    mobile_selection_input args
  end
end

def select_game_difficulty args
  draw_background args
  
  args.outputs.primitives << {
    x: 210,
    y: 32.from_top,
    text: "SELECT DIFFICULTY",
    font: "fonts/kenvector_future.ttf",
    size_enum: 28,
    r: 200,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << args.layout.rect({
    col: 4.5,
    row: 2.5,
    w: 15,
    h: 4.2
  }).merge({
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }).border!
  
  args.outputs.primitives << {
    x: 420,
    y: 202.from_top,
    text: "NORMAL MODE",
    font: "fonts/kenvector_future.ttf",
    size_enum: 16,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 325,
    y: 342.from_top,
    text: "THE PREFERRED MODE BY COOL GUYS!",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << args.layout.rect({
    col: 4.5,
    row: 7.5,
    w: 15,
    h: 4.2
  }).merge({
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }).border!
  
  args.outputs.primitives << {
    x: 480,
    y: 462.from_top,
    text: "VOID MODE",
    font: "fonts/kenvector_future.ttf",
    size_enum: 16,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 285,
    y: 602.from_top,
    text: "THE #{"DARK SOULS".quote} MODE, ONE HIT AND BYE!",
    font: "fonts/kenvector_future.ttf",
    size_enum: 4,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 8,
    y: 36,
    text: "BACK",
    font: "fonts/kenvector_future.ttf",
    size_enum: 6,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  if !is_mobile
    draw_selection_rect args
    selection_rect_input args
  else
    mobile_selection_input args
  end
end

def how_to_play_menu args
  draw_background args
  
  left_arr = [
    "sprites/Arrow_Left_Key_Dark.png",
    "sprites/A_Key_Dark.png",
    "sprites/XboxSeriesX_Dpad_Left.png",
  ]
  
  right_arr = [
    "sprites/Arrow_Right_Key_Dark.png",
    "sprites/D_Key_Dark.png",
    "sprites/XboxSeriesX_Dpad_Right.png",
  ]
  
  shoot_forward_arr = [
    "sprites/Arrow_Up_Key_Dark.png",
    "sprites/XboxSeriesX_A.png",
    "sprites/XboxSeriesX_Dpad_Up.png"
  ]
  
  shoot_backward_arr = [
    "sprites/Arrow_Down_Key_Dark.png",
    "sprites/XboxSeriesX_B.png",
    "sprites/XboxSeriesX_Dpad_Down.png"
  ]
  
  args.outputs.primitives << {
    x: 220,
    y: 32.from_top,
    text: "HOW TO PLAY?",
    font: "fonts/kenvector_future.ttf",
    size_enum: 42,
    r: 200,
    g: 0,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 100,
    y: 222.from_top,
    text: "TURN LEFT",
    font: "fonts/kenvector_future.ttf",
    size_enum: 14,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  left_arr.length.times.map do |i|
    args.outputs.primitives << {
      x: 900 + (i * 100),
      y: 292.from_top,
      w: 96,
      h: 96,
      path: left_arr[i]
    }.sprite!
  end
  
  args.outputs.primitives << {
    x: 100,
    y: 322.from_top,
    text: "TURN RIGHT",
    font: "fonts/kenvector_future.ttf",
    size_enum: 14,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  right_arr.length.times.map do |i|
    args.outputs.primitives << {
      x: 900 + (i * 100),
      y: 392.from_top,
      w: 96,
      h: 96,
      path: right_arr[i]
    }.sprite!
  end
  
  args.outputs.primitives << {
    x: 100,
    y: 422.from_top,
    text: "SHOOT FORWARD",
    font: "fonts/kenvector_future.ttf",
    size_enum: 14,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  shoot_forward_arr.length.times.map do |i|
    args.outputs.primitives << {
      x: 900 + (i * 100),
      y: 492.from_top,
      w: 96,
      h: 96,
      path: shoot_forward_arr[i]
    }.sprite!
  end
  
  args.outputs.primitives << {
    x: 100,
    y: 522.from_top,
    text: "SHOOT BACKWARD",
    font: "fonts/kenvector_future.ttf",
    size_enum: 14,
    r: 34,
    g: 155,
    b: 255,
    a: 255,
  }.label!
  
  shoot_backward_arr.length.times.map do |i|
    args.outputs.primitives << {
      x: 900 + (i * 100),
      y: 592.from_top,
      w: 96,
      h: 96,
      path: shoot_backward_arr[i]
    }.sprite!
  end
  
  args.outputs.primitives << {
    x: 905,
    y: 165.from_top,
    text: "ONE OF THESE BUTTONS",
    font: "fonts/kenvector_future.ttf",
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  args.outputs.primitives << {
    x: 8,
    y: 32,
    text: is_mobile ? "TAP SCREEN TO BACK" : "PRESS ENTER OR ESCAPE KEY TO BACK",
    font: "fonts/kenvector_future.ttf",
    size_enum: 2,
    r: 255,
    g: 255,
    b: 255,
    a: 255,
  }.label!
  
  if !is_mobile
    selection_rect_input args
  else
    mobile_selection_input args
  end
end

def save_data args
  $gtk.serialize_state("blackvoid_data.txt", args.state)
end

def load_data args
  if args.state.game_loaded == 0
    data = $gtk.deserialize_state("blackvoid_data.txt")
  
    if data
      $gtk.args.state = data
      args.state.current_scene = 0
      args.state.loaded_saved_game = 1
      args.state.menu_selection = 1
      args.state.angle = 0
      args.state.angle_offset = 90
      args.state.paused_game = 0
      args.state.bullets = []
      args.state.offside_bullets = []
      
      if args.state.played_game_previously == 1 && args.state.wave > 1
        args.state.played_game_previously = 1
        args.state.menu_selection = 0
      end
    end
  
    args.state.game_loaded = 1
  end
end

def clear_data args
  args.state.angle                      = 0
  args.state.created_enemies            = 0
  args.state.combo                      = 0
  args.state.player_alive               = 1
  args.state.score                      = 0
  args.state.enemy_count_per_wave       = 10
  args.state.total_killed_enemies       = 0
  args.state.enemies_killed             = 0
  args.state.wave                       = 1
  args.state.access_from_pause_menu     = 0
  args.state.paused_game                = 0
  args.state.menu_selection             = 1
  args.state.game_difficulty_selection  = 0
  args.state.played_game_previously     = 0
  args.state.pause_menu_selection       = 0
  args.state.bullets                    = []
  args.state.offside_bullets            = []
  args.state.enemies                    = []
  args.state.demo_bullet_speed          = 15
  args.state.demo_player_dist           = 0
  args.state.demo_angle                 = 0
  args.state.demo_created_enemies       = 0
  args.state.demo_bullets               = []
  args.state.demo_offside_bullets       = []
  args.state.demo_enemies               = []
  args.state.demo_enemies_killed        = 0
  args.state.demo_gun_activated         = 0
  args.state.demo_player_center_x       = 0
  args.state.demo_player_center_y       = 0
  args.state.game_over_label_alpha      = 0
  save_data args
end
