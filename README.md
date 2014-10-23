## _sget_ [![badge]][npm]

> Async / Sync read line for Node.

## Install

```sh
npm install sget
```

## Description

Reads a line from the [standard input][stdin] synchronously if no callback is specified, otherwise reads it asynchronously. Think C [gets][cppref] for [Node][node].

## Usage

```js
var sget = require('sget');

var something = sget('Say something. I\'ll wait.');
console.log('You said', something);

sget('Leave word and you will be heard.', function(data) {
  console.log('I heard you said', data);
});
console.log('\nThis test is not over.');
```

## Test
```sh
./test.js
```
If the above fails, you may need to give execute permissions to the file owner, just run `chmod u+x test.js`. Click [here][chmod] for more info.

## Help

Do you want to help? Open an issue [here][issues]. Comments, feedback and / or pull requests are welcome.

## License

MIT © [Jorge Bucaran](http://bucaran.me)

[cppref]: http://en.cppreference.com/w/c/io/gets
[node]: http://nodejs.org/
[issues]: https://github.com/bucaran/sget/issues
[stdin]: http://en.wikipedia.org/wiki/Standard_streams#Standard_input_.28stdin.29
[chmod]: http://www.zzee.com/solutions/chmod-help.shtml
[badge]: http://img.shields.io/badge/npm-sget-green.svg?style=flat-square
[npm]: https://www.npmjs.org/package/sget
