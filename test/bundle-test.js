const fs = require('fs');
const assert = require('assert');

try {
  const htmlStr = fs.readFileSync(__dirname + '/../index.html', 'utf-8');
  assert.ok(htmlStr && htmlStr.length, `index.html isnt empty`);
  const jsonFiles = fs.readdirSync(__dirname + '/../data/').filter(f => f.endsWith('.js'));

  for (const filename of jsonFiles) {
    const sourceStr = fs.readFileSync(__dirname + '/../data/' + filename, 'utf-8');
    assert.ok(sourceStr && sourceStr.length, `${filename} isnt empty`);
    assert.ok(htmlStr.includes(sourceStr), `${filename} isnt found in the html`);
  }
} catch (err) {
  console.error(err);
  process.exit(1);
}
