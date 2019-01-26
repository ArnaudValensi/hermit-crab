const fs = require('fs');
const glob = require('glob-promise');
const chalk = require('chalk');
const { execSync, spawn } = require('child_process');
const dedent = require('dedent');

const CART_FILE = `${require('../package.json').name}.p8`;

(async function main() {
  function getSection(name) {
    let section = [name];
    const fileLines = fs
      .readFileSync("./hermit-carb.p8")
      .toString()
      .split('\n');

    const sectionLine = fileLines.indexOf(name);

    if (sectionLine === -1) {
      return section[0];
    }

    for (let index = sectionLine + 1; index < fileLines.length; index++) {
      if (fileLines[index].startsWith('__')) {
        break;
      }
      section.push(fileLines[index]);
    }

    return section.join('\n');
  }

  async function getFileList() {
    const sourceFiles = await glob('./src/**/*.lua');
    const entryIndex = sourceFiles.indexOf('./src/index.lua');
    if (entryIndex === -1) {
      console.error('Cannot find `./src/index.lua`');
      process.exit(1);
    }

    sourceFiles.splice(entryIndex, 1);

    return sourceFiles;
  }

  function readLuaFiles(sourceFiles) {
    let luaData = '';

    sourceFiles.forEach((file) => {
      luaData += fs.readFileSync(file).toString();
    });

    luaData += fs.readFileSync('./src/index.lua').toString();

    return luaData;
  }

  function loadCart(filename) {
    const runApplescript = (...scripts) => execSync(`osascript ${scripts.map(x => `-e '${x}'`).join(' ')}`)
    const activate = 'tell application "PICO-8" to activate'
    const loadCart = dedent`tell application "System Events"
      key code 53
      "load ${filename}"
      key code 36
      delay .1
      key code 15 using control down
      end tell`;

    runApplescript(activate, 'delay .3', loadCart);
  }

  const header = dedent`pico-8 cartridge // http://www.pico-8.com
    version 16
    __lua__`;

  const gfxData = getSection('__gfx__');
  const gffData = getSection('__gff__');
  const mapData = getSection('__map__');
  const sfxData = getSection('__sfx__');
  const sourceFiles = await getFileList();

  console.log(`${chalk.blue('Building the following files:')}\n ${chalk.green('./src/index.lua\n ' + sourceFiles.join('\n '))}`);

  const luaData = readLuaFiles(sourceFiles);
  const buildData = `${header}\n${luaData}\n${gfxData}\n${gffData}\n${mapData}\n${sfxData}`;

  fs.writeFileSync(CART_FILE, buildData);

  console.log(chalk.yellow('Success'));

  loadCart(CART_FILE);
})().catch(console.error);
