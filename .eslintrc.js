module.exports = {
  "extends": "google",
  "env": {
    "browser": true,
    "es6": true
  },
  "rules": {
    "camelcase": 0,
    "curly": [2, "multi"],
    "max-len": [2, 120, {
      "ignoreComments": true,
      "ignoreUrls": true,
      "tabWidth": 2
    }],
    "no-implicit-coercion": [2, {
      "boolean": false,
      "number": true,
      "string": true
    }],
    "no-unused-expressions": [2, {
      "allowShortCircuit": true,
      "allowTernary": false
    }],
    "no-unused-vars": [2, {
      "vars": "all",
      "args": "after-used",
      "argsIgnorePattern": "(^reject$|^_$)",
      "varsIgnorePattern": "(^_$)"
    }],
    "quotes": [1, "single"],
    "no-var": 0,
    "require-jsdoc": 0,
    "valid-jsdoc": 0
  }
}
