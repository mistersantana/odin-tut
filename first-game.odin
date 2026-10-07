package firstgame

import rl "vendor:raylib"

Animation_name :: enum {
	Idle,
	Run,
}

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
	name:          Animation_name,
}

update_animation :: proc(a: ^Animation) {
	a.frame_timer += rl.GetFrameTime()

	if a.frame_timer > a.frame_length {
		a.current_frame += 1
		a.frame_timer = 0

		if a.current_frame == a.num_frames {
			a.current_frame = 0
		}
	}
}

draw_animation :: proc(a: Animation, pos: rl.Vector2, flip: bool) {
	width := f32(a.texture.width)
	height := f32(a.texture.height)


	source := rl.Rectangle {
		x      = f32(a.current_frame) * width / f32(a.num_frames),
		y      = 0,
		width  = width / f32(a.num_frames),
		height = height,
	}

	if flip {
		source.width = -source.width
	}

	dest := rl.Rectangle {
		x      = pos.x,
		y      = pos.y,
		width  = width / f32(a.num_frames),
		height = height,
	}

	rl.DrawTexturePro(a.texture, source, dest, {dest.width / 2, dest.height}, 0, rl.WHITE)
}

PIXEL_WINDOW_HEIGHT :: 180

main :: proc() {
	rl.InitWindow(1280, 720, "!")
	rl.SetWindowPosition(30, 60)
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.SetTargetFPS(120)
	player_pos: rl.Vector2
	player_vel: rl.Vector2
	player_grounded: bool
	player_flip: bool

	player_run := Animation {
		texture      = rl.LoadTexture("cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
		name         = .Run,
	}

	player_idle := Animation {
		texture      = rl.LoadTexture("cat_idle.png"),
		num_frames   = 2,
		frame_length = 0.5,
		name         = .Idle,
	}

	current_anim := player_idle

	platforms := []rl.Rectangle{{-20, 20, 96, 16}, {90, -10, 96, 16}, {90, -50, 96, 16}}

	platform_texture := rl.LoadTexture("platform.png")

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		if rl.IsKeyDown(.LEFT) {
			player_vel.x = -100
			player_flip = true

			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else if rl.IsKeyDown(.RIGHT) {
			player_vel.x = 100
			player_flip = false

			if current_anim.name != .Run {
				current_anim = player_run
			}
		} else {
			player_vel.x = 0

			if current_anim.name != .Idle {
				current_anim = player_idle
			}
		}

		player_vel.y += 1000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -300
		}

		player_pos += player_vel * rl.GetFrameTime()

		player_feet_collider := rl.Rectangle{player_pos.x - 4, player_pos.y - 4, 8, 4}

		player_grounded = false

		for platform in platforms {
			if rl.CheckCollisionRecs(player_feet_collider, platform) && player_vel.y > 0 {
				player_vel.y = 0
				player_pos.y = platform.y
				player_grounded = true
			}
		}

		update_animation(&current_anim)

		screen_height := f32(rl.GetScreenHeight())

		camera := rl.Camera2D {
			zoom   = screen_height / PIXEL_WINDOW_HEIGHT,
			offset = {f32(rl.GetScreenWidth() / 2), screen_height / 2},
			target = player_pos,
		}

		rl.BeginMode2D(camera)
		draw_animation(current_anim, player_pos, player_flip)
		for platform in platforms {
			rl.DrawTextureV(platform_texture, {platform.x, platform.y}, rl.WHITE)
		}
		rl.EndMode2D()
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
