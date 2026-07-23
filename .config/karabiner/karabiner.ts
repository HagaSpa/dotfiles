import {
  ifApp,
  map,
  mapSimultaneous,
  rule,
  withMapper,
  writeToProfile,
} from 'karabiner.ts';
import { TERMINAL_BUNDLE_IDS } from './apps.ts';

const ifTerminal = ifApp({ bundle_identifiers: [...TERMINAL_BUNDLE_IDS] });

// vim hjkl key repeat conflicts fundamentally with hold-for-modifier. Only the
// right-index J needs disabling in vim apps (vim/Vimium hold j to scroll); F
// (Shift) and S (Opt) on the left hand stay active everywhere — F via bilateral
// chord still gives Shift+right-letter (the original wrist pain point) inside
// vim apps too.
const VIM_APP_IDS = [
  ...TERMINAL_BUNDLE_IDS,
  '^com\\.google\\.Chrome$',
  '^dev\\.zed\\.Zed$',
  '^com\\.neovide\\.neovide$',
] as const;
const unlessVimApp = ifApp({
  bundle_identifiers: [...VIM_APP_IDS],
}).unless();

const LEFT_HAND_LETTERS = [
  'q', 'w', 'e', 'r', 't',
  'a', 's', 'd', 'f', 'g',
  'z', 'x', 'c', 'v', 'b',
] as const;
const RIGHT_HAND_LETTERS = [
  'y', 'u', 'i', 'o', 'p',
  'h', 'j', 'k', 'l', 'semicolon',
  'n', 'm', 'comma', 'period', 'slash',
] as const;
// Cross-hand rolls (e.g. "si", "ju") also need simultaneous safety because Karabiner
// has no bilateral-combinations; without this, S+i within the basic-HRM window
// commits S as Option and misfires Option+i.
const ALL_LETTERS = [...LEFT_HAND_LETTERS, ...RIGHT_HAND_LETTERS] as const;

const HRM_PARAMS = {
  'basic.to_if_alone_timeout_milliseconds': 200,
  'basic.to_if_held_down_threshold_milliseconds': 200,
} as const;
const HRM_SIMULTANEOUS_MS = 180;

// Letter rolls (e.g. "sa", "si") within HRM_SIMULTANEOUS_MS pass through as literals
// instead of triggering the modifier — works around Karabiner's lack of QMK-style
// permissive-hold / bilateral-combinations. Intentional modifier+letter requires
// holding the HRM key longer than HRM_SIMULTANEOUS_MS before tapping the letter.
function homeRowMod(opts: {
  key: string;
  toModifier: { key_code: string; modifiers?: string[] };
  safetyKeys: readonly string[];
}) {
  const others = opts.safetyKeys.filter((k) => k !== opts.key);
  return [
    ...others.flatMap((other) => [
      mapSimultaneous(
        [opts.key as never, other as never],
        { key_down_order: 'strict' },
        HRM_SIMULTANEOUS_MS,
      ).to([{ key_code: opts.key as never }, { key_code: other as never }]),
      mapSimultaneous(
        [other as never, opts.key as never],
        { key_down_order: 'strict' },
        HRM_SIMULTANEOUS_MS,
      ).to([{ key_code: other as never }, { key_code: opts.key as never }]),
    ]),
    map({ key_code: opts.key as never, modifiers: { optional: ['any'] } })
      .to({ ...opts.toModifier, lazy: true } as never)
      .toIfAlone({ key_code: opts.key as never })
      .parameters(HRM_PARAMS),
  ];
}

writeToProfile('Default profile', [
  rule('Terminal Ctrl tap-hold + tmux IME bypass', ifTerminal).manipulators([
    map({ key_code: 'left_control', modifiers: { optional: ['any'] } })
      .to({ key_code: 'left_control', lazy: true })
      .toIfAlone({ key_code: 'left_control', hold_down_milliseconds: 300 })
      .parameters({ 'basic.to_if_alone_timeout_milliseconds': 300 }),

    map({
      key_code: 'spacebar',
      modifiers: { mandatory: ['left_control'], optional: ['any'] },
    })
      .to({ key_code: 'japanese_eisuu' })
      .to({ key_code: 'spacebar', modifiers: ['left_control'] }),
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

  // Shift を含めると macOS の中国語変換サービス (⌃⌥⇧⌘C / ⌃⌥⇧⌘V) と衝突するため
  // ⌘⌥⌃ に留める。Cmd を含むことが Secure Input 固着時のホットキー生存条件。
  rule('Home Row Mods (Cmd+Opt+Ctrl on ;)').manipulators([
    map({ key_code: 'semicolon', modifiers: { optional: ['any'] } })
      .to({
        key_code: 'right_command',
        modifiers: ['right_control', 'right_option'],
        lazy: true,
      })
      .toIfAlone({ key_code: 'semicolon' })
      .parameters({
        'basic.to_if_alone_timeout_milliseconds': 200,
        'basic.to_if_held_down_threshold_milliseconds': 200,
      }),
  ]),

  rule('Home Row Mods (Shift on F, Opt on S, Ctrl on D)').manipulators([
    ...homeRowMod({
      key: 'f',
      toModifier: { key_code: 'left_shift' },
      safetyKeys: ALL_LETTERS,
    }),
    ...homeRowMod({
      key: 's',
      toModifier: { key_code: 'left_option' },
      safetyKeys: ALL_LETTERS,
    }),
    ...homeRowMod({
      key: 'd',
      toModifier: { key_code: 'left_control' },
      safetyKeys: ALL_LETTERS,
    }),
  ]),

  rule('Home Row Mods (Shift on J)', unlessVimApp).manipulators([
    ...homeRowMod({
      key: 'j',
      toModifier: { key_code: 'right_shift' },
      safetyKeys: ALL_LETTERS,
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
