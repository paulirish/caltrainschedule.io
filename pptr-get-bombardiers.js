const puppeteer = require('puppeteer');

function extractTrains() {
  var table = document.querySelector('#middle').querySelector('table');
  table.querySelector('tr').remove();
  var str = table.textContent.replace(/\n\s+(\d+)(\s+)?\n\s+/g, ',\n $1, ');
  return str;
};

async function getBombardiers() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto('http://www.caltrain.com/Page4354.aspx');
  const trainsStr = await page.evaluate(extractTrains);

  // Eval the string so we can sort() it
  eval(`var bombardiers = [${trainsStr}]`);

  await browser.close();

  return bombardiers.filter(Boolean).sort();
};

module.exports = {
  getBombardiers,
}