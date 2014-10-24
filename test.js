#!/usr/bin/env node

var sget = require('./sget');
var something = sget('Say something. I\'ll wait.');
console.log('You said', something);

sget('Leave word and you will be heard.', function(data) {
  console.log('I heard you said', data);
});
console.log('\nThis test is not over.');
