import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const catalogPath = new URL('./preset_catalog.json', import.meta.url);
const catalog = JSON.parse(await readFile(catalogPath, 'utf8'));

assert.equal(catalog.version, 1, 'Preset catalog version must be 1.');
assert.ok(Array.isArray(catalog.presets), 'Preset catalog must contain a presets array.');
assert.equal(catalog.presets.length, 67, 'Expected the complete Jam preset library.');

const identifiers = new Set();
const groupCounts = new Map([['Jam', 0], ['Solo', 0]]);
for (const preset of catalog.presets) {
  assert.equal(typeof preset.id, 'string', 'Each preset needs a stable ID.');
  assert.ok(preset.id.length > 0, 'Preset IDs must not be empty.');
  assert.ok(!identifiers.has(preset.id), `Preset ID is duplicated: ${preset.id}`);
  identifiers.add(preset.id);

  assert.equal(typeof preset.name, 'string', `${preset.id} needs a display name.`);
  assert.ok(preset.name.length > 0, `${preset.id} has an empty display name.`);
  assert.equal(typeof preset.prompt, 'string', `${preset.id} needs a prompt.`);
  assert.ok(preset.prompt.length > 0, `${preset.id} has an empty prompt.`);
  assert.ok(groupCounts.has(preset.group), `${preset.id} has an unknown group.`);
  groupCounts.set(preset.group, groupCounts.get(preset.group) + 1);
}

assert.equal(groupCounts.get('Jam'), 39, 'Jam preset count changed unexpectedly.');
assert.equal(groupCounts.get('Solo'), 28, 'Solo preset count changed unexpectedly.');

console.log(`Validated ${catalog.presets.length} Magenta presets.`);
