# SKIN-DOCKER

```shell
IMAGE=ghcr.io/lakelink/blessing-skin-server:latest
docker pull "$IMAGE"

# 创建临时容器，不启动服务
docker create --name skin-init "$IMAGE"

# 将镜像内的文件复制到宿主机，保留所有权
mkdir -p ./data/skin/public ./data/skin/storage
docker cp -a skin-init:/var/www/html/public/. ./data/skin/public/
docker cp -a skin-init:/var/www/html/storage/. ./data/skin/storage/

# 删除临时容器及其匿名卷
docker rm -v skin-init

docker compose up -d
```

本仓库提供开箱即用的 Blessing Skin 容器化部署方案，包括 Blessing Skin 本体、Janus、Web Server 等。
 
这个仓库做了哪些：
1. 配置了容器化 php 环境，内置插件市场镜像，自动配置 redis 连接，自动完成 APP 密钥初始化。
2. 构建了 Janus 和 Prisma 客户端，开箱即用。
3. 配置了 FastCGI 和 Janus 代理，上游只需配置反向代理和 Https。

## 食用方式

0. 安装 `Docker` 和 `Docker Compose`，可参考[阿里云官方文档](https://help.aliyun.com/zh/ecs/user-guide/install-and-use-docker#800b337f470oq)

1. 安装并配置 Web Server，这里强烈推荐 `Caddy`，配置简单，支持自动 HTTPS。

    Caddy 配置示例  
    以域名 `skin.jsumc.fun` 和端口 `8081` 为例
    ```
    skin.jsumc.fun {
            reverse_proxy 127.0.0.1:8081
    }
    ```

2. 新建一个文件夹用于存放皮肤站相关文件。以 `/opt/skin` 为例。

3. 下载本仓库 `docker-compose.yml` 文件到 `/opt/skin` 文件夹。

4. 编辑 `docker-compose.yml` 文件，根据注释修改。

5. sqlite 用户先用 `touch data/skin.db` 创建数据库文件。以 `data/skin.db` 为例。

6. 运行 `docker compose up -d` 启动容器。

7. 运行 `docker compose --profile http up -d` 启动 HTTP 容器。

8. 打开网页安装 Blessing Skin，注意 sqlite 数据库填**容器内绝对路径**。完成后在插件市场安装 `Yggdrasil-Connect` 插件并启用。在 `OpenID 提供者标识符` 填入 `https://skin.jsumc.fun/api/janus`。这里以 `skin.jsumc.fun` 为例。

9. 运行 `docker compose exec skin php artisan yggc:create-personal-access-client --owner=1`，其中 `1` 是个人访问客户端**所属的用户**的 ID，默认不用改。输入 `yes` 回车，会得到一个 `PASSPORT_PERSONAL_ACCESS_CLIENT_ID=1`，这个 `1` 就是个人访问客户端的 ID。

10. 打开 OAuth2 应用，在刚刚创建的**个人访问客户端**对应的项目添加回调 URL `https://skin.jsumc.fun/yggc/client/public` 并确保站点配置中的站点地址（URL）已填写。

11. 运行 `docker compose --profile janus up -d` 启动 Janus 容器。

12. 打开 `data/.env` 文件

    1. `PASSPORT_PERSONAL_ACCESS_CLIENT_ID=1` 填入刚刚得到的**个人访问客户端** ID。

    2. `BS_SITE_URL=https://skin.jsumc.fun` 填入皮肤站的 URL，必须是 HTTPS。

    3. `BS_SITE_NAME="JSUCraft Skin"` 填入皮肤站的名称，注意有空格就需要用引号括起来。

    4. `BS_FAVICON_URL=https://pic.imgdb.cn/item/6725c6e7d29ded1a8c6695b3.jpg` 填入皮肤站的图标 URL。

13. 运行 `docker compose --profile http --profile janus down` 关闭所有容器。

14. 编辑 `docker-compose.yml` 文件，将 `http` 和 `jsnus` 的 `profiles` 注释掉。

15. 运行 `docker compose up -d` 启动容器。

### 独立 Client ID 和公共 ClientID

要想为每个启动器创建独立的 Client ID，需要在 `OAuth2 应用` 中创建一个新的应用，应用名为启动器名，回调 URL 中填入 `https://skin.jsumc.fun/yggc/client/public`，再将新的 Client ID 提交给启动器开发者。

启动器也会自主获取公共 Client ID，只需要在 `data/.env` 文件中修改 `SHARED_CLIENT_ID=` 这一行。改成自定义的公共 Client ID，这个 ID 对应的回调 URL 也需要设置为 `https://skin.jsumc.fun/yggc/client/public`。
