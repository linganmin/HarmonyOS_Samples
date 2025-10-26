var express = require('express');
var path = require('path');
var proxy = require('http-proxy-middleware');

var app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.static(path.join(__dirname, 'dist')));

app.use('/images', express.static('images'));
app.use('/api', proxy.createProxyMiddleware({ target: 'https://devecostudio-drcn.op.hicloud.com/solution/v1', changeOrigin: true }));

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

app.listen(8080, () => {
  console.log('服务器启动成功！');
});

module.exports = app;
