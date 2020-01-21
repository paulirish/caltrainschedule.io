const fs = require("fs");

const { getBombardiers } = require("./pptr-get-bombardiers.js");

(async function() {
  console.log('Fetching bombardier data...');
  const bombardierTrains = await getBombardiers();
  const bombardierText = `
        // from http://www.caltrain.com/Page4354.aspx. Page sez "(Effective April 4, 2016" but it's updated occasionally
        // see also http://www.caltrain.com/about/statsandreports/commutefleets.html
        const bombardiers = ${JSON.stringify(bombardierTrains)};
`;
  console.log("Bombardier data fetched.");

  const dataItems = [
    "calendar",
    "calendar_dates",
    "routes",
    "stops",
    "train_numbers",
  ];

  let textToInline = "";

  for (const dataItem of dataItems) {
    const text = fs.readFileSync(`${__dirname}/data/${dataItem}.json`, "utf-8");
    textToInline += `
        // ${dataItem}
        const ${dataItem} = ${text}`;
  }
  textToInline += bombardierText;

  const documentFilename = `${__dirname}/index.html`;
  const documentHTML = fs.readFileSync(documentFilename, "utf-8");
  const re = /<script defer async>[\s\S]*<!-- EO DATA -->/;

  if (!documentHTML.match(/<script defer async>[\s\S]*<!-- EO DATA -->/))
    throw new Error("Did not match regex");

  const newHTML = documentHTML
    // data block
    .replace(
      re,
      `
    <script defer async>
  ${textToInline}
    </script> <!-- EO DATA -->
  `.trim()
    )
    // refreshed timestamp
    .replace(
      /effective Caltrain schedule, refreshed .*?\./,
      `effective Caltrain schedule, refreshed ${new Date().toDateString()}.`
    );

  fs.writeFileSync(documentFilename, newHTML, "utf-8");

  console.log("Inlining complete.");


  // bump the version line in sw.js
  const swText = fs.readFileSync(`${__dirname}/sw.js`, 'utf8').split('\n');
  const swVersionLine = swText[0];
  eval(swVersionLine);
  swText[0] = `var VERSION = '${++VERSION}';`;
  fs.writeFileSync(`${__dirname}/sw.js`, swText.join('\n'), 'utf8');
  console.log('sw.js VERSION bumped.');
})();
