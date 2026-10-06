package firstgame

import rl "vendor:raylib"

Animation :: struct {
	texture:       rl.Texture2D,
	num_frames:    int,
	frame_timer:   f32,
	current_frame: int,
	frame_length:  f32,
}

main :: proc() {
	rl.InitWindow(1280, 720, "!")
	rl.SetWindowPosition(30, 60)
	player_pos := rl.Vector2{640, 320}
	player_vel: rl.Vector2
	player_grounded: bool
	player_flip: bool

	player_run := Animation {
		texture      = rl.LoadTexture("cat_run.png"),
		num_frames   = 4,
		frame_length = 0.1,
	}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		if rl.IsKeyDown(.LEFT) {
			player_vel.x = -400
			player_flip = true
		} else if rl.IsKeyDown(.RIGHT) {
			player_vel.x = 400
			player_flip = false
		} else {
			player_vel.x = 0
		}

		player_vel.y += 2000 * rl.GetFrameTime()

		if player_grounded && rl.IsKeyPressed(.SPACE) {
			player_vel.y = -600
			player_grounded = false
		}

		player_pos += player_vel * rl.GetFrameTime()

		if player_pos.y > f32(rl.GetScreenHeight()) - 64 {
			player_pos.y = f32(rl.GetScreenHeight()) - 64
			player_grounded = true
		}

		player_run_width := f32(player_run.texture.width)
		player_run_height := f32(player_run.texture.height)

		player_run.frame_timer += rl.GetFrameTime()

		for player_run.frame_timer > player_run.frame_length {
			player_run.current_frame += 1
			player_run.frame_timer -= player_run.frame_length

			if player_run.current_frame == player_run.num_frames {
				player_run.current_frame = 0
			}
		}

		draw_player_source := rl.Rectangle {
			x      = f32(player_run.current_frame) * player_run_width / f32(player_run.num_frames),
			y      = 0,
			width  = player_run_width / f32(player_run.num_frames),
			height = player_run_height,
		}

		if player_flip {
			draw_player_source.width = -draw_player_source.width
		}

		draw_player_dest := rl.Rectangle {
			x      = player_pos.x,
			y      = player_pos.y,
			width  = player_run_width * 4 / f32(player_run.num_frames),
			height = player_run_height * 4,
		}

		rl.DrawTexturePro(player_run.texture, draw_player_source, draw_player_dest, 0, 0, rl.WHITE)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
