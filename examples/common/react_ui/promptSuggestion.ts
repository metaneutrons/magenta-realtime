import catalog from '../preset_catalog.json';

export type MagentaPreset = {
  id: string;
  name: string;
  group: 'Jam' | 'Solo';
  prompt: string;
};

type PresetCatalog = {
  version: number;
  presets: MagentaPreset[];
};

export const PRESET_CATALOG_VERSION = (catalog as PresetCatalog).version;
export const MAGENTA_PRESETS = (catalog as PresetCatalog).presets;
export const PROMPT_SUGGESTIONS = MAGENTA_PRESETS
  .filter((preset) => preset.group === 'Jam')
  .map((preset) => preset.prompt);
export const INSTRUMENT_SUGGESTIONS = MAGENTA_PRESETS
  .filter((preset) => preset.group === 'Solo')
  .map((preset) => preset.prompt);
export const ALL_SUGGESTIONS = MAGENTA_PRESETS.map((preset) => preset.prompt);
