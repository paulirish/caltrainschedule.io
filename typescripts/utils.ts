interface Navigator { serviceWorker: any; }

function extendObject(destination, source) {
  for (var property in source) {
    if (source.hasOwnProperty(property)) {
      destination[property] = source[property];
    }
  }
  return destination;
};

var $ = document.querySelector.bind(document);
var $$ = document.querySelectorAll.bind(document);

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').then(function() {
    console.log('service worker is is all cool.');
  }).catch(function(e) {
    console.error('service worker is not so cool.', e);
    throw e;
  });
}

interface Node {
  on: (string, EventListenerOrEventListenerObject) => void
}

interface NodeList {
  on: (string, EventListenerOrEventListenerObject) => void
}

Node.prototype.on = function(name : string, fn : EventListenerOrEventListenerObject) {
  this.addEventListener(name, fn);
}

NodeList.prototype.on = (function(name, fn) {
  this.forEach(function(elem) {
    elem.on(name, fn);
  });
});

interface String {
  repeat: (integer) => string;
  rjust: (width, padding) => string;
  small: () => string
}

String.prototype.repeat = function(num) {
  return (num <= 0) ? '' : this + this.repeat(num - 1);
};

String.prototype.rjust = function(width, padding) {
  padding = (padding || ' ').substr(0, 1); // one and only one char
  return padding.repeat(width - this.length) + this;
};

String.prototype.small = function() {
  return "<small>" + this + "</small>";
};
