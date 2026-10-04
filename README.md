# AI 个人形象管理顾问（Personal Stylist）

基于通用形象科学（AIS：色彩 / 线条 / 场合 / 衣橱系统）的个人形象管理 dsh 智能体预设。

**核心**：服装档案 × 顾客档案 → 3 套搭配方案 + 审美理由 + 品牌语境话术。

## 结构

```
preset/               # dsh 预设（安装目标 ~/.dsh/.agent-presets/personal-stylist/）
  agent.cordis.yml    # 预设定义（插件 + persona + 工具层）
  preset.yml          # 预设元数据
  plugins/stylist-core/  # 核心插件（641 行：服装档案/顾客档案/匹配方案/反馈闭环）
  skills/
    stylist-kb/       # 规则库（SKILL.md + workflow.md）
    always-in-style/  # AIS 知识库（《与纽约形象大师对话》提炼）
install/install.sh    # 一键部署（--workdir 自定义 + WORKSPACE 自动重写）
data/                 # 数据目录骨架（customers/plans/feedback/garments）
docs/                 # 设计文档
```

## 安装

```bash
./install/install.sh                    # 默认工作目录 /Users/mac/Desktop/个人形象管理
./install/install.sh --workdir /path    # 自定义工作目录（自动重写 WORKSPACE）
./install/install.sh --preset-only      # 只装 dsh 预设
```

## 数据层

- 服装档案：`<workdir>/data/garments/<item_id>.json`（CAO 写，Stylist 读）
- 顾客档案：`<workdir>/data/customers/<customer_id>.json`
- 匹配方案：`<workdir>/data/plans/PLAN-*.json`
- 反馈闭环：`<workdir>/data/feedback/<item_id>.feedback.json`

## 美学内核

通用形象科学（AIS, Always In Style）：
- 6 型色彩系统（冷暖/净柔/深浅）
- 身体线条与服装线条匹配
- 场合 × 衣橱规划（商务/休闲/社交/约会）
