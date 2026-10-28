# MoonPDB 项目申报书

## 基本信息

- 项目名称：MoonPDB
- 参赛者：LC6543
- 邮箱：2735527267@qq.com
- GitHub：https://github.com/LC6543
- 仓库：https://github.com/LC6543/moonpdb
- Mooncakes：LC6543/moonpdb
- 项目方向：语言和开发工具 / 调试信息与二进制基础设施
- 许可证：Apache-2.0

## 最终目标

MoonPDB 的最终目标是提供一个纯 MoonBit、只读、资源有界的完整 Microsoft PDB 7.0
核心格式读取器。完整兼容指：合法 PDB 7.0 的 MSF 容器、PDB Info、TPI/IPI、DBI、
模块流、public/global 符号、CodeView 符号和行号流均可被定位和有界读取；已支持的
记录给出类型化语义，未知或扩展记录保留原始字节和错误原因，不静默丢失。

项目面向 CI、崩溃分析、构建审计和 MoonBit 调试工具。PDB 与 DWARF 是不同格式；
Mooncakes 已有 DWARF、ELF 和数据库接口，但没有 Microsoft PDB 7.0 读取器。本项目是
新工程，不维护、不修改也不重复上述项目。

## 已完成的现有基础

- 已发布 `LC6543/moonpdb@0.1.0`：MSF superblock、block map、stream directory、
  PDB Info、GUID/age、named streams 和 feature codes。
- 当前有效源码约 8,800 行、测试约 2,400 行；`moon check --deny-warn` 和
  `moon test --deny-warn` 通过，现有 52 个测试。
- 已配置 GitHub Actions、Apache-2.0、README、安全策略、贡献指南和版本记录。

## 本轮新增与后续里程碑

1. TPI/IPI：56 字节头部、类型索引范围、记录框架、simple type、modifier、pointer、
   procedure、member function、arglist、bitfield、array、class/struct/interface、
   union、enum、alias、label、function/member/string ID、build info、UDT source line、
   type server 和未知记录保留；field-list 子记录在下一功能中类型化。
2. 已完成 DBI 头、模块列表、section contributions、section map、文件信息、EC 子流和
   可选调试头；后续补模块调试流中的符号与行号语义。
3. 已完成符号记录框架、模块调试流，以及 `S_PUB32`、`S_GDATA32`、`S_LDATA32`、
   `S_GPROC32`、`S_LPROC32`、`S_THUNK32`、`S_BLOCK32`、`S_LABEL32`、`S_CONSTANT`、
   `S_UDT`、`S_PROCREF`、`S_FRAMEPROC` 和 `S_END`；Publics 头、GSI 头与桶、
   address map、thunk map、section offsets、最近 public 地址查询和 Globals
   名称哈希查询也已完成；inline site 等复杂记录先保真读取。
4. 已完成 C13 子段框架、string table、文件校验和、行/列记录及 segment+offset
   到源码路径和行号的基础映射。
5. 已完成 PE32/PE32+ 头、image base、section table 和 segment+offset→RVA/VA 映射；
   统一符号化结果可同时返回最近 public symbol、section、源码路径、行号和列号。
   明确不宣称寄存器、局部变量、栈回溯、内联帧展开或反编译。
6. 工具与验收：只读 CLI、真实 PDB 夹具、畸形输入测试、Mooncakes 发布、可复现 CI。

## 技术路线与边界

所有层接收 `Bytes` 和显式限制，先验证偏移、数量、乘加溢出和分配上限，再读取数据。
记录编号与 TPI/IPI 声明范围交叉校验；未知 leaf 保留原始 payload；已知但截断的记录
返回结构化错误。测试覆盖合成合法输入、截断/越界/资源上限输入和真实 PDB 互操作。

不做：PDB 写入或生成、反汇编/反编译、调试器 UI、符号服务器认证，以及完整的
ELF/DWARF/Mach-O/PE 解析器；PE 仅用于 image base 和 section 地址映射。格式资料来自
Microsoft `microsoft-pdb` 公开头和 LLVM CodeView 文档，仓库持续记录来源与许可证。

## 当前申报状态

本轮重点回应初审反馈：把完整 PDB 7.0 兼容拆成可验收的层和记录清单，并将有效源码从
约 700 行扩展到约 8,800 行，新增 TPI/IPI、DBI、CodeView 符号、Publics、
Globals 名称索引、C13 行号、PE RVA 映射和统一符号化层。后续按一个功能一个提交
继续实现 CLI 与真实 PDB/PE 互操作验收。
