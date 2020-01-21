const fs = require("fs");

const { getBombardiers } = require("./pptr-get-bombardiers.js");

(async function() {
  console.log('Fetching bombardier data...');
  const bombardierTrains = await getBombardiers();
  const bombardierText = `
// from http://www.caltrain.com/Page4354.aspx. Page sez "(Effective April 4, 2016" but it's updated occasionally
// see also http://www.caltrain.com/about/statsandreports/commutefleets.html
var bombardiers = ${JSON.stringify(bombardierTrains)};
`;
  fs.writeFileSync(`${__dirname}/data/bombardiers.js`, bombardierText.trim(), "utf-8");
  console.log("Bombardier data updated.");

  const filenames = [
    "calendar.js",
    "calendar_dates.js",
    "routes.js",
    "stops.js",
    "train_numbers.js",
    "bombardiers.js"
  ];

  let textToInline = "";

  for (const filename of filenames) {
    const text = fs.readFileSync(`${__dirname}/data/${filename}`, "utf-8");
    textToInline += `
        // ${filename}
        ${text}`;
  }

  const documentFilename = `${__dirname}/index.html`;
  const documentHTML = fs.readFileSync(documentFilename, "utf-8");
  const re = /<script defer async>[\s\S]*<!-- EO DATA -->/;

  if (!documentHTML.match(/<script defer async>[\s\S]*<!-- EO DATA -->/))
    throw new Error("Did not match regex");

  const newHTML = documentHTML
    .replace(
      re,
      `
    <script defer async>
  ${textToInline}
    </script> <!-- EO DATA -->
  `.trim()
    )
    .replace(
      /effective Caltrain schedule, .*?\./,
      `effective Caltrain schedule, ${new Date().toDateString()}.`
    );

  fs.writeFileSync(documentFilename, newHTML, "utf-8");

  console.log("Inlining complete.");
})();
