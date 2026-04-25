# 《I.MX6U嵌入式Linux C应用编程指南》前5章学习提纲

> 本笔记基于正点原子教程体系整理，帮助快速掌握 Linux C 应用编程基础。

---

## 第1章：Linux 基础知识

### 1.1 Linux 系统简介
**要点**：
- Linux 的特点：开源、多用户、多任务
- Linux 发行版：Ubuntu、Debian、CentOS 等
- 嵌入式 Linux：Buildroot、Yocto、正点原子定制系统

**实践**：
- 熟悉开发板的 Linux 系统
- 通过串口/SSH 连接开发板

---

### 1.2 Linux 常用命令
**必须掌握的命令**：

| 命令 | 用途 | 示例 |
|------|------|------|
| `ls` | 列出文件 | `ls -lh` |
| `cd` | 切换目录 | `cd /home` |
| `pwd` | 显示当前路径 | `pwd` |
| `mkdir` | 创建目录 | `mkdir test` |
| `rm` | 删除文件 | `rm -rf test/` |
| `cp` | 复制文件 | `cp a.txt b.txt` |
| `mv` | 移动/重命名 | `mv a.txt /tmp/` |
| `cat` | 查看文件 | `cat /etc/passwd` |
| `echo` | 输出文本 | `echo "hello" > test.txt` |
| `chmod` | 修改权限 | `chmod +x app` |
| `ps` | 查看进程 | `ps aux` |
| `kill` | 终止进程 | `kill -9 1234` |
| `ifconfig` | 网络配置 | `ifconfig eth0` |
| `mount` | 挂载文件系统 | `mount -t nfs ...` |

**实践**：
- 在开发板上练习这些命令
- 理解 Linux 文件权限（rwx）

---

### 1.3 vi/vim 编辑器
**基本操作**：
- 进入编辑模式：`i`（插入）、`a`（追加）
- 退出编辑模式：`Esc`
- 保存退出：`:wq`
- 不保存退出：`:q!`
- 删除一行：`dd`
- 复制一行：`yy`
- 粘贴：`p`
- 查找：`/关键字`

**实践**：
- 在开发板上用 vi 编辑一个简单的 C 文件

---

### 1.4 Shell 脚本基础
**要点**：
- Shell 脚本用于自动化任务
- 第一行：`#!/bin/sh`
- 变量：`name="test"`
- 条件判断：`if [ $a -eq 1 ]; then ... fi`
- 循环：`for i in 1 2 3; do ... done`

**示例脚本**：
```bash
#!/bin/sh
echo "Hello, Linux!"
echo "Current directory: $(pwd)"
```

**实践**：
- 写一个脚本自动编译并传输程序到开发板

---

## 第2章：交叉编译环境搭建

### 2.1 什么是交叉编译
**要点**：
- **本地编译**：在 x86 PC 上编译 x86 程序
- **交叉编译**：在 x86 PC 上编译 ARM 程序
- 为什么需要交叉编译：开发板性能有限，编译慢

**关键概念**：
- **主机（Host）**：编译代码的机器（Ubuntu PC）
- **目标机（Target）**：运行程序的机器（i.MX6ULL 开发板）

---

### 2.2 安装交叉编译工具链
**工具链位置**：
```
F:/Linux/【正点原子】阿尔法Linux开发板（A盘）-基础资料/03、软件/armgcc/
```

**工具链前缀**：
```
arm-linux-gnueabihf-
```

**前缀含义**：
- `arm`：目标架构是 ARM
- `linux`：目标操作系统是 Linux
- `gnueabi`：GNU Embedded ABI（嵌入式应用二进制接口）
- `hf`：hard float，使用硬件浮点运算单元（FPU）

> 所以 `arm-linux-gnueabihf-gcc` 的含义是：**针对 ARM Linux 平台的、支持硬件浮点的 GNU 交叉编译器**。

**环境变量配置**：
```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export PATH=$PATH:/path/to/armgcc/bin
```

**验证安装**：
```bash
arm-linux-gnueabihf-gcc --version
```

---

### 2.3 第一个交叉编译程序
**hello.c**：
```c
#include <stdio.h>

int main(void)
{
    printf("Hello, i.MX6ULL!\n");
    return 0;
}
```

**编译**：
```bash
arm-linux-gnueabihf-gcc hello.c -o hello
```

**传输到开发板**：
```bash
# 方法1：NFS 挂载
cp hello /home/zyq/nfs/

# 方法2：scp 传输
scp hello root@192.168.1.11:/root/
```

**在开发板上运行**：
```bash
chmod +x hello
./hello
```

**实践**：
- 完成第一个交叉编译程序
- 在开发板上成功运行

---

### 2.4 NFS 网络文件系统
**作用**：
- 开发板通过网络挂载 PC 上的目录
- 方便调试：编译后直接在开发板上运行，无需传输

**PC 端配置（Ubuntu）**：
```bash
# 安装 NFS 服务
sudo apt install nfs-kernel-server

# 编辑 /etc/exports
/home/zyq/nfs *(rw,sync,no_root_squash,no_subtree_check)

# 重启 NFS 服务
sudo systemctl restart nfs-kernel-server
```

**开发板端挂载**：
```bash
mount -t nfs -o nolock,vers=3 192.168.1.12:/home/zyq/nfs /mnt
```

**实践**：
- 配置 NFS 共享目录
- 开发板挂载成功

---

## 第3章：文件 I/O

### 3.1 Linux 文件系统
**要点**：
- Linux 下一切皆文件：普通文件、设备文件、目录、管道等
- 文件描述符（File Descriptor）：整数，标识打开的文件
- 标准文件描述符：
  - `0` - 标准输入（stdin）
  - `1` - 标准输出（stdout）
  - `2` - 标准错误（stderr）

---

### 3.2 文件 I/O 函数

#### 3.2.1 open() - 打开文件
```c
#include <fcntl.h>

int open(const char *pathname, int flags);
int open(const char *pathname, int flags, mode_t mode);
```

**参数**：
- `pathname`：文件路径
- `flags`：打开方式
  - `O_RDONLY`：只读
  - `O_WRONLY`：只写
  - `O_RDWR`：读写
  - `O_CREAT`：文件不存在则创建
  - `O_APPEND`：追加模式
  - `O_TRUNC`：清空文件内容
- `mode`：权限（如 `0644`）

**返回值**：
- 成功：文件描述符（非负整数）
- 失败：`-1`

**示例**：
```c
int fd = open("/tmp/test.txt", O_RDWR | O_CREAT, 0644);
if (fd < 0) {
    perror("open failed");
    return -1;
}
```

---

#### 3.2.2 read() - 读取文件
```c
#include <unistd.h>

ssize_t read(int fd, void *buf, size_t count);
```

**参数**：
- `fd`：文件描述符
- `buf`：缓冲区
- `count`：读取字节数

**返回值**：
- 成功：实际读取的字节数
- 到达文件末尾：`0`
- 失败：`-1`

**示例**：
```c
char buf[128];
int n = read(fd, buf, sizeof(buf));
if (n > 0) {
    buf[n] = '\0';  // 添加字符串结束符
    printf("Read: %s\n", buf);
}
```

---

#### 3.2.3 write() - 写入文件
```c
#include <unistd.h>

ssize_t write(int fd, const void *buf, size_t count);
```

**参数**：
- `fd`：文件描述符
- `buf`：数据缓冲区
- `count`：写入字节数

**返回值**：
- 成功：实际写入的字节数
- 失败：`-1`

**示例**：
```c
const char *msg = "Hello, Linux!\n";
write(fd, msg, strlen(msg));
```

---

#### 3.2.4 close() - 关闭文件
```c
#include <unistd.h>

int close(int fd);
```

**返回值**：
- 成功：`0`
- 失败：`-1`

**示例**：
```c
close(fd);
```

---

### 3.3 完整示例：文件读写
```c
/**
 * @file   file_io.c
 * @brief  文件读写示例
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main(void)
{
    int fd;
    char write_buf[] = "Hello, i.MX6ULL!";
    char read_buf[128];
    
    // 1. 打开文件（不存在则创建）
    fd = open("/tmp/test.txt", O_RDWR | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open failed");
        return -1;
    }
    
    // 2. 写入数据
    write(fd, write_buf, strlen(write_buf));
    
    // 3. 移动文件指针到开头
    lseek(fd, 0, SEEK_SET);
    
    // 4. 读取数据
    int n = read(fd, read_buf, sizeof(read_buf));
    if (n > 0) {
        read_buf[n] = '\0';
        printf("Read: %s\n", read_buf);
    }
    
    // 5. 关闭文件
    close(fd);
    
    return 0;
}
```

**编译运行**：
```bash
arm-linux-gnueabihf-gcc file_io.c -o file_io
./file_io
```

---

### 3.3.1 头文件说明

本示例涉及的四个标准头文件：

| 头文件 | 全称 | 主要功能 |
|--------|------|----------|
| `<stdio.h>` | Standard Input/Output | 标准 I/O：`printf`、`fopen`、`fread` 等 |
| `<fcntl.h>` | File Control | 文件控制：`open()` 的标志位（`O_RDWR`、`O_CREAT` 等） |
| `<unistd.h>` | UNIX Standard | 系统调用：`read()`、`write()`、`close()`、`lseek()` |
| `<string.h>` | String | 字符串/内存操作：`strlen()`、`memset()`、`memcpy()` |

**两套 I/O 接口的区别**：
- **标准 I/O**（`<stdio.h>`）：`fopen`/`fread`/`fwrite` — 带缓冲，适合普通文件
- **系统 I/O**（`<fcntl.h>` + `<unistd.h>`）：`open`/`read`/`write` — 无缓冲，更底层，适合设备文件

在嵌入式 Linux 驱动开发中，通常用系统 I/O 来操作设备节点（如 `/dev/led`）。

---

### 3.4 lseek() - 移动文件指针
```c
#include <unistd.h>

off_t lseek(int fd, off_t offset, int whence);
```

**参数**：
- `fd`：文件描述符
- `offset`：偏移量
- `whence`：起始位置
  - `SEEK_SET`：文件开头
  - `SEEK_CUR`：当前位置
  - `SEEK_END`：文件末尾

**返回值**：
- 成功：新的文件偏移量
- 失败：`-1`

**示例**：
```c
// 移动到文件开头
lseek(fd, 0, SEEK_SET);

// 移动到文件末尾
lseek(fd, 0, SEEK_END);

// 获取文件大小
off_t size = lseek(fd, 0, SEEK_END);
```

---

### 3.5 实践练习
1. **练习1**：写一个程序，读取 `/etc/passwd` 文件并打印
2. **练习2**：写一个程序，复制文件（类似 `cp` 命令）
3. **练习3**：写一个程序，统计文件的行数

---

## 第4章：标准 I/O 库

### 4.1 标准 I/O vs 文件 I/O
**区别**：

| 特性 | 文件 I/O | 标准 I/O |
|------|---------|---------|
| 头文件 | `<fcntl.h>`, `<unistd.h>` | `<stdio.h>` |
| 操作对象 | 文件描述符（int） | 文件指针（FILE *） |
| 缓冲 | 无缓冲 | 有缓冲 |
| 函数 | `open/read/write/close` | `fopen/fread/fwrite/fclose` |
| 性能 | 直接系统调用 | 用户态缓冲，减少系统调用 |

**选择**：
- 设备文件（如 `/dev/fb0`）：用文件 I/O
- 普通文件：用标准 I/O（更高效）

---

### 4.2 标准 I/O 函数

#### 4.2.1 fopen() - 打开文件
```c
#include <stdio.h>

FILE *fopen(const char *pathname, const char *mode);
```

**参数**：
- `pathname`：文件路径
- `mode`：打开模式
  - `"r"`：只读
  - `"w"`：只写（清空）
  - `"a"`：追加
  - `"r+"`：读写
  - `"w+"`：读写（清空）
  - `"a+"`：读写（追加）

**返回值**：
- 成功：文件指针
- 失败：`NULL`

**示例**：
```c
FILE *fp = fopen("/tmp/test.txt", "w");
if (fp == NULL) {
    perror("fopen failed");
    return -1;
}
```

---

#### 4.2.2 fread() / fwrite() - 读写文件
```c
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
```

**参数**：
- `ptr`：缓冲区
- `size`：每个元素的大小
- `nmemb`：元素个数
- `stream`：文件指针

**返回值**：
- 成功：实际读写的元素个数
- 失败：小于 `nmemb`

**示例**：
```c
int data[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
fwrite(data, sizeof(int), 10, fp);
```

---

#### 4.2.3 fprintf() / fscanf() - 格式化读写
```c
int fprintf(FILE *stream, const char *format, ...);
int fscanf(FILE *stream, const char *format, ...);
```

**本质**：把 `printf`/`scanf` 的屏幕输入输出，改成对文件的读写。

| 你熟悉的 | 对应文件版 | 区别 |
|---------|-----------|------|
| `printf("Age: %d", 25)` → **屏幕** | `fprintf(fp, "Age: %d", 25)` → **文件** | 多了 `FILE *stream` 参数，指定输出到哪里 |
| `scanf("%d", &age)` ← **键盘** | `fscanf(fp, "%d", &age)` ← **文件** | 多了 `FILE *stream` 参数，指定从哪里读 |

**示例**：
```c
fprintf(fp, "Name: %s, Age: %d\n", "Alice", 25);

char name[32];
int age;
fscanf(fp, "Name: %s, Age: %d", name, &age);
```

**实际应用场景：保存/读取配置文件**
```c
// 保存配置到文件
FILE *fp = fopen("/mnt/config.txt", "w");
fprintf(fp, "ip=%s\n", "192.168.1.11");
fprintf(fp, "brightness=%d\n", 80);
fclose(fp);
```
生成的 `config.txt`：
```
ip=192.168.1.11
brightness=80
```

```c
// 从文件读取配置
FILE *fp = fopen("/mnt/config.txt", "r");
char ip[32];
int brightness;
fscanf(fp, "ip=%s", ip);           // 读到 "192.168.1.11"
fscanf(fp, "brightness=%d", &brightness);  // 读到 80
fclose(fp);
```

**⚠️ 注意陷阱**：`fscanf` 读字符串遇到空格会停止。如果格式对不上会解析失败。实际项目中更常用 `fgets` 逐行读然后自己解析。

---

#### 4.2.4 fgets() / fputs() - 行读写
```c
char *fgets(char *s, int size, FILE *stream);
int fputs(const char *s, FILE *stream);
```

**示例**：
```c
char line[256];
while (fgets(line, sizeof(line), fp) != NULL) {
    printf("%s", line);
}
```

---

#### 4.2.5 fclose() - 关闭文件
```c
int fclose(FILE *stream);
```

**返回值**：
- 成功：`0`
- 失败：`EOF`

---

### 4.3 完整示例：标准 I/O
```c
/**
 * @file   stdio_demo.c
 * @brief  标准 I/O 示例
 */
#include <stdio.h>

int main(void)
{
    FILE *fp;
    
    // 1. 写入文件
    fp = fopen("/tmp/test.txt", "w");
    if (fp == NULL) {
        perror("fopen failed");
        return -1;
    }
    
    fprintf(fp, "Name: Alice\n");
    fprintf(fp, "Age: 25\n");
    fprintf(fp, "City: Beijing\n");
    
    fclose(fp);
    
    // 2. 读取文件
    fp = fopen("/tmp/test.txt", "r");
    if (fp == NULL) {
        perror("fopen failed");
        return -1;
    }
    
    char line[256];
    while (fgets(line, sizeof(line), fp) != NULL) {
        printf("%s", line);
    }
    
    fclose(fp);
    
    return 0;
}
```

---

### 4.4 实践练习
1. **练习1**：用标准 I/O 实现文件复制
2. **练习2**：读取配置文件（键值对格式）
3. **练习3**：写一个简单的日志系统

---

## 第5章：ioctl 与设备控制

### 5.1 什么是 ioctl
**要点**：
- `ioctl` = I/O Control（输入输出控制）
- 用于控制设备的特殊操作（不是简单的读写）
- 常用于：
  - 获取/设置设备参数
  - 控制设备行为
  - 查询设备状态

**典型应用**：
- Framebuffer：获取屏幕分辨率、色深
- ALSA：配置音频采样率、声道数
- 串口：设置波特率、数据位

---

### 5.2 ioctl 函数原型
```c
#include <sys/ioctl.h>

int ioctl(int fd, unsigned long request, ...);
```

**参数**：
- `fd`：文件描述符
- `request`：控制命令（宏定义）
- `...`：可选参数（通常是指针）

**返回值**：
- 成功：`0` 或其他值（取决于命令）
- 失败：`-1`

---

### 5.3 示例：Framebuffer 获取屏幕信息
```c
/**
 * @file   fb_info.c
 * @brief  获取 Framebuffer 屏幕信息
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/fb.h>
#include <sys/ioctl.h>

int main(void)
{
    int fd;
    struct fb_var_screeninfo vinfo;
    
    // 1. 打开 framebuffer 设备
    fd = open("/dev/fb0", O_RDWR);
    if (fd < 0) {
        perror("open /dev/fb0 failed");
        return -1;
    }
    
    // 2. 获取屏幕信息
    if (ioctl(fd, FBIOGET_VSCREENINFO, &vinfo) < 0) {
        perror("ioctl FBIOGET_VSCREENINFO failed");
        close(fd);
        return -1;
    }
    
    // 3. 打印屏幕信息
    printf("Screen resolution: %dx%d\n", vinfo.xres, vinfo.yres);
    printf("Bits per pixel: %d\n", vinfo.bits_per_pixel);
    printf("Virtual resolution: %dx%d\n", vinfo.xres_virtual, vinfo.yres_virtual);
    
    // 4. 关闭设备
    close(fd);
    
    return 0;
}
```

**编译运行**：
```bash
arm-linux-gnueabihf-gcc fb_info.c -o fb_info
./fb_info
```

**预期输出**：
```
Screen resolution: 1024x600
Bits per pixel: 32
Virtual resolution: 1024x600
```

---

### 5.4 示例：LED 控制（自定义驱动）
假设有一个 LED 驱动，支持以下 ioctl 命令：
```c
#define LED_ON  _IO('L', 0)
#define LED_OFF _IO('L', 1)
```

**应用程序**：
```c
/**
 * @file   led_ctrl.c
 * @brief  LED 控制示例
 */
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#define LED_ON  _IO('L', 0)
#define LED_OFF _IO('L', 1)

int main(void)
{
    int fd;
    
    // 1. 打开 LED 设备
    fd = open("/dev/led", O_RDWR);
    if (fd < 0) {
        perror("open /dev/led failed");
        return -1;
    }
    
    // 2. 点亮 LED
    printf("LED ON\n");
    ioctl(fd, LED_ON);
    sleep(1);
    
    // 3. 熄灭 LED
    printf("LED OFF\n");
    ioctl(fd, LED_OFF);
    sleep(1);
    
    // 4. 关闭设备
    close(fd);
    
    return 0;
}
```

---

### 5.5 ioctl 命令定义
**宏定义**：
```c
#include <asm/ioctl.h>

_IO(type, nr)           // 无参数
_IOR(type, nr, size)    // 读取数据
_IOW(type, nr, size)    // 写入数据
_IOWR(type, nr, size)   // 读写数据
```

**参数**：
- `type`：设备类型（魔数，通常是字符）
- `nr`：命令编号
- `size`：数据类型大小

**示例**：
```c
#define FBIOGET_VSCREENINFO  _IOR('F', 0x01, struct fb_var_screeninfo)
#define FBIOPUT_VSCREENINFO  _IOW('F', 0x02, struct fb_var_screeninfo)
```

---

### 5.6 实践练习
1. **练习1**：读取 Framebuffer 信息并打印
2. **练习2**：如果有 LED 驱动，写程序控制 LED 闪烁
3. **练习3**：查看 `/dev/` 目录下的设备文件，尝试用 `ioctl` 获取信息

---

## 补充知识

### 附1：栈内存 vs 堆内存

操作系统下，内存资源由操作系统管理和分配。当应用程序需要堆内存时，可以向操作系统申请，用完后再释放归还。

| 对比项 | 栈（Stack） | 堆（Heap） |
|--------|------------|-----------|
| 申请方式 | 自动（声明变量就有了） | 手动（`malloc`） |
| 释放方式 | 自动（函数返回自动释放） | 手动（`free`，忘了就内存泄漏） |
| 大小限制 | 小（一般几MB） | 大（受物理内存限制） |
| 速度 | 快 | 相对慢 |
| 生命周期 | 函数内有效 | `free` 前一直有效 |

**直观对比**：
```c
void func(void)
{
    // ===== 栈内存 =====
    int a = 10;           // 在栈上，函数返回后自动消失
    char buf[64];         // 在栈上，固定大小，必须编译时确定

    // ===== 堆内存 =====
    char *p = malloc(64); // 在堆上，函数返回后依然存在，直到 free
    free(p);              // 必须手动释放
}
```

**什么时候用堆？**

1. **大小在运行时才知道**
```c
int n;
scanf("%d", &n);
int *arr = malloc(n * sizeof(int));  // 栈上做不到
```

2. **数据需要跨函数存活**
```c
char *create_buffer(void)
{
    char *buf = malloc(1024);
    return buf;          // 可以！堆内存函数返回后还在

    // 千万别这样：
    // char buf[1024];
    // return buf;       // 错！栈内存函数返回就没了，返回野指针
}
```

3. **嵌入式 Linux 中的实际例子**
```c
// 读文件时不知道文件多大，动态申请
FILE *fp = fopen("/dev/sensor", "r");
fseek(fp, 0, SEEK_END);     // 把读写位置移到文件末尾
long size = ftell(fp);      // 获取当前位置（即文件总大小）

char *data = malloc(size);  // 按实际大小申请堆内存
fread(data, 1, size, fp);   // 把文件内容读进堆内存
// ... 处理数据 ...
free(data);                 // 用完释放，归还给操作系统
```

**逐行解释 `fseek` + `ftell` + `malloc` 这段代码**：

```c
fseek(fp, 0, SEEK_END);
```
把文件指针移到**文件末尾**。`fseek(文件指针, 偏移量, 起始位置)`，`SEEK_END` 表示从末尾开始算，偏移 0 就是正好在末尾。

```c
long size = ftell(fp);
```
`ftell` 返回当前位置距离文件开头有多少字节。此时位置在末尾，所以 `size` = **文件总大小**。

```c
char *data = malloc(size);
```
按文件大小动态申请堆内存，刚好能装下整个文件。

```c
fread(data, 1, size, fp);
```
把文件内容读到 `data` 里。`fread(缓冲区, 每块大小, 块数, 文件指针)`，这里每块 1 字节，读 `size` 块，就是读整个文件。

```c
free(data);
```
用完释放内存，归还给操作系统。

**整体流程**：
```
fopen → fseek到末尾 → ftell获取大小 → malloc申请内存 → fread读内容 → free释放
```

> **记住一句话**：栈像餐厅托盘——用完自动回收；堆像你借的碗——必须自己还，不还就泄漏了。
> 在嵌入式 Linux 中 `malloc` 和 `free` 必须成对出现，否则设备长时间运行会耗尽内存崩溃。

---

## 学习建议

### 1. 学习顺序
```
第1章（1天）→ 第2章（2天）→ 第3章（3天）→ 第4章（2天）→ 第5章（2天）
```

### 2. 实践为主
- 每个示例代码都要自己敲一遍
- 在开发板上运行验证
- 遇到问题先自己调试，再查资料

### 3. 重点掌握
- **第2章**：交叉编译环境（必须搭建成功）
- **第3章**：文件 I/O（后续音视频开发的基础）
- **第5章**：ioctl（设备控制的核心）

### 4. 配合练习
- 每章结束后做练习题
- 尝试修改示例代码，观察结果
- 写一些小工具（如文件复制、文本统计）

### 5. 遇到问题
- 查看错误信息（`perror`、`strerror`）
- 使用 `man` 命令查看函数手册（如 `man 2 open`）
- 参考正点原子论坛、CSDN、Stack Overflow

---

## 下一步

学完前 5 章后，你应该能够：
- ✅ 搭建交叉编译环境
- ✅ 编写简单的 Linux C 程序
- ✅ 使用文件 I/O 读写文件
- ✅ 使用 ioctl 控制设备

**接下来可以**：
1. 继续学习《Linux C应用编程指南》后续章节（多线程、网络编程）
2. 开始学习《Linux驱动开发指南》的 Framebuffer 和 ALSA 章节
3. 尝试做一个简单的音频播放器（播放 WAV 文件）

---

## 参考资源

- 正点原子官方论坛：`http://www.openedv.com/forum.php`
- Linux man 手册：`man 2 open`（系统调用）、`man 3 fopen`（库函数）
- 在线 man 手册：`https://man7.org/linux/man-pages/`
