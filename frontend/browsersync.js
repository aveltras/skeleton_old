const serve = require('browser-sync')
const proxy = require('http-proxy-middleware')
const path = require('path')
const Bundler = require('parcel-bundler')

const bundler = new Bundler([
    path.join(__dirname, 'assets/app.css'),
    path.join(__dirname, './index.js')
], {
  cache: true,
  minify: false,
  sourceMaps: true,
  watch: true,
  outDir: path.join(__dirname, '../build'),
  publicUrl: '/static',
  detailReport: true,
  cache: true,
  minify: true,
  sourceMaps: true,
  http: true
})

serve({
  port: 3000,
  notify: false,  
  open: false,
  watch: true,
  files: [
    path.join(__dirname, '../build'),
    path.join(__dirname, '../backend/src/**'),
  ],
  server: {
    baseDir: path.join(__dirname, '../build')
  },
  middleware: [
    proxy('http://localhost:8080', {}),
    bundler.middleware()
  ]
})
