# MoonPDB 项目申报书

## 基本信息

- 项目名称：MoonPDB
- 参赛者：LC6543
- 邮箱：2735527267@qq.com
- GitHub：https://github.com/LC6543
- 仓库：https://github.com/LC6543/moonpdb
- 项目方向：语言和开发工具 / 调试信息与二进制基础设施
- 项目性质：依据公开的 Microsoft PDB 7.0 / MSF 格式原创实现
- 许可证：Apache-2.0

## 项目简介

MoonPDB 为 MoonBit 提供纯 MoonBit 的 Windows PDB 7.0 调试信息读取能力。它面向需要在非 Windows 主程序、CI 服务、崩溃分析工具或 MoonBit 自建调试工具中读取 Windows 符号的开发者，目标是让 PDB 不再只能通过 Windows SDK、DIA 或 C++ 库访问。

PDB 文件不是简单的记录流。外层是 MSF 容器，内部有 stream directory、PDB Info、TPI/IPI、DBI、模块信息和符号流。MoonPDB 按这些层逐步实现，所有读取都带边界、数量和内存上限，适合处理不可信的构建产物。

## 生态缺口

截至 2026-10-18，Mooncakes 查重结果：

- `moon search moonpdb`：没有同名模块。
- `moon search "moon-pdb"`：没有结果。
- `moon search pdb7`：没有结果。
- `moon view LC6543/moonpdb`：registry 返回 404，名称未被占用。
- `moon search "program database"`：没有 PDB 格式实现。

现有 MoonBit 项目中有 DWARF、ELF、BAP 和数据库接口，但没有 Microsoft PDB 读取器。PDB 与 DWARF 是不同格式，本项目不会重复或修改这些项目。

## 三个使用场景

1. Windows 崩溃定位：CI 或服务端拿到 minidump 和 PDB 后，把地址映射到函数、源文件和行号。
2. 构建产物审计：检查 PDB 与 PE 的 GUID/年龄是否匹配，统计模块、符号和源码路径，作为发布门禁的一部分。
3. 调试器与编辑工具：为 MoonBit 编写的调试前端、符号浏览器或代码导航工具提供可复用的 PDB 数据层。

## 核心功能与交付边界

计划交付：

- MSF superblock、block map、stream directory 和有界 stream 读取；
- PDB Info stream、named stream map 和 GUID/age；
- TPI/IPI type records 及常见类型字段解析；
- DBI module list、public/global symbol streams 和 line tables；
- 地址到函数、源文件和行号的符号化 API；
- 可选原生 CLI，用于检查、列出和导出摘要；
- 测试夹具、畸形输入测试、互操作验证、README、CI 和 Mooncakes 发布。

明确不做：

- ELF、DWARF、Mach-O 或 PE 的完整解析器；
- 反汇编、反编译和调试器 UI；
- 修改 PDB 或生成 PDB；
- 连接符号服务器和实现认证协议；
- 在首版实现全部 CodeView 记录语义。

## 技术路线

先实现纯函数、无 I/O 的 MSF 层，输入字节和限制参数，输出可查询的 stream 目录。后续层复用同一套边界读取器，避免每一层各自做不安全的整数和长度处理。所有 block index、stream size 和目录长度在分配前验证；对循环引用、过大元素数和截断输入返回结构化错误。

测试分三层：手工构造的 MSF 夹具、畸形输入和边界测试、真实 Windows PDB 的互操作测试。格式参考 LLVM 的 PDB/MSF 文档和 Microsoft 公开的 microsoft-pdb 样例，仓库中记录来源与许可证。

## 当前阶段

本次申报对应初审版本：完成独立工程、MSF 容器解析、stream directory、PDB Info stream、命名 stream map 和基础测试。TPI、DBI、符号解析和 CLI 作为后续里程碑逐步提交。
