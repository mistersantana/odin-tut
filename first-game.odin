package firstgame

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(1280, 720, "!")
	player_pos := rl.Vector2{640, 320}
	player_vel: rl.Vector2
	player_grounded: bool
	player_run_texture := rl.LoadTexture("cat_run.png")
	player_run_num_frames := 4

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		if rl.IsKeyDown(.LEFT) {
			player_vel.x = -400
		} else if rl.IsKeyDown(.RIGHT) {
			player_vel.x = 400
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

		player_run_width := f32(player_run_texture.width)
		player_run_height := f32(player_run_texture.height)

		draw_player_source := rl.Rectangle {
			x      = 0,
			y      = 0,
			width  = player_run_width / f32(player_run_num_frames),
			height = player_run_height,
		}

		draw_player_dest := rl.Rectangle {
			x      = player_pos.x,
			y      = player_pos.y,
			width  = player_run_width * 4 / f32(player_run_num_frames),
			height = player_run_height * 4,
		}

		rl.DrawTexturePro(player_run_texture, draw_player_source, draw_player_dest, 0, 0, rl.WHITE)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
