const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  devServer: {
    proxy: {
      '/api': {
        target: 'https://devecostudio-drcn.op.hicloud.com/solution/v1',
        changeOrigin: true,
        pathRewrite: { '^/api': '' }//重定向
      }
    }
  }
})
