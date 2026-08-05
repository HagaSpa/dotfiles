#include QMK_KEYBOARD_H


#ifdef RGBLIGHT_ENABLE
//Following line allows macro to read current RGB settings
extern rgblight_config_t rgblight_config;
#endif

extern uint8_t is_master;

enum layer_number {
  _QWERTY = 0,
  _FN,
  _ADJUST,
};

enum custom_keycodes {
  RGB_RST = SAFE_RANGE
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  [_QWERTY] = LAYOUT(
  //,-----------------------------------------------------|   |--------------------------------------------------------------------------------.
       KC_ESC,    KC_1,    KC_2,    KC_3,    KC_4,    KC_5,        KC_6,    KC_7,    KC_8,    KC_9,    KC_0, KC_MINS,  KC_EQL, KC_BSLS,  KC_GRV,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------+--------|
       KC_TAB,    KC_Q,    KC_W,    KC_E,    KC_R,    KC_T,        KC_Y,    KC_U,    KC_I,    KC_O,    KC_P, KC_LBRC, KC_RBRC, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------|
      KC_LCTL,    KC_A, LALT_T(KC_S), LCTL_T(KC_D), LSFT_T(KC_F), KC_G,  KC_H,    KC_J,    KC_K,    KC_L, RCAG_T(KC_SCLN), KC_QUOT, KC_ENT,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
      KC_LSFT,    KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,        KC_N,    KC_M, KC_COMM,  KC_DOT, KC_SLSH, KC_RSFT, MO(_FN),
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
               MO(_FN), KC_LALT, LGUI_T(KC_LNG2), KC_SPC,    KC_SPC, RGUI_T(KC_LNG1), KC_BSPC,  KC_ENT
          //`---------------------------------------------|   |--------------------------------------------'
  ),

  [_FN] = LAYOUT(
  //,-----------------------------------------------------|   |--------------------------------------------------------------------------------.
  TG(_ADJUST),   KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,       KC_F6,   KC_F7,   KC_F8,   KC_F9,  KC_F10,  KC_F11,  KC_F12,  KC_INS,  KC_DEL,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------+--------|
      _______, _______, _______, _______, _______, _______,     _______, _______, KC_PSCR, KC_SCRL,KC_PAUSE,   KC_UP, _______, KC_BSPC,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------|
      _______, _______, _______, _______, _______, _______,     _______, _______, KC_HOME, KC_PGUP, KC_LEFT,KC_RIGHT, _______,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
      _______, _______, _______, _______, _______, _______,     _______, _______,  KC_END, KC_PGDN, KC_DOWN, _______, _______,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
               _______, _______, _______, _______,              _______, _______,          KC_STOP, _______
          //`---------------------------------------------|   |--------------------------------------------'
  ),

  [_ADJUST] = LAYOUT(
  //,-----------------------------------------------------|   |--------------------------------------------------------------------------------.
  TG(_ADJUST), XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,     XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, QK_BOOT,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,     RGB_RST, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,     UG_TOGG, UG_NEXT, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
      XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,     UG_VALD, UG_VALU, UG_HUED, UG_HUEU, UG_SATD, UG_SATU, XXXXXXX,
  //|--------+--------+--------+--------+--------+--------|   |--------+--------+--------+--------+--------+--------+--------|
               XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX,              XXXXXXX, XXXXXXX,          KC_STOP, XXXXXXX
          //`---------------------------------------------|   |--------------------------------------------'
  )
};


// '*' exempts a key from Chordal Hold's opposite-hands rule. The Cmd mod-taps
// need same-hand chords (Cmd+A, Cmd+C) and ; sends ⌘⌥⌃ to Raycast, whose
// hotkey may sit on the right hand. Marking them 'L'/'R' would settle those as
// taps and emit 英数 / かな / ; instead of the modifier.
const char chordal_hold_layout[MATRIX_ROWS][MATRIX_COLS] PROGMEM = LAYOUT(
  'L','L','L','L','L','L',    'R','R','R','R','R','R','R','R','R',
  'L','L','L','L','L','L',    'R','R','R','R','R','R','R','R',
  'L','L','L','L','L','L',    'R','R','R','R','*','R','R',
  'L','L','L','L','L','L',    'R','R','R','R','R','R','R',
      'L','L','*','L',        'R','*','R','R'
);

// Cmd has to engage the moment another key is pressed; waiting out TAPPING_TERM
// would make Cmd+C feel sluggish. The home row mods stay on PERMISSIVE_HOLD.
bool get_hold_on_other_key_press(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case LGUI_T(KC_LNG2):
    case RGUI_T(KC_LNG1):
      return true;
    default:
      return false;
  }
}

//A description for expressing the layer position in LED mode.
layer_state_t layer_state_set_user(layer_state_t state) {
#ifdef RGBLIGHT_ENABLE
    switch (get_highest_layer(state)) {
    case _FN:
      rgblight_sethsv_at(HSV_BLUE, 0);
      break;
    case _ADJUST:
      rgblight_sethsv_at(HSV_PURPLE, 0);
      break;
    default: //  for any other layers, or the default layer
      rgblight_sethsv_at( 0, 0, 0, 0);
      break;
    }
    rgblight_set_effect_range( 1, 11);
#endif
return state;
}

// Ctrl + hjkl / , / . → arrows and word jump, mirroring the Karabiner rule that
// covers the built-in keyboard. The Ctrl bit is stripped so the app sees a bare
// arrow; any other modifier held at the time (Shift, for selection) passes
// through. Returns true when the key was replaced.
static bool ctrl_nav(uint16_t keycode, keyrecord_t *record) {
  if (!(get_mods() & MOD_MASK_CTRL)) {
    return false;
  }
  if (!record->event.pressed) {
    return true;  // the press already sent a complete tap
  }

  uint16_t to_code;
  switch (keycode) {
    case KC_H:    to_code = KC_LEFT;        break;
    case KC_J:    to_code = KC_DOWN;        break;
    case KC_K:    to_code = KC_UP;          break;
    case KC_L:    to_code = KC_RIGHT;       break;
    case KC_COMM: to_code = LALT(KC_LEFT);  break;
    case KC_DOT:  to_code = LALT(KC_RIGHT); break;
    default:      return false;
  }

  const uint8_t saved = get_mods();
  del_mods(MOD_MASK_CTRL);
  send_keyboard_report();
  tap_code16(to_code);
  set_mods(saved);
  send_keyboard_report();
  return true;
}

// Ctrl+Space (tmux prefix) drops out of the IME on the way through: 英数 first,
// then the prefix itself. The Karabiner equivalent scopes this to terminals, but
// QMK cannot see the frontmost app so it applies everywhere. That is safe as long
// as nothing else is bound to Ctrl+Space — settings.sh disables macOS's own
// input-source switcher on it.
static bool ctrl_space_ime_bypass(keyrecord_t *record) {
  if (!(get_mods() & MOD_MASK_CTRL)) {
    return false;
  }
  if (!record->event.pressed) {
    return true;
  }

  const uint8_t saved = get_mods();
  del_mods(MOD_MASK_CTRL);
  send_keyboard_report();
  tap_code(KC_LNG2);
  set_mods(saved);
  send_keyboard_report();
  tap_code(KC_SPC);
  return true;
}

int RGB_current_mode;
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  bool result = false;
  switch (keycode) {
    #ifdef RGBLIGHT_ENABLE
      case QK_UNDERGLOW_MODE_NEXT:
          if (record->event.pressed) {
            rgblight_mode(RGB_current_mode);
            rgblight_step();
            RGB_current_mode = rgblight_config.mode;
          }
        break;
      case RGB_RST:
          if (record->event.pressed) {
            eeconfig_update_rgblight_default();
            rgblight_enable();
            RGB_current_mode = rgblight_config.mode;
          }
        break;
    #endif
    case KC_H:
    case KC_J:
    case KC_K:
    case KC_L:
    case KC_COMM:
    case KC_DOT:
      result = !ctrl_nav(keycode, record);
      break;
    case KC_SPC:
      result = !ctrl_space_ime_bypass(record);
      break;
    default:
      result = true;
      break;
  }

  return result;
}
