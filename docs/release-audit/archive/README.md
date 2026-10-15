# Archive: older audit material and retired branches

Kept here so the old GitHub branches could be deleted without losing anything. Nothing in this folder is used by the app or the build.

| Item | What it is |
|---|---|
| `mobile-audit-source-only/` | The first source-only Android audit of Pagemark (0.7.x era) made with the mobile-audit skill: `REPORT.md`, `coverage.md` and 8 findings (`MOB-SEC-0001`, `MOB-CRY-0002`, `MOB-BLD-0004`, `MOB-SEC-0005`, `MOB-PRV-0003`, `MOB-PRV-0006`, `MOB-SEC-0008`, `MOB-STORE-0007`). Came from branch `branch/inspiring-franklin-sawwzg` (draft PR #1). The findings were handled in later releases; the current audits are in the folder above. |
| `mobile-audit.skill` | The packaged mobile-audit skill (a zip; install by unzipping into `~/.claude/skills/`). |
| `old-branch-patches/apk-0.4.2.patch` | 0.4.2 patch work (locked-library Trash, PIN note after restore, search ranking). Already in `main`. Tip was `15ba123`. |
| `old-branch-patches/play-store-prep.patch` | First Play build flavor, privacy policy and Play guide. Already in `main`. Tip was `d48582f`. |
| `old-branch-patches/Pagemark-Google_play.patch` | Early Drive-to-folder backup rewrite and Play roadmap. Replaced by the folder backup in `main` (`lib/folder_backup.dart`). Tip was `71ab8f4`. |

`Pagemark-APK` (this branch) was previously an old pointer to a roadmap commit (`5eeb2a0`); it now carries current `main` plus this archive.

Apply a patch to look at it: `git apply --stat old-branch-patches/<name>.patch`.
