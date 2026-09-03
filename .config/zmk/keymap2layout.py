import json
import pathlib
import re
import sys

BUILTIN_BEHAVIORS = {"magic", "bt_0", "bt_1", "bt_2", "bt_3"}
BUILTIN_MACROS = {"rgb_ug_status_macro", "bt_select_0", "bt_select_1", "bt_select_2", "bt_select_3"}
NO_PARAM_BINDINGS = {"&magic"}
BINDING_ALIASES = {"&sys_reset": "&reset", "&spc_ime": "&kp SPACE"}
KEYCODE_ALIASES = {
    "TILDE": "LS(GRAVE)",
    "EXCL": "LS(N1)",
    "AT": "LS(N2)",
    "HASH": "LS(N3)",
    "DLLR": "LS(N4)",
    "PRCNT": "LS(N5)",
    "CARET": "LS(N6)",
    "AMPS": "LS(N7)",
    "ASTRK": "LS(N8)",
    "LPAR": "LS(N9)",
    "RPAR": "LS(N0)",
    "UNDER": "LS(MINUS)",
    "PLUS": "LS(EQUAL)",
    "LBRC": "LS(LBKT)",
    "RBRC": "LS(RBKT)",
    "PIPE": "LS(BSLH)",
    "COLON": "LS(SEMI)",
    "DQT": "LS(SQT)",
    "LESS_THAN": "LS(COMMA)",
    "GREATER_THAN": "LS(DOT)",
    "QMARK": "LS(FSLH)",
}
UNSUPPORTED_KEYCODES = {
    "LA(LEFT)": "LEFT",
    "LA(RIGHT)": "RIGHT",
    "LC(LA(LGUI))": "LGUI",
    "LC(SPACE)": "SPACE",
}
MACRO_DEFAULT_WAIT_MS = 100
MACRO_DEFAULT_TAP_MS = 30
UUID = "9a2f4c18-6d3b-4e7a-8c15-2b0d7e934f61"
PARENT_UUID = "e649e6e5-6870-41c6-8580-ed551ed37c5b"


def brace_block(text, open_idx):
    depth = 0
    for i in range(open_idx, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[open_idx : i + 1]
    raise ValueError("unbalanced braces")


def named_block(text, name):
    m = re.search(r"\b%s\s*\{" % re.escape(name), text)
    if not m:
        return ""
    return brace_block(text, text.index("{", m.start()))


def definitions(block, skip):
    for m in re.finditer(r"(\w+):\s*\1\s*\{", block):
        name = m.group(1)
        if name in skip:
            continue
        yield name, brace_block(block, block.index("{", m.start()))


def prop(body, name):
    m = re.search(r"%s\s*=\s*([^;]+);" % re.escape(name), body)
    return m.group(1).strip() if m else None


def int_prop(body, name):
    value = prop(body, name)
    return int(value.strip("<>")) if value else None


def expand(text, defines):
    for key in sorted(defines, key=len, reverse=True):
        text = re.sub(r"\b%s\b" % key, defines[key], text)
    return text


def keycode(token):
    token = KEYCODE_ALIASES.get(token, token)
    token = UNSUPPORTED_KEYCODES.get(token, token)
    m = re.fullmatch(r"([A-Z_]+)\((.+)\)", token)
    if m:
        return {"value": m.group(1), "params": [keycode(m.group(2))]}
    return {"value": token}


def to_param(token, layer_numbers):
    if token in layer_numbers:
        return {"value": layer_numbers[token]}
    return keycode(token)


def to_binding(token, layer_numbers):
    token = BINDING_ALIASES.get(token.strip(), token)
    parts = token.split()
    code = parts[0]
    if code in NO_PARAM_BINDINGS:
        return {"value": code}
    out = {"value": code}
    params = [to_param(p, layer_numbers) for p in parts[1:]]
    if params:
        out["params"] = params
    return out


def split_bindings(text):
    return [t.strip() for t in re.split(r"(?=&)", text) if t.strip()]


def parse_hold_taps(block, key_groups):
    out = []
    for name, body in definitions(block, BUILTIN_BEHAVIORS):
        if "zmk,behavior-hold-tap" not in body:
            continue
        entry = {
            "name": "&" + name,
            "description": "",
            "bindings": re.findall(r"&\w+", prop(body, "bindings") or ""),
            "tappingTermMs": int_prop(body, "tapping-term-ms"),
            "flavor": (prop(body, "flavor") or '""').strip('"'),
        }
        for key, field in (
            ("quick-tap-ms", "quickTapMs"),
            ("require-prior-idle-ms", "requirePriorIdleMs"),
        ):
            value = int_prop(body, key)
            if value is not None:
                entry[field] = value
        positions = prop(body, "hold-trigger-key-positions")
        if positions:
            entry["holdTriggerKeyPositions"] = [
                int(x) for x in expand(positions.strip("<>"), key_groups).split()
            ]
        if re.search(r"hold-trigger-on-release\s*;", body):
            entry["holdTriggerOnRelease"] = True
        if re.search(r"retro-tap\s*;", body):
            entry["retroTap"] = True
        out.append(entry)
    return out


def describe_macro(body):
    inner = re.search(r"bindings\s*=\s*<(.*?)>\s*;", body, re.S)
    raw = " ".join(inner.group(1).split()) if inner else ""
    lost = [k for k in UNSUPPORTED_KEYCODES if k in raw]
    text = "Real binding: %s" % raw
    if lost:
        text += "\nShown with the modifier dropped (the editor rejects these key codes): %s" % ", ".join(lost)
    return text


def parse_macros(block, layer_numbers):
    out = []
    for name, body in definitions(block, BUILTIN_MACROS):
        inner = re.search(r"bindings\s*=\s*<(.*?)>\s*;", body, re.S)
        out.append(
            {
                "name": "&" + name,
                "description": describe_macro(body),
                "waitMs": int_prop(body, "wait-ms") or MACRO_DEFAULT_WAIT_MS,
                "tapMs": int_prop(body, "tap-ms") or MACRO_DEFAULT_TAP_MS,
                "bindings": [
                    to_binding(t, layer_numbers) for t in split_bindings(inner.group(1) if inner else "")
                ],
                "params": [],
            }
        )
    return out


def parse_processors(text):
    out = []
    for chunk in re.findall(r"<([^>]*)>", text):
        parts = chunk.split()
        entry = {"code": parts[0], "params": []}
        for p in parts[1:]:
            entry["params"].append(int(p) if p.lstrip("-").isdigit() else p)
        out.append(entry)
    return out


def parse_listeners(src, layer_numbers):
    listeners = []
    for m in re.finditer(r"&(cirque_\w+_listener)\s*\{", src):
        body = brace_block(src, src.index("{", m.start()))
        nodes, top = [], body
        for nm in re.finditer(r"(\w+)\s*\{", body[1:]):
            node = brace_block(body[1:], body[1:].index("{", nm.start()))
            top = top.replace(node, "")
            layers = re.search(r"layers\s*=\s*<([^>]*)>", node)
            if not layers:
                continue
            numbers = [int(layer_numbers.get(x, x)) for x in layers.group(1).split()]
            procs = re.search(r"input-processors\s*=\s*(<[^;]*)", node)
            nodes.append(
                {
                    "code": "layer_%d" % numbers[0],
                    "layers": numbers,
                    "inputProcessors": parse_processors(procs.group(1)) if procs else [],
                }
            )
        procs = re.search(r"input-processors\s*=\s*(<[^;]*)", top)
        listeners.append(
            {
                "code": "&" + m.group(1),
                "inputProcessors": parse_processors(procs.group(1)) if procs else [],
                "nodes": nodes,
            }
        )
    return listeners


def main(keymap_path, out_path):
    src = pathlib.Path(keymap_path).read_text()

    layer_numbers = dict(re.findall(r"#define\s+(LAYER_\w+)\s+(\d+)", src))
    key_groups = {
        k: " ".join(v.split()) for k, v in re.findall(r"#define\s+(KEYS_\w+)\s+([\d\s]+?)\n", src)
    }

    names, layers = [], []
    keymap = src[src.index("keymap {") :]
    for name, body in re.findall(r"layer_(\w+)\s*\{\s*bindings = <(.*?)>;", keymap, re.S):
        tokens = split_bindings(body)
        if len(tokens) != 60:
            raise SystemExit("layer %s has %d bindings, expected 60" % (name, len(tokens)))
        names.append(name)
        layers.append([to_binding(t, layer_numbers) for t in tokens])

    layout = {
        "keyboard": "go60",
        "firmware_api_version": "1",
        "locale": "en-US",
        "uuid": UUID,
        "parent_uuid": PARENT_UUID,
        "unlisted": False,
        "date": int(pathlib.Path(keymap_path).stat().st_mtime),
        "creator": "HagaSpa",
        "title": "go60 (dotfiles)",
        "notes": "Generated from .config/zmk/config/go60.keymap by mise run zmk-layout. "
        "The keymap file is the source of truth; edits made here are not carried back.\n"
        "\n"
        "Two things cannot be expressed here and are shown approximately:\n"
        "- Space is a plain &kp SPACE. The real binding is a mod-morph that sends 英数 "
        "before Ctrl+Space (the tmux/herdr prefix).\n"
        "- The editor rejects LA(LEFT), LA(RIGHT), LC(LA(LGUI)) and LC(SPACE), so ; shows "
        "as Cmd instead of ⌘⌥⌃ (Raycast), and Nav's , / . show as bare arrows instead of "
        "Opt+←/→ (word-wise movement).",
        "tags": ["qwerty", "mac"],
        "custom_defined_behaviors": "",
        "custom_devicetree": "",
        "config_parameters": [],
        "layout_parameters": {},
        "layer_names": names,
        "layers": layers,
        "macros": parse_macros(named_block(src, "macros"), layer_numbers),
        "inputListeners": parse_listeners(src, layer_numbers),
        "holdTaps": parse_hold_taps(named_block(src, "behaviors"), key_groups),
        "combos": [],
    }

    pathlib.Path(out_path).write_text(json.dumps(layout, ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
