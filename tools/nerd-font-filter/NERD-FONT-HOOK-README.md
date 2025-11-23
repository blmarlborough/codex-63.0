# Nerd Font Icon Replacement Hook

Automatically replaces Claude's emoji with proper Nerd Font icons in Claude Code Web.

## Installation

### Option 1: Tampermonkey (Recommended)

1. Install [Tampermonkey](https://www.tampermonkey.net/) browser extension
   - Chrome/Edge: https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo
   - Firefox: https://addons.mozilla.org/en-US/firefox/addon/tampermonkey/
   - Safari: https://apps.apple.com/us/app/tampermonkey/id1482490089

2. Open Tampermonkey dashboard

3. Click "+" to create new script

4. Copy contents of `emoji-to-nerd-font.user.js` into the editor

5. Save (Ctrl+S / Cmd+S)

6. Reload Claude Code web page

### Option 2: Greasemonkey (Firefox)

1. Install [Greasemonkey](https://addons.mozilla.org/en-US/firefox/addon/greasemonkey/)

2. Click Greasemonkey icon → New user script

3. Paste contents of `emoji-to-nerd-font.user.js`

4. Save and reload Claude page

### Option 3: Violentmonkey

1. Install [Violentmonkey](https://violentmonkey.github.io/get-it/)

2. Click Violentmonkey icon → "+" button

3. Paste script contents

4. Save

## Emoji Mapping

The script replaces these emoji with Nerd Font icons:

| Emoji | Nerd Font | Name              |
|-------|-----------|-------------------|
| ✅     |         | CHECKMARK         |
| ❌     |         | RED-X             |
| ✓     |         | CHECKMARK         |
| ✗     |         | RED-X             |
| ☑     | 󰄵        | TASK-COMPLETE     |
| ☐     |         | TASK-INCOMPLETE   |
| ⭐     | 󰓎        | STAR-KEY-INFO     |
| ℹ️     |         | GEN-INFO          |
| ⚠️     |         | CAUTION           |
| 🚨     | 󰝧        | AGENT-RISK        |

## Adding More Mappings

Edit the `EMOJI_MAP` object in the script:

```javascript
const EMOJI_MAP = {
    '🎯': '󰀘', // your custom mapping
    // ...
};
```

Find Nerd Font icons at: https://www.nerdfonts.com/cheat-sheet

## Verifying It Works

1. Open browser console (F12)
2. Look for: `[Nerd Font Filter] Emoji replacement active`
3. Test by having Claude respond with emoji - they should render as Nerd Font icons

## Terminal Requirements

Your terminal MUST have a Nerd Font installed:
- Install from: https://www.nerdfonts.com/
- Popular choices:
  - FiraCode Nerd Font
  - JetBrainsMono Nerd Font
  - Hack Nerd Font

Configure your terminal to use the Nerd Font as the default typeface.

## Troubleshooting

**Icons show as boxes/question marks:**
- Install a Nerd Font in your terminal
- Set terminal font to the Nerd Font

**Script not running:**
- Check Tampermonkey is enabled
- Verify script is enabled in Tampermonkey dashboard
- Check browser console for errors
- Ensure URL matches: `https://claude.ai/*` or `https://*.claude.ai/*`

**Some emoji still showing:**
- Add them to EMOJI_MAP in the script
- File an issue with the emoji you want mapped

## Alternative: System-wide Filter

For non-browser Claude Code usage, create a response filter:

```bash
#!/usr/bin/env bash
# ~/.claude/filter-response.sh

# Read stdin, replace emoji, output
sed 's/✅//g; s/❌//g; s/☑/󰄵/g; s/☐//g; s/⭐/󰓎/g; s/ℹ️//g; s/⚠️//g; s/🚨/󰝧/g'
```

Then pipe Claude responses through it.
