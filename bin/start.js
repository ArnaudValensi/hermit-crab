const { spawn } = require('child_process');

const CART_FILE = `${require('../package.json').name}.p8`;

spawn(`/Applications/PICO-8.app/Contents/MacOS/pico8`, ['-run', CART_FILE], {
    detached: true,
    stdio: 'ignore',
}).unref();
