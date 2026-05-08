import {
  ifApp,
  map,
  rule,
  withMapper,
  writeToProfile,
} from 'karabiner.ts';
import { TERMINAL_BUNDLE_IDS } from './apps.ts';

const ifTerminal = ifApp({ bundle_identifiers: [...TERMINAL_BUNDLE_IDS] });

writeToProfile('Default profile', [
  rule('Terminal Ctrl tap-hold + tmux IME bypass', ifTerminal).manipulators([
    map({ key_code: 'left_control', modifiers: { optional: ['any'] } })
      .to({ key_code: 'left_control', lazy: true })
      .toIfAlone({ key_code: 'left_control', hold_down_milliseconds: 300 })
      .parameters({ 'basic.to_if_alone_timeout_milliseconds': 300 }),

    map({
      key_code: 'b',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    })
      .to({ key_code: 'japanese_eisuu' })
      .to({ key_code: 'b', modifiers: ['left_control'] }),
  ]),

  rule('Ctrl navigation (hjkl / word / page)').manipulators([
    map({
      key_code: 'comma',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    }).to({ key_code: 'left_arrow', modifiers: ['left_option'] }),

    map({
      key_code: 'period',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    }).to({ key_code: 'right_arrow', modifiers: ['left_option'] }),

    map({
      key_code: 'w',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    }).to({ key_code: 'page_up' }),

    map({
      key_code: 'v',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    }).to({ key_code: 'page_down' }),

    withMapper({
      h: 'left_arrow',
      j: 'down_arrow',
      k: 'up_arrow',
      l: 'right_arrow',
    } as const)((from, to) =>
      map({
        key_code: from,
        modifiers: { mandatory: ['left_control'], optional: ['any'] },
      }).to({ key_code: to }),
    ),
  ]),

  rule('Home Row Mods (Opt+Shift on ;)').manipulators([
    map({ key_code: 'semicolon', modifiers: { optional: ['any'] } })
      .to({
        key_code: 'right_option',
        modifiers: ['right_shift'],
        lazy: true,
      })
      .toIfAlone({ key_code: 'semicolon' })
      .parameters({
        'basic.to_if_alone_timeout_milliseconds': 200,
        'basic.to_if_held_down_threshold_milliseconds': 200,
      }),
  ]),

  rule('Tap CMD to toggle Kana/Eisuu').manipulators([
    withMapper({
      left_command: 'japanese_eisuu',
      right_command: 'japanese_kana',
    } as const)((cmd, lang) =>
      map({ key_code: cmd, modifiers: { optional: ['any'] } })
        .to({ key_code: cmd, lazy: true })
        .toIfHeldDown({ key_code: cmd })
        .toIfAlone({ key_code: lang })
        .parameters({ 'basic.to_if_held_down_threshold_milliseconds': 100 }),
    ),
  ]),
]);
