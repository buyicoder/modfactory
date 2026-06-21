# ModFactory —— Minecraft 模组工业革命

```
███╗   ███╗  ██████╗  ██████╗
████╗ ████║ ██╔═══██╗ ██╔══██╗
██╔████╔██║ ██║   ██║ ██║  ██║     ← 模块 · 轻量 · 精准
██║╚██╔╝██║ ██║   ██║ ██║  ██║
██║ ╚═╝ ██║ ╚██████╔╝ ██████╔╝
╚═╝     ╚═╝  ╚═════╝  ╚═════╝

███████╗  █████╗   ██████╗ ████████╗  ██████╗  ██████╗  ██╗   ██╗
██╔════╝ ██╔══██╗ ██╔════╝ ╚══██╔══╝ ██╔═══██╗ ██╔══██╗ ╚██╗ ██╔╝
█████╗   ███████║ ██║         ██║    ██║   ██║ ██████╔╝  ╚████╔╝   ← 工厂 · 厚重 · 工业化
██╔══╝   ██╔══██║ ██║         ██║    ██║   ██║ ██╔══██╗   ╚██╔╝
██║      ██║  ██║ ╚██████╗    ██║    ╚██████╔╝ ██║  ██║    ██║
╚═╝      ╚═╝  ╚═╝  ╚═════╝    ╚═╝     ╚═════╝  ╚═╝  ╚═╝    ╚═╝
```

> 平台无关的 Minecraft 游戏体验工厂。用一句话生成可编译、可运行的完整模组。

ModFactory 不是"帮你写代码的工具"。它是一个完整的**模组生产流水线**——从玩家体验设计出发，协调纹理引擎、领域模块、资产服务、Fabric 工程、整合包集成、合约校验与 QA 门控，输出或集成完整可验证的游戏体验。


## 快速开始

在你的 AI Agent 中使用对应的适配器：

**Claude Code：**

```
/mc-mod-master 创建一把能召唤闪电的红宝石剑
```

**Cursor / 通用 Agent：** 从 `adapters/` 目录开始，阅读对应的适配器指引。

主控 Skill 会自动完成五步：

1. 解析你意图中的玩家体验目标
2. 选择运作模式：**原创设计** / **整合包作者** / **专注模组**
3. 选定所需的领域模块和共享资产服务
4. 产出或集成受合约约束的资产、代码、配置与资源
5. 在构建和运行时验证之前执行闭包检查


## 核心哲学

### 为什么 ModFactory 和别的工具不同？

传统的 MC 模组工具是"代码生成器"——你告诉它你要一把剑，它给你一个 Java 文件。但一把真正的红宝石剑，需要的不只是代码：

- **纹理**：16×16 PNG，程序化逐像素生成，不是复制粘贴
- **模型**：物品模型 JSON + 手持变换 + Blockbench 3D 模型
- **配方**：合成配方 JSON（有序/无序/锻造/切石）
- **战利品表**：怪物掉落/宝箱/钓鱼/礼物
- **注册**：物品注册 + 创造模式标签页 + 语言翻译
- **平衡性**：伤害/攻速/耐久/附魔能力 = 钻石级？下界合金级？

ModFactory 把这一整套流程自动化了。你说的只是一句"红宝石剑"，它做的是从创意到可运行的完整链条。

### 三个运作模式

| 模式 | 适用场景 | 例子 |
|------|----------|------|
| **原创设计** | 创造全新的游戏系统 | 战斗进阶（武器→护甲→Boss→掉落→状态效果）、科技线（机器→自动化→资源→配方→终局）、魔法线（魔力→仪式→触媒→解锁） |
| **整合包作者** | 用已有模组组合成统一体验 | 幻想主题包、科技空岛、魔法冒险——ModFactory 帮你发现冲突、分配系统所有权、规划 config/数据包/脚本 |
| **专注模组** | 只做一件事，做好 | 一把雷击剑、一个新生物、一种新材料、一个 GUI |

## 架构总览

```
mc-mod-master（总调度 Skill）
│
├── experience director      ← 体验导演：选定运作模式，定义玩家旅程
├── project mode router      ← 模式路由：原创/整合包/专注
│
├── 领域模块（6 个）
│   ├── entity module         ← 实体：生物/Boss/宠物/坐骑/弹射物
│   ├── item module           ← 物品：工具/武器/护甲/食物/特殊道具
│   ├── block module          ← 方块：自定义硬度/光照/碰撞箱/掉落
│   ├── gameplay module       ← 玩法：技能/职业/属性/任务/成就
│   ├── worldgen module       ← 世界生成：矿物/结构/群系
│   └── network module        ← 网络：Payload 数据包 S2C/C2S
│
├── 共享资产服务
│   ├── asset source          ← 资产来源决策（GearFactory / AI / 手动）
│   ├── texture material      ← 纹理材质：20 色板 × 6 形状
│   ├── model rig             ← 模型骨架：Blockbench 集成
│   ├── animation             ← 动画制作：Blockbench MCP 驱动
│   └── technical art         ← 技术美术：渲染/粒子/着色器
│
├── Fabric 工程层             ← 1.21.11 Gradle 工程 + Java 21+
├── 整合包集成                ← 兼容性图 + 冲突分析
├── contracts                 ← 8 种合约类型（资产/架构/配方/战利品/实体/方块/物品/QA）
└── QA gates                  ← 15 条规则跨验证 + 22 种编译错误自动修复
```


## Skills 全景（25 个）

### 调度层

| Skill | 功能 |
|-------|------|
| `mc-mod-master` | 主控调度：需求拆解 → 任务编排 → 子 Skill 派遣 → 质量门控 |
| `experience-director` | 体验导演：选定运作模式、定义玩家旅程、划分系统模块 |

### 设计层

| Skill | 功能 |
|-------|------|
| `entity-designer` | 实体设计师：代码前的 9 段式蓝图（概念→视觉→战斗→行为→生成→掉落→音效→模型→清单） |
| `entity-design-expert` | 实体设计专家：协调 12+ 合作方，强制执行资产合约 |
| `appearance-designer` | 外观设计师：形状到模板的决策引擎，杜绝不合理映射 |

### 生成层——物品/方块/实体/玩法

| Skill | 功能 |
|-------|------|
| `texture-generator` | 纹理生成器：GearFactory 引擎（20 色板 × 6 形状），输出逐像素 PNG |
| `texture-ai-generator` | AI 纹理生成器：minecraft-ai / Pixel GPT / Deep Pixels |
| `item-generator` | 物品生成器：工具、护甲、食物、特殊物品，5 种架构模式 |
| `block-generator` | 方块生成器：BlockItem 联动、blockstate、模型 JSON |
| `entity-generator` | 实体生成器：1.21.11 RenderState API，敌对/Boss/宠物/坐骑 |
| `gameplay-generator` | 玩法生成器：技能系统、Buff/Debuff、职业属性 |
| `loot-generator` | 战利品表生成器：方块/实体掉落/宝箱/钓鱼/礼物 |
| `recipe-generator` | 配方生成器：有序/无序合成、熔炼、锻造、切石、营火 |
| `worldgen-generator` | 世界生成器：矿物生成、结构生成、生物群系修改 |
| `gui-generator` | GUI 生成器：ScreenHandler + Screen + BlockEntity 桥接 |
| `command-generator` | 命令生成器：Brigadier 注册，12 种参数类型 |
| `datagen-generator` | 数据生成器：Model/Recipe/LootTable/Tag/Language Provider |
| `network-generator` | 网络生成器：Payload 数据包系统（S2C + C2S） |
| `mixin-generator` | Mixin 生成器：@Inject/@ModifyArg/@Redirect/@Accessor/@Invoker |

### 资产层

| Skill | 功能 |
|-------|------|
| `blockbench-animator` | Blockbench 动画师：MCP 驱动的实体动画创作 |

### 分析与 QA 层

| Skill | 功能 |
|-------|------|
| `mod-analyzer` | Mod 分析师：逆向经典模组提取架构模式（5 个知识库） |
| `integrity-checker` | 完整性校验器：15 条规则跨验证，PASS/WARNING/FAIL 报告 |
| `auto-fix` | 自动修复引擎：22 种编译错误模式匹配 + 5 次迭代修复闭环 |
| `conflict-expert` | 冲突专家：依赖/版本/运行时冲突/性能风险分析 |
| `fabric-mc-mod-development` | 知识库：Yarn↔Mojang 映射表、1.21.11 API 差异速查 |


## 实体管线——从创意到可运行的闭环

ModFactory 提供业内最完整的实体生产管线：

```
点子 → 设计蓝图 → Blockbench 资产 → 资产合约 → Fabric 代码 → 完整性校验 → 构建 → runClient QA
```

1. **点子阶段**：你说"一个能用闪电攻击的铁傀儡变种"
2. **设计蓝图**：9 段式实体设计文档（概念/视觉/战斗/行为/生成/掉落/音效/模型/清单）
3. **Blockbench 资产**：MCP 驱动自动创建模型、动画、纹理
4. **资产合约**：JSON 合约锁定模型路径、纹理尺寸、动画帧数
5. **Fabric 代码**：EntityType 注册 → Entity 类 → Renderer → Model → Spawn Egg → 战利品表
6. **完整性校验**：15 条规则跨验证（纹理是否存在？模型路径是否匹配？注册是否完整？）
7. **构建**：`./gradlew build`
8. **runClient QA**：自动启动游戏验证，截图、日志、性能数据

参见 `docs/entity-pipeline.md` 和 `docs/artifact-contracts.md`。


## 纹理引擎——GearFactory

ModFactory 的纹理不是从网上下载的，是**程序化逐像素生成的**。

```
forge_engine/
├── forge.ps1         ← 主引擎：色板 × 形状 → 16×16 PNG
├── palettes.json      ← 20 种色板：红宝石、蓝宝石、暗铁、雷击……
├── templates/         ← 形状模板：剑/镐/斧/锄/铲/头盔/胸甲/护腿/靴子
└── output/            ← 生成的纹理 PNG
```

**使用方法：**

```powershell
# 生成全套红宝石装备纹理
./forge.ps1 -PaletteName ruby -Shape vanilla -ItemName all

# 只生成剑
./forge.ps1 -PaletteName thunder -Shape vanilla -ItemName sword
```

生成的 PNG 直接输出到 `fabric-mod-dev/src/main/resources/assets/modid/textures/`，和 Java 代码无缝对接。

这不是手绘。不是 AI 生成。不是复制粘贴。**每一像素都是代码算出来的。** 这是 modfactory 区别于所有其他 MC 工具的核心差异化。


## 已有成果——Ruby & Thunder 模组

当前仓库里的 `fabric-mod-dev/` 包含一个完整可运行的模组，展示了 ModFactory 的生产能力：

| 内容 | 详情 |
|------|------|
| 红宝石工具 | 剑、镐、斧、锄、铲 |
| 红宝石护甲 | 头盔、胸甲、护腿、靴子 |
| 红宝石苹果 | 食物 + 特殊效果 |
| 雷击剑 | 100% 触发闪电（可配置概率） |
| 雷击碎片 | 合成材料 |
| 暗铁锭/核心 | 新材料 |
| 暗铁傀儡 | 自定义实体 + 刷怪蛋 |
| 雷击矿/红宝石矿 | 世界生成矿物 |

**全部纹理均由 forge_engine 程序化生成。全部代码均由 ModFactory 的 Skill 体系生成。全部模型均通过 Blockbench MCP 集成创建。**


## 整合包创作

ModFactory 不仅做模组，也能设计和验证整合包：

```
幻想主题 → 模组发现 → 兼容性图 → 冲突分析 → 集成方案 → 启动 QA
```

详见 `docs/modpack-authoring.md`。


## 开发阶段

| 阶段 | 覆盖范围 | 状态 |
|------|----------|------|
| Phase 1 | master, texture, item, block | ✅ V1.0（已完成） |
| Phase 2 | entity（设计→资产→代码→QA 完整闭环） | ✅ 活跃（暗铁傀儡已实现） |
| Phase 3 | gameplay（技能/职业/属性系统） | 🔧 开发中 |
| Phase 4 | worldgen, structure, quest | 📋 计划中 |


## 环境要求

- **AI Agent**：Claude Code / Cursor / 通用 Agent（能读写文件、执行命令）
- **Java 21+**：Minecraft 1.21.11 运行环境
- **Node.js 18+**：MCP 服务运行环境
- **Blockbench**：3D 模型编辑器（可选，实体管线需要）
- **PowerShell**：纹理引擎运行环境


## 安装

```bash
# 一键安装（安装 MCP 服务 + 克隆 GearFactory + 配置 Claude Code）
install.bat

# 或手动安装
npm install -g @mcdxai/minecraft-dev-mcp    # MC 源码实时访问
npm install -g mcmodding-mcp                # Fabric 官方文档检索
git clone https://github.com/buyicoder/GearFactory.git forge_engine
```

安装后在 Claude Code 中直接使用 `/mc-mod-master` 即可触发。


## 核心设计文档

平台无关的核心文档在 `core/` 目录：

| 文件 | 内容 |
|------|------|
| `core/positioning.md` | 产品定位与核心原则 |
| `core/architecture.md` | 工作室级分层架构 |
| `core/contracts.md` | 8 种合约类型定义 |
| `core/specialists/registry.md` | 25 个专家角色注册表 |
| `core/workflows/` | 核心工作流 |

历史文档与实现笔记在 `docs/`。


## 许可

MIT License

---

**ModFactory 不是"让 AI 帮你写几个 Java 文件"。它是 Minecraft 模组开发的生产力革命。从一句话到一套完整的游戏体验，全程自动化、合约化、可验证。**
