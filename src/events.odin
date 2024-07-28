package main

import skl_app "shared:sokol/app"

Key_State :: bit_set[enum {
	Down,
	Pressed,
}]

@(private)
key_states: #sparse[skl_app.Keycode]Key_State

event_handler :: proc(event: ^skl_app.Event) {
	#partial switch event.type {
	case .KEY_DOWN:
		key_states[event.key_code] += {.Down}

	case .KEY_UP:
		if .Down in key_states[event.key_code] {
			key_states[event.key_code] += {.Pressed}
		}
		key_states[event.key_code] -= {.Down}
	}
}

update_keys_states :: proc() {
	for &i in key_states {
		i -= {.Pressed}
	}
}

is_key_down :: proc(key: skl_app.Keycode) -> bool {
	return .Down in key_states[key]
}

is_key_pressed :: proc(key: skl_app.Keycode) -> bool {
	return .Pressed in key_states[key]
}

get_key_state :: proc(key: skl_app.Keycode) -> Key_State {
	return key_states[key]
}
