# 测试环境搭建

> **说明**：FFmpeg以及Nginx请自行查阅官网进行安装与环境配置。

## 多码率视频流生成

1. 准备视频源文件，可使用mp4格式的视频文件。

2. 基于已有mp4源文件，参考以下命令，使用FFmpeg生成360p、720p以及1080p三种分辨率的视频流，替换`your_input_file`为实际mp4文件路径，`output_path`为视频输出根目录。

   > **说明**：使用时注意命令换行符，windows下powershell为`，cmd为^，bash默认为\。

   ```bash
   ffmpeg -i your_input_file \
       -preset medium -g 60 -sc_threshold 0 \
       -filter_complex "
           [0:v]split=3[v1][v2][v3];
           [v1]scale=640:360[v360];
           [v2]scale=1280:720[v720];
           [v3]scale=1920:1080[v1080];
           [0:a]asplit=3[a1][a2][a3]" \
       -map "[v360]" -map "[a1]" \
       -map "[v720]" -map "[a2]" \
       -map "[v1080]" -map "[a3]" \
       -c:v libx264 -profile:v main \
       -b:v:0 1000k -maxrate:0 1500k -bufsize:0 2000k \
       -b:v:1 3000k -maxrate:1 4500k -bufsize:1 6000k \
       -b:v:2 5000k -maxrate:2 7500k -bufsize:2 10000k \
       -c:a aac -b:a 128k -ar 44100 \
       -f hls -hls_time 6 -hls_list_size 0 \
       -master_pl_name "master.m3u8" \
       -var_stream_map "v:0,a:0,name:360p v:1,a:1,name:720p v:2,a:2,name:1080p" \
       "output_path/%v/index.m3u8"
   ```

   输出的视频流文件结构如下：

   ```
   ├──360p  
   │  ├──index.m3u8               // 单码率m3u8索引文件
   │  ├──index0.ts                // 视频分片文件
   │  ├──index1.ts                // 视频分片文件
   │  └──...                          
   ├──720p  
   │  ├──index.m3u8               // 单码率m3u8索引文件
   │  ├──index0.ts                // 视频分片文件
   │  ├──index1.ts                // 视频分片文件
   │  └──...    
   ├──1080p                                     
   │  ├──index.m3u8               // 单码率m3u8索引文件
   │  ├──index0.ts                // 视频分片文件
   │  ├──index1.ts                // 视频分片文件
   │  └──...                
   └──master.m3u8                 // 主m3u8索引文件，访问此文件进行多码率视频流播放
   ```

## 服务器搭建

1. 修改Nginx配置文件nginx.conf，参考以下配置：

   ```text
   server {
       listen 80;      # 默认监听80端口
       server_name _;  # 仅本地访问的情况下可配置为"_"或留空
   
       location /videos {
           alias path/to/hls;  # 替换为master.m3u8所在父目录的完整路径
           add_header 'Access-Control-Allow-Origin' '*';
   
           types {
               application/vnd.apple.mpegurl m3u8;
               video/mp2t ts;
           }
       }
   }
   ```

2. 使用上述配置启动Nginx服务后，保证播放设备和搭建服务器的PC在同一局域网内，之后可使用服务端的ip地址访问并播放视频资源，参考以下配置，替换`your_server_ip`为服务器PC的ip地址。

   > **说明**：如果自定义了其他监听端口则需要在ip后指定，例如`127.0.0.1:8080`。

   ```typescript
   // CustomConfig.ets
   export class CustomConfigs {
     // ...
     public static readonly URL = 'http://your_server_ip/videos/master.m3u8';
     // ...
   }
   ```