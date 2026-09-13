# Claude Code 用インストールプロンプト

以下を Claude Code にそのまま貼り付ける。

```text
次のリポジトリに含まれる3つの Agent Skill と付属コマンドを、このユーザーの Claude Code にインストールしてください。

Repository:
https://github.com/takaoumehara/interactive-experience-skills

要件:
- 一時ディレクトリへ main ブランチを clone または pull する。
- 実行前に LICENSE、install.sh、各 SKILL.md を確認する。
- リポジトリ付属の ./install.sh を実行する。
- 上書き対象は、このリポジトリと同名の3 Skillと4コマンドだけに限定する。
- ~/.claude/skills/ の次の3ディレクトリを確認する:
  - embodied-product-director
  - interactive-experience-collective
  - movement-learning-system-designer
- ~/.claude/commands/ の motion-idea、refresh-skills、scout-skills、skills-routine を確認する。
- interactive-experience-collective/references/realtime-3d-pipeline.md が存在することを確認する。
- SKILL.md が参照する references/*.md と assets/*.md に参照切れがないことを確認する。
- 最後に、配置先、導入した version、検証結果、新しいセッションが必要かを報告する。
```

Claude.ai ではプロンプトによるローカル配置ではなく、`dist/*.zip` を **Customize → Skills → Upload a skill** からアップロードする。
