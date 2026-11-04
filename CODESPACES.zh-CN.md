# 在 GitHub Codespaces 运行 OpenFilm

这个仓库在官方 `openfilm/openfilm` 源码上增加了 GitHub Codespaces 启动配置。OpenFilm Studio 需要 Node 服务和本地文件系统，不能作为纯静态 GitHub Pages 网站运行，因此部署目标是 Codespaces。

## 启动

1. 打开仓库的 **Code** 菜单，选择 **Codespaces**。
2. 点击 **Create codespace on main**。
3. 等待容器安装依赖并自动启动 Studio。
4. 打开 **Ports** 面板中的 `4848` 端口；终端也会打印带登录密钥的 Studio 地址。

Codespaces 首次创建通常需要数分钟。端口保持为 `Private`，只有当前 GitHub 账号可以通过转发地址访问。

## 配置

- `.devcontainer/devcontainer.json`：Node 22 开发容器、端口转发和自动启动。
- `.devcontainer/setup.sh`：安装 ffmpeg、pnpm 依赖并构建 Studio。
- `.devcontainer/start-openfilm.sh`：启动 Studio，并根据 Codespaces 公开域名生成可访问地址。
- `OPENFILM_STUDIO_ORIGIN`、`OPENFILM_FILM_ORIGIN`：只在宿主代理存在时设置，让 Studio 接受 Codespaces 的 HTTPS 转发域名。

## 停止与重启

Codespaces 停止后，重新打开即可通过 `postStartCommand` 自动启动 Studio。日志位于 `packages/openfilm/.dev/codespace.log`，运行地址写入 `packages/openfilm/.dev/codespace-url.txt`。

## 说明

这是 GitHub Codespaces 部署，不是 GitHub Pages。前者可以运行 Node、Chromium、ffmpeg 和 Studio 的文件系统；后者只能托管静态文件，无法提供 OpenFilm 的编辑和渲染能力。
