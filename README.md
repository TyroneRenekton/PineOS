# PineOS

# 运行环境
mac -> docker -> centos -> bochs

# 常用docker命令
* 创建容器 docker run -it 镜像id /bin/bash
* 启动容器 docker start 容器id
* 停止容器 dokcer stop 容器id
* 主机传输文件给容器 docker cp /path container_id:/path

# 加载MBR

# bochs调试命令
x/n 物理地址，查看机器码
disasm/n 线性地址 ，查看命令

# 分页

# 分页查命令地址
jmp $
r 查看ip寄存器


