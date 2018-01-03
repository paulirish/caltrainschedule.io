'use strict';

const puppeteer = require('puppeteer');
const statikk = require('statikk');

const PORT = 8992;

(async () => {
  const browser = await puppeteer.launch({headless: false});
  const page = await browser.newPage();

  const server = statikk({port: PORT});
  await page.goto(`http://localhost:${PORT}`);

  await page.waitForSelector('footer');
  await page.setViewport({height: 600, width: 1100});
  await page.addScriptTag({path: './test/injected-test.js'});

  await page.evaluate(() => {
    test();
  });

  console.log('awaiting test files to be downloaded...')
  // wait for network to be idle
  await new Promise(resolve => {
    page._client.on('Page.lifecycleEvent', e => {
      if (e.name === 'networkIdle') resolve();
    });
  });

  const failureText = await page.$eval('#test_result #failed', elem => elem.innerText.trim());

  if (failureText === 'Total failed:0') {
    console.log('PASS');
    await browser.close();
    process.exit(0);
  } else {
    await page.screenshot({fullPage: true, path: `./screenshot.png`});
    console.error('FAIL!');
    console.error(failureText);
    process.exit(1);
  }
})();
