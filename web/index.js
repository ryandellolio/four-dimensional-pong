import init, { greet } from './pkg/four_dimensional_pong.js';

async function run() {
  await init();
  greet("Hello, WebAssembly!");
}

document.getElementById("run-button").addEventListener("click", run);