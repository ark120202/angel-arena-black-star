const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface(process.stdin, process.stdout);
rl.setPrompt('Dota Path: ');
rl.prompt();

rl.on('line', (dotaPath) => {
  const gamePath = `${dotaPath}/game/dota_addons`;
  const contentPath = `${dotaPath}/content/dota_addons`;
  if (!fs.existsSync(gamePath)) {
    console.log(`${gamePath} not found`);
    rl.prompt();
    return;
  }
  if (!fs.existsSync(contentPath)) {
    console.log(`${contentPath} not found`);
    rl.prompt();
    return;
  }
  rl.close();

  (async () => {
    await fs.promises.rename('./game', gamePath + '/angel_arena_black_star_v0');
    await fs.promises.rename('./content', contentPath + '/angel_arena_black_star_v0');
    await fs.promises.symlink(gamePath + '/angel_arena_black_star_v0', './game', 'junction');
    await fs.promises.symlink(contentPath + '/angel_arena_black_star_v0', './content', 'junction');
  })().catch(err => {
    console.error(err);
    process.exit(1);
  });
});
