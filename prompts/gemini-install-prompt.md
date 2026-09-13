# Gemini CLI 用インストールプロンプト

以下を Gemini CLI にそのまま貼り付ける。

```text
次のリポジトリに含まれる3つの Agent Skill を、Gemini CLI のユーザースコープへインストールしてください。

Repository:
https://github.com/takaoumehara/interactive-experience-skills

要件:
- 一時ディレクトリへ main ブランチを clone または pull する。
- 実行前に LICENSE、各 SKILL.md、インストール対象の .skill archive を確認する。
- Gemini CLI 公式の `gemini skills install <local .skill package>` を使い、次をユーザースコープへインストールする:
  - embodied-product-director.skill
  - interactive-experience-collective.skill
  - movement-learning-system-designer.skill
- 既に同名 Skill がある場合は、現在の配置先と更新方法を確認し、この3 Skillだけを更新する。他の Skill は変更しない。
- `gemini skills list` で3 Skillが発見されることを確認する。
- interactive-experience-collective に realtime-3d-pipeline.md が含まれることを確認する。
- 可能なら `/skills reload`、できなければ新しいセッションを開始する必要があると報告する。
- 最後に、配置先、導入した version、検証結果を報告する。
```

Gemini CLI は user Skill として `~/.gemini/skills/` または `~/.agents/skills/` を探索する。開発中のローカルフォルダを使う場合は `gemini skills link <path>` も利用できるが、この配布版は `.skill` archive の install を優先する。
