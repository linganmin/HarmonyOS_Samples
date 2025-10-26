from flask import Flask, send_file
import os

app = Flask(__name__)

# 设置视频文件的路径
VIDEO_PATH = 'D:/test/0.mp4'

# 视频文件的URL路径
@app.route('/video')
def video():
    return send_file(VIDEO_PATH)

if __name__ == '__main__':
    # 运行在0.0.0.0上，这样局域网内的其他设备也能访问
    app.run(host='0.0.0.0', port=5000)