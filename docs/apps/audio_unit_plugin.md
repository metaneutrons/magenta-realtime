# Audio Unit Plugin

The Audio Unit plugin provides DAW integration and raw access to the MRT2 model itself for maximum control. It is an AUv3 instrument that runs inside a DAW. See [macOS apps](index.md) for the shared prerequisites and build pattern.

## Prerequisites

```bash
brew install node
```

## Build & deploy

```bash
source .venv/bin/activate
cmake . -B build
cmake --build build --target deploy_mrt2_au -j10
```

After a successful build, the plugin is deployed to
`~/Applications/MRT2 (AU).app`. Open it once to register the Audio Unit:

```bash
open ~/Applications/MRT2\ \(AU\).app
```

```{note}
If the plugin fails to load in your DAW, macOS's `pluginkit` may have cached a
stale or broken build (e.g., from your Downloads folder). You can verify
registered plugin paths by running `pluginkit -mAv | grep -i mrt`. If it
points to an incorrect path, unregister the bad one with
`pluginkit -r <bad_path>` and explicitly register the correct one with
`pluginkit -a "/Applications/MRT2 (AU).app/Contents/PlugIns/MRT2_AU.appex"`.
```

## Use the plugin

1. In **Ableton Live**, go to *Settings → Plug-Ins* and enable **"Use Audio Unit v3"**, then **"Rescan Plug-Ins"**.
2. Load the MagentaRT instrument on a track.
3. Click **"Load Model…"** and select the exported model *folder* (e.g. `~/Documents/Magenta/magenta-rt-v2/models/mrt2_base/`).

## Presets

The plug-in ships the Jam prompt library as AUv3 factory presets. They are
available from both the plug-in's **Presets** menu and a DAW's native Audio
Unit preset browser. The menu groups the library into **Jam** and **Solo**
prompt suggestions.

The same list is exposed to the host as the discrete **Factory Preset**
parameter. In Ableton Live, select that parameter in the device's automation
chooser to automate factory-preset changes. A change made in the plug-in menu
updates this parameter too, so the host and plug-in show the same factory
preset. Live displays the preset names rather than the numeric values.

Factory presets change the prompt only. They deliberately do not restore a
transformer bank, random state, or audio-prefill context, because those are
time- and model-specific musical states rather than reusable sound designs.

Use your DAW's normal Audio Unit **Save Preset** command for user presets. The
plug-in serializes its prompt configuration, AU parameters, prompt surface,
model bookmark, and loaded audio-prompt embeddings with the host project or
user preset.
