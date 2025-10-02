# 生成一个全栈 web 应用需要的 Dockerfile

* 需要安装最新的 node.js
* 需要安装最新的 next.js
* 需要安装最新的 pgsql client 工具
* 需要安装 shadcn UI 框架
* 由于是一个智能编码的 Runtime, 所以同样需要安装 claude code
* 需要安装 buildah 方便这个 Runtime 在发布时可以在非特权模式下构建干净的 Docker 镜像
* 以及其他我没有考虑到的其它工具

# 任务

0. 根据以上需求生成 Dockerfile 
1. 在我确认 Dockerfile 无误后，安装 buildah 进行构建, 并提交到 docker 镜像仓库, 仓库用户名密码我已经设置到环境变量中了.
2. 替换 Readme, 给出如何使用这个 Runtime 的说明书，以及这个 Runtime 的环境变量列表。