/**
 * github.com/bucaran/sget
 *
 * sget. Async / Sync read line for Node.
 *
 * @copyright (c) 2014 Jorge Bucaran
 * @license MIT
 */
var fs = require('fs');
/**
 * Read a line from stdin sync. If callback is undefined reads it async.
 *
 * @param {String} prompt Message to log before reading stdin.
 * @param {Function} callback If specified, reads the stdin async.
 */
var sget = module.exports = function(prompt, callback) {
  win32 = function() {
    return ('win32' === process.platform);
  },
  readSync = function(buffer) {
    var fd = win32() ? process.stdin.fd : fs.openSync('/dev/stdin', 'rs');
    var bytes = fs.readSync(fd, buffer, 0, buffer.length);
    if (!win32()) fs.closeSync(fd);
    return bytes;
  };
  prompt = prompt || '';
  if (callback) {
    var rl = require('readline').createInterface(
      process.stdin, process.stdout);
    rl.question(prompt, function(data) {
      callback(data);
      rl.close();
    });
  } else {
    return (function(buffer) {
      try {
        console.log(prompt);
        return buffer.toString(null, 0, readSync(buffer));
      } catch (e) {
        throw e;
      }
    }(new Buffer(sget.bufferSize)));
  }
};
/**
 * @type {Number} Size of the buffer to read.
 */
sget.bufferSize = 256;
