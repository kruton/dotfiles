// Keep runtime and plugin declarations covered by the configured managers.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');
const read = (file) => fs.readFileSync(path.join(root, file), 'utf8');
const config = JSON.parse(JSON.stringify(vm.runInNewContext(`(${read('renovate.json5')})`)));

function extract(file, text) {
  return config.customManagers.flatMap((manager) => {
    if (!manager.managerFilePatterns.some((pattern) =>
      new RegExp(pattern.slice(1, -1)).test(file))) return [];
    return manager.matchStrings.flatMap((pattern) =>
      [...text.matchAll(new RegExp(pattern, 'g'))].map((match) => ({
        ...match.groups,
        datasource: match.groups.datasource || manager.datasourceTemplate,
      })));
  });
}

const files = [
  '.chezmoidata/runtimes.yaml',
  'dot_vim/settings/plugins.vim',
  'dot_config/nvim/init.lua',
  ...fs.readdirSync(path.join(root, '.chezmoiexternals'))
    .filter((file) => file.endsWith('.toml'))
    .map((file) => `.chezmoiexternals/${file}`),
];
const dependencies = new Map();
for (const file of files) {
  const text = read(file);
  const found = extract(file, text);
  assert.equal(new Set(found.map((dep) => dep.depName)).size, found.length,
    `${file}: duplicate dependency extraction`);
  dependencies.set(file, found);

  console.log(`${file}: ${found.length} dependencies discovered`);
}

const runtime = dependencies.get('.chezmoidata/runtimes.yaml');
for (const tool of ['node', 'ruby']) {
  assert.equal(runtime.find((dep) => dep.depName === tool).datasource, `${tool}-version`);
}
const vimPlugins = [...read('dot_vim/settings/plugins.vim').matchAll(/^\s*Plug '([^']+)'/gm)]
  .map((match) => match[1]).sort();
assert.deepEqual(dependencies.get('dot_vim/settings/plugins.vim').map((dep) => dep.depName).sort(), vimPlugins);
assert.equal(dependencies.get('dot_config/nvim/init.lua').length,
  [...read('dot_config/nvim/init.lua').matchAll(/^\s*(?:commit|version) = /gm)].length);
const tmuxPlugins = [...read('dot_tmux.conf').matchAll(/set -g @plugin '([^']+)'/g)]
  .map((match) => match[1]).sort();
assert.deepEqual(dependencies.get('.chezmoiexternals/tmux.toml').map((dep) => dep.depName).sort(), tmuxPlugins);
