# Work Report Skill

Generate daily and weekly work reports from git activity across multiple repositories.

## Install

Option 1: clone the repo into your Codex skills directory:

```
git clone https://github.com/<owner>/work-report.git ~/.codex/skills/work-report
```

Option 2: download the release `.skill` and unzip it into `~/.codex/skills`:

```
unzip work-report.skill -d ~/.codex/skills
```

Restart Codex after installation.

## Configure

By default the script scans `/Users/leo/tk.com`. Override with `--root` or edit
`scripts/git_today_commits.sh` to set your preferred root path.

## Usage

In Codex, ask for:

- Daily report: `日报` or `发日报`
- Weekly report: `周报` or `发周报`

Script usage:

```
scripts/git_today_commits.sh --root /path/to/repos --period daily --group-by-repo
```

## Output format

Daily:

```
MM.DD 今日工作总结
<项目A>
1.<item>
2.<item>
```

Weekly:

```
MM.DD-MM.DD 本周工作总结
<项目A>
1.<item>
2.<item>
```

## License

MIT
