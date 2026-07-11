# Centile — Forest / Dissected Tree / Plan UI-UX Overhaul Plan

Planning document. No code written. Scope: mobile portrait only, three screens + gamification surfacing. Palette/tokens fixed (`lib/core/theme/theme.dart`).

Screen → file map (confirmed by reading source):

| User term | Screen | File | Entry |
|---|---|---|---|
| Plan page | `StrategyScreen` | `lib/screens/strategy/strategy_screen.dart:19` | Bottom-nav "Plan" tab, "Strategy" segment (`lib/main.dart:189`, `:297`) |
| Forest page | `GoalDetailScreen` | `lib/screens/strategy/goal_detail_screen.dart:14` | Pushed from Plan → Goal Anchor card (`strategy_screen.dart:96`) |
| Dissected Tree page | `FactorDetailScreen` | `lib/screens/strategy/factor_detail_screen.dart:14` | Pushed from Forest tree tap (`goal_detail_screen.dart:153`) or Plan factor chip (`strategy_screen.dart:213`) |

---

## 1. Current state audit

### 1.1 Plan page — `StrategyScreen`

- `CustomScrollView` with 5 slivers: header, goal, factors (conditional on `activeGoal`), time, sprint (`strategy_screen.dart:27-37`).
- Header: plain `displayMedium` "Strategy" + muted subtitle (`:43-65`). No gamification, no progress, no greeting.
- Goal Anchor: single `GlassCard`, `highlighted: true`, shows title + days remaining + "Tap to view forest →" (`:94-156`). If no goal, an add-row card (`:78-92`).
- Active Focus section: header counts `(n/2)` (`:169-176`); each active factor rendered as `FactorHealthTree` inside a `Stack` with a top-right "Pause" pill (`:205-272`).
- Dissected Trees section: dormant factors in a hand-built 2-column `Row` loop of `_DormantFactorChip` (`:342-382`); chips are name + emoji only, no level/health.
- Time Defense: gradient budget card + 4 radio rows for `TimeAvailability` (`:437-613`).
- Sprint goals: two sections (30-day, 14-day), each a list of `_SprintGoalCard` (`:615-698`, card body `:1245-1519`).
- `_SectionHeader` is a *third* private copy of a section-header pattern (`:1156-1206`); two more exist in the other two screens.

### 1.2 Forest page — `GoalDetailScreen`

- `SingleChildScrollView`, `Column`, center-aligned, 20px padding (`goal_detail_screen.dart:68-71`).
- Days-remaining pill (`:74-105`), "🌳 Your Forest" emoji-heading (`:110-117`), "`{n} trees planted`" (`:119-122`).
- `ForestPlatform` — isometric painted platform, fixed height 180 (`:149-161`).
- Empty state when no factors: surface card with 🌱 (`:125-147`).
- Statistics: emoji heading + 3 rows × 2 `_StatCard` = 6 cards (Trees, Effort, Health, Tasks, Habits, Reflects) (`:166-235`, card `:369-411`).
- Tree breakdown: "🔥 Active Focus" + "💤 Dissected" `_TreeChip` wraps (`:240-270`).
- Edit goal via app-bar pencil → bottom sheet (`:281-366`).

### 1.3 Dissected Tree page — `FactorDetailScreen`

- `SingleChildScrollView`, `Column`, 20px padding (`factor_detail_screen.dart:114-118`).
- `TreePlatform` hero card (`:120-130`; widget `tree_platform.dart:11-352`): level header `Lv → Lv+1` (`:60-90`), progress bar, tree PNG asset with emoji fallback (`:149-172`), stage pill, 4-stat effort row (`:208-247`), italic quote (`:251-266`).
- Gap Analysis `GlassCard`: Target / Current / Gap number trio (`:135-277`).
- Focus Status `GlassCard`: emoji + Active/Dormant + activate/deactivate button (`:282-402`).
- Level Criteria: two `GlassCard`s — target description, current description (`:405-503`).
- Work History: 3 `_StatChip`s + linked tasks/habits/reflections lists (`:508-605`).
- Edit mode: app-bar pencil toggles `_isEditing`, swapping displays for `TextField`s in place (`:87-111`).

### 1.4 Reconciliation with reference images

| Observation in image | Code reality | Verdict |
|---|---|---|
| Image #1: lone tree sits **top-left**, not centred | `_getTreePosition(0,1,width)` → row0/col0 → `x = -157.5` (`forest_platform.dart:137-150`) | **Bug.** Grid positions are absolute; a 1-tree forest is never centred. |
| Image #1: "**1 trees** planted" | `'${factors.length} trees planted'` (`goal_detail_screen.dart:120`) | **Bug.** No pluralization. |
| Image #1: Health card reads **0%** in red | `avgHealth` averages only `isActiveFocus` factors; the lone factor is dormant → numerator 0, denominator 1 → 0% (`goal_detail_screen.dart:44-46`) | **Misleading.** 0% reads as "dying" when it just means "no active factor". |
| Image #1: ~30 grey dots scattered on platform | `_IsometricGridPainter` draws 30 seeded random dots (`forest_platform.dart:219-226`) | Matches. Reads as visual noise. |
| Image #2: "Level **3 → 4**", "**0%** to next level" | Header uses `factor.currentLevel` (manual, default 3) but the bar uses `effortUnits % 10` (`tree_platform.dart:36,60-122`) | **Disconnect.** Bar tracks effort, number tracks a hand-edited field — they can never agree. |
| Image #2: Gap Analysis 7 / 3 / 4 | `targetLevel` 7, `currentLevel` 3 defaults, `gap` getter (`growth_area.dart:88-106`, screen `:183-232`) | Matches. |
| Image #2: tree is a detailed illustrated PNG | `Image.asset(_getTreeAssetPath(stage))` with emoji fallback (`tree_platform.dart:155-166`) | Matches. |

---

## 2. UI/UX problems identified (ranked)

### Plan page
1. **[High] Hierarchy is flat.** Five equally-weighted slivers; no sense of "what matters now". The goal — the anchor of the whole app — is one card the same visual weight as a time-availability radio list (`strategy_screen.dart:94`, `:566`).
2. **[High] Zero progress signal.** No goal progress, no streak, no level, no momentum anywhere — despite `getGoalProgress` (`app_state.dart:1439`) and `UserStats` existing.
3. **[Med] Dormant chips are dead weight.** `_DormantFactorChip` shows only emoji + name (`:1208-1243`); no level, no gap, no "needs research" flag — nothing to act on.
4. **[Med] Two factor renderings, inconsistent.** Active factors use rich `FactorHealthTree`; dormant use bare chips. Same entity, two languages.
5. **[Med] Hand-rolled 2-column grid** for dormant factors (`:342-382`) — fragile, no `Wrap`/`GridView`.
6. **[Low] Sprint cards are button-heavy.** Complete/Failed/Undo/Delete all the same size, no progress, no link to factor health.

### Forest page
1. **[High] The forest is the point and it's tiny & broken.** Fixed 180px height, single tree mis-positioned far left (`forest_platform.dart:137-150`), platform mostly empty. The emotional centre of the app is its weakest moment.
2. **[High] Stats dump.** Six identical `_StatCard`s in a 3×2 grid (`goal_detail_screen.dart:177-235`) with no ranking — Reflects (a vanity count) sits equal to Health (a survival metric).
3. **[High] Misleading 0% Health** (see §1.4) actively discourages the user.
4. **[Med] Redundant tree breakdown.** "Active Focus" / "Dissected" chip lists (`:240-270`) duplicate the forest itself and the Plan page.
5. **[Med] Emoji headings** ("🌳 Your Forest", "📊 Statistics") clash with the refined Fraunces/Manrope type system.
6. **[Low] No tap affordance on trees** — `onTreeTap` works but nothing signals it.

### Dissected Tree page
1. **[High] Level number is fiction.** Manual `currentLevel` vs effort-derived progress bar never agree (§1.4). `isFactorLevelBehindEffort` (`app_state.dart:1486`) exists to catch exactly this and is never shown.
2. **[High] No reward for effort.** Logging a task/habit feeds `effortUnits` (`app_state.dart:1420`) but the screen never animates, never celebrates — the tree just sits there.
3. **[Med] Edit mode is jarring.** Whole layout reshuffles when the pencil is tapped (`factor_detail_screen.dart:147-274`); name field appears/disappears, Gap jumps location.
4. **[Med] Gap Analysis is three bare numbers** (`:183-232`) — no bar, no "you've closed X of Y", no visual gap.
5. **[Med] Health only implied.** Focus Status prints "Health: 62%" as plain text (`:317`); `healthStatus`/decay (`growth_area.dart:126-162`) never visualized.
6. **[Low] Work History truncates silently** ("+N more", `:564-571`) with no way to expand.

### Cross-cutting
- **[High] Three private `_SectionHeader` classes** (`strategy_screen.dart:1156`, `goal_detail_screen.dart:413`, `factor_detail_screen.dart:671`) — plus a shared `lib/widgets/section_header.dart` that none of them use.
- **[High] Gamification is invisible.** `XPBar`, `StreakBadge` (`lib/widgets/xp_bar.dart`) are defined and used **nowhere** (grep: only self-references). `UserStats` (XP, coins, streak, freezes, badges) never appears on any of the three screens.
- **[Med] Navigation is one-way & shallow.** Plan → Forest → Tree pushes routes; no breadcrumb, no lateral move (tree → sibling tree), back is the only exit.

---

## 3. Forest page — overhaul proposal

Reframe: the Forest is a **living dashboard of the goal**, not a stats page with a small graphic on top.

### 3.1 Layout (before → after)

**Before:** pill → text heading → 180px platform → 6-card grid → 2 chip lists.

**After:** a `CustomSliverAppBar` forest + a focused content stack.

```
┌─────────────────────────────┐
│ ‹  test            level 3 ✎│  collapsing app bar
│ ░░░░░ THE FOREST CANVAS ░░░░ │  expandedHeight ~300, parallax
│   🌳   🌲      🌱           │  trees scattered, depth-sorted
│ ════════════════════════════│  ground line
├─────────────────────────────┤
│ ◷ 269 days   ·   34% to goal│  goal pulse strip (1 row)
│ ▰▰▰▰▰▱▱▱▱▱  weighted progress│
├─────────────────────────────┤
│ Forest health               │  ONE hero metric, not 6
│  🌿 Thriving · 2 trees active│
├─────────────────────────────┤
│ Needs attention             │  only if a factor is wilting
│  ⚠ Focus · 4 days untended  │
├─────────────────────────────┤
│ This goal at a glance        │  compact 2×2, ranked
│  Effort 0   Tasks 0          │
│  Active 0/2 Dissected 1      │
└─────────────────────────────┘
```

### 3.2 Concrete changes

- **Forest canvas → `SliverAppBar`** (`expandedHeight` ≈ 300, `FlexibleSpaceBar`). Replaces the cramped 180px box (`goal_detail_screen.dart:149-161`). Parallax on the canvas as the user scrolls; app-bar title shrinks the goal name in.
- **Fix tree placement.** Rewrite `_getTreePosition` (`forest_platform.dart:137-150`) so trees are **distributed around the platform centre** scaled to `factors.length` — 1 tree → centre; 2–4 → arc; 5+ → current grid. Depth-sort by `pos.dy` so nearer trees overlap correctly.
- **Reduce platform noise.** Drop the 30 random dots (`forest_platform.dart:219-226`) to ~8 sparse tufts; let canopy gradient carry the texture.
- **Goal pulse strip.** New single row: days-remaining (recolours to `warning`/`danger` under thresholds) + a `getGoalProgress(goalId)` (`app_state.dart:1439`) bar — the existing weighted aggregation, finally surfaced.
- **One hero health metric.** Replace the 6-card grid (`:177-235`) with a single "Forest health" card: derived from active factors' `healthStatus` (`growth_area.dart:126`). Wording, not just a %: *Thriving / Steady / Wilting / Untended*. Fixes the misleading "0%" — a dormant-only forest reads "Resting", not "0%".
- **Conditional "Needs attention" card.** Shown only when a factor has `daysSinceWork > 3` or `healthStatus == 'wilting'/'dead'` (`growth_area.dart:150`). Deep-links straight to that `FactorDetailScreen`. This is the motivational core of the page.
- **Demote stats to a collapsed 2×2** "at a glance", ranked: Effort, Tasks, Active n/2, Dissected count. Drop Reflects/Habits-today from this screen (they live on the Tree page already).
- **Delete the redundant chip lists** (`:240-270`) — the forest canvas *is* the tree list; tapping a tree is the navigation.
- **Headings:** drop emoji ("🌳", "📊"); use `displaySmall`/`titleMedium` from the type system.

---

## 4. Dissected Tree pages — overhaul proposal

Reframe: this is where **effort becomes visible growth**. Every visit should feel like the tree responded.

### 4.1 Layout (before → after)

**Before:** TreePlatform hero → Gap Analysis → Focus Status → Level Criteria ×2 → Work History.

**After:**

```
┌─────────────────────────────┐
│ ‹  Communication        ✎   │
│         🌳  (tree, large)   │  hero, breathing idle anim
│      ╰ Sprout · Lv 3 ╮      │
│   ▰▰▰▰▰▰▱▱▱▱  3/10 effort   │  effort→next-stage, honest
│   "…thousand forests…"      │
├─────────────────────────────┤
│ ⚡ Active focus · 🌿 Healthy │  status ribbon, 1 row
│  62% health · worked 1d ago │
├─────────────────────────────┤
│ The climb                    │  Gap Analysis, reframed
│  Lv 3 ──●────────○ Lv 7     │  track w/ current + target
│  4 levels to target          │
├─────────────────────────────┤
│ What each level looks like   │  Level Criteria, collapsed
│  ▸ Level 7 — target          │  expandable tiles
│  ▸ Level 3 — you are here    │
├─────────────────────────────┤
│ Work feeding this tree       │  History, segmented
│  [Tasks] [Habits] [Reflect]  │
│  · … (tap to expand all)     │
└─────────────────────────────┘
```

### 4.2 Concrete changes

- **Honest progress bar.** Pick ONE model. Recommend: bar = effort toward next *stage* (the `effortUnits % 10` already computed, `tree_platform.dart:36`), and **label it "effort to next stage"** — not "% to next level". The manual `currentLevel`/`targetLevel` belong to "The climb" section, not the bar. Removes the §1.4 disconnect without backend change.
- **Surface the level-vs-effort signal.** When `isFactorLevelBehindEffort(factorId)` (`app_state.dart:1486`) is true, show a gentle nudge on the hero: *"Your effort suggests Level 4 — update?"* → opens edit. This is real existing logic, currently dead.
- **Status ribbon.** Collapse Focus Status (`factor_detail_screen.dart:282-402`) into a one-row ribbon under the hero: focus state + `healthStatus` word + health % + `daysSinceWork`. Keep activate/deactivate as a single trailing action; move the "max 2" warning into a snackbar on failed tap, not a permanent card.
- **"The climb" — Gap Analysis as a track.** Replace the three bare numbers (`:183-232`) with a horizontal level track 1→10, a filled node at `currentLevel`, a hollow ring at `targetLevel`, the span between tinted. Caption: "4 levels to target". Same data, legible at a glance.
- **Level Criteria → expandable tiles.** Two always-open `GlassCard`s (`:405-503`) become collapsible tiles; target collapsed by default unless empty (then it prompts). Less scroll, same content.
- **Work History → segmented.** One segmented control (Tasks / Habits / Reflect) over a single list instead of three stacked truncated lists (`:546-605`). "Show all" expands instead of silent "+N more".
- **Calmer edit mode.** Instead of reshuffling the whole column (`:147-274`), edit opens a bottom sheet (consistent with goal edit, `goal_detail_screen.dart:288`). The detail screen stays stable; no layout jump.

---

## 5. Plan page — overhaul proposal

Reframe: Plan is **mission control** — answer "what's my goal, how am I doing, what needs me" in the first screen-height.

### 5.1 Layout (before → after)

**Before:** header → goal card → factors → time → sprints, all equal weight.

**After:**

```
┌─────────────────────────────┐
│ Strategy          Lv 3 · 🔥5│  header + compact gamif strip
├─────────────────────────────┤
│ ╭ YOUR GOAL ───────────────╮│  hero card, biggest element
│ │ test                     ││
│ │ ◷ 269 days  ▰▰▰▱▱ 34%    ││  days + getGoalProgress
│ │ 1 tree · view forest →    ││
│ ╰───────────────────────────╯│
├─────────────────────────────┤
│ Active focus        2/2     │  unchanged structure,
│  [FactorHealthTree]         │  restyled headers
│  [FactorHealthTree]         │
├─────────────────────────────┤
│ Dissected trees      + add  │  RICH tiles, not bare chips
│  🌳 Comm   Lv3 ·gap4 ·⚠     │
│  🌲 Focus  Lv5 ·gap2        │
├─────────────────────────────┤
│ ▸ Time defense   (collapsed)│  demoted to expandable
│ ▸ Sprint goals   (collapsed)│  section, badge = active n
└─────────────────────────────┘
```

### 5.2 Concrete changes

- **Goal Anchor → hero card.** Keep the tap-to-forest behaviour (`strategy_screen.dart:96`) but make it the largest, tallest element: goal title in `displaySmall`, days-remaining, and a `getGoalProgress` bar (currently never shown on this screen). When no goal, the add-card stays but gets an illustration + clearer CTA.
- **Header gamification strip.** Add `XPBar(compact: true)` (already built, `xp_bar.dart:22`) to the header row — level + level progress + coins. First time `UserStats` appears on this screen. Add `StreakBadge` (`xp_bar.dart:236`) next to it.
- **Dissected trees → rich tiles.** Replace `_DormantFactorChip` (`:1208-1243`) and the hand-built 2-col grid (`:342-382`) with a `Wrap` of tiles showing emoji + name + `Lv{currentLevel}` + `gap` + a `needsResearch` flag (`growth_area.dart:81`). One factor visual language, shared with the Forest tree-tap target.
- **Unify factor rendering.** Active uses `FactorHealthTree`; dormant should use a compact variant of the *same* widget (dimmed, no health bar) — not a different widget. Extract a shared `FactorTile`.
- **Demote Time Defense + Sprints.** Both become collapsible sections (default collapsed) with a count badge in the header (e.g. "Sprint goals · 2 active"). They're planning tools, not daily glances — they shouldn't outweigh the goal.
- **Sprint cards:** add a thin progress hint (days elapsed / total) and shrink the Complete/Fail/Delete buttons into one primary + an overflow menu (`:1388-1513`).
- **One `SectionHeader`.** Replace all three private copies with the shared `lib/widgets/section_header.dart` (audit it first; restyle if needed). Optional `trailing` slot for +add / count badge.

---

## 6. Gamification improvements

Principle: surface what already exists; make effort *land*. No new mechanics.

### 6.1 What exists today

- `UserStats`: `totalXP`, `coins`, `currentStreak`, `longestStreak`, `freezeTokens`, `unlockedBadgeIds`, `level` (sqrt curve), `levelProgress` (`lib/models/user_stats.dart`).
- `XPRewards` constants (`user_stats.dart:325`); `earnReward` fires on task/focus/habit/reflection/experiment completion (`app_state.dart:696,825,894,1069,1368`).
- `XPBar`, `StreakBadge` widgets — built, **unused** (`lib/widgets/xp_bar.dart`).
- `AchievementNotification` overlay — shown only globally in `MainNavigationShell` (`main.dart:266-275`).
- Tree life-cycle: 7 stages (`forest_platform.dart:9-27`); per-factor `healthPercent`, decay, `growthStage`, `treeEmoji` (`growth_area.dart`).
- `getGoalProgress`, `getRecommendedLevel`, `isFactorLevelBehindEffort` — computed, **never surfaced** (`app_state.dart:1439,1478,1486`).

### 6.2 Problems & fixes

**A. Progress is invisible (visibility).**
- *Problem:* XP/level/streak exist but appear on none of the three screens. The user cannot tell they're "leveling up".
- *Fix:* `XPBar(compact)` + `StreakBadge` in the Plan header (§5.2). `getGoalProgress` bar on both the Goal hero (Plan) and the Forest pulse strip. The Tree page's effort bar gets an honest label (§4.2).

**B. Effort earns nothing felt (feedback loops).**
- *Problem:* completing work mutates `effortUnits`/`healthPercent` silently; the Tree page is static on return.
- *Fix:* when a `FactorDetailScreen` opens after new effort, play a one-shot **growth pulse** on the tree (scale 1.0→1.04→1.0, soft `successGlow`) and slide the effort bar from its old to new value. Reuse `lib/widgets/completion_animation.dart` / `confetti.dart` sparingly — a few leaves, not a casino.

**C. Stage transitions pass unmarked (motivation).**
- *Problem:* crossing a `TreeLifeStage` boundary (sprout→seedling, etc.) is the single most satisfying event and is unmarked.
- *Fix:* a restrained **stage-up moment** — the stage pill (`tree_platform.dart:174-201`) morphs, a one-line caption ("Your tree reached *Seedling*"), one `primaryGlow` pulse. No modal, no full-screen takeover. Optionally route a stage-up through the existing `AchievementNotification` channel.

**D. Health decay is silent until bad (motivation / loss-aversion).**
- *Problem:* `calculateDecayedHealth` (`growth_area.dart:156`) drops 10%/day but the user only learns via a red number.
- *Fix:* the Forest "Needs attention" card (§3.2) + on the Tree status ribbon, a calm "worked Nd ago" with the tree art subtly desaturating as health falls (drive `leafColor` off `healthPercent`, already partially wired `forest_platform.dart:323-329`). Concern, not alarm.

**E. Goal-level momentum absent (motivation).**
- *Problem:* the user closes factor gaps but never sees the goal itself move.
- *Fix:* `getGoalProgress` weighted bar on the Goal hero + Forest pulse strip; when it crosses 25/50/75/100%, a quiet milestone toast. The forest is the visual: more/larger trees as factors level.

### 6.3 Restraint guardrails

- No points-number spam on every tap; XP accrues quietly, surfaced as the *level bar*, not floating "+10".
- No badges/coins shoved onto these three screens beyond the compact header strip — the Badges/Shop screens own that.
- Motion: short (`AppMotion.standard`/`celebration`, `theme.dart:235-243`), opacity/scale based; reserve `confetti` for goal-level milestones only.
- Tone: words like *Thriving / Resting / Untended* over raw percentages where possible. Reflective, not arcade.

---

## 7. Cross-screen flow

Hierarchy: **Plan (goal) → Forest (the goal's trees) → Tree (one factor)**.

- **Shared visual spine:** one `SectionHeader`, one `FactorTile`, one tree-art language. A factor looks the same as a Plan tile, a Forest tree, and a Tree-page hero — only scale changes.
- **Transitions:** Plan goal card → Forest should be a **shared-axis / container transform** (the goal card expands into the forest canvas) rather than the default push. A `_sharedAxisRoute` already exists in `main.dart` — reuse it. Forest tree → Tree page: the tapped tree art is the transition anchor (hero animation on the tree widget).
- **Lateral movement:** on `FactorDetailScreen`, add a slim factor switcher (prev/next sibling factor of the same goal) so the user isn't forced back to the Forest to inspect the next tree.
- **Breadcrumb:** Tree page app-bar shows the goal name as a tappable crumb back to the Forest.
- **Consistent edit:** all three edit via bottom sheets (Plan/Goal already do; Tree page should adopt it, §4.2) — no in-place layout swaps.
- **State continuity:** returning to the Forest after logging effort replays the affected tree's growth pulse (§6.2-B) so the loop visibly closes.

---

## 8. Component breakdown

| Component | Action | Notes |
|---|---|---|
| `_SectionHeader` ×3 (`strategy_screen.dart:1156`, `goal_detail_screen.dart:413`, `factor_detail_screen.dart:671`) | **Delete → replace** | Use shared `lib/widgets/section_header.dart`; add optional `trailing` (count badge / +add). |
| `_DormantFactorChip` (`strategy_screen.dart:1208`) | **Replace** | New shared `FactorTile` (compact variant). |
| `FactorHealthTree` (`lib/widgets/factor_health_tree.dart`) | **Refactor → `FactorTile`** | One widget, `variant: active/dormant/hero`; absorbs `_TreeChip`, `_DormantFactorChip`. |
| `_TreeChip` (`goal_detail_screen.dart:442`) | **Delete** | Chip lists removed from Forest (§3.2). |
| `_StatCard` (`goal_detail_screen.dart:369`) | **Restyle + reduce** | 6 → compact 2×2 "at a glance". |
| `ForestPlatform` (`lib/widgets/forest_platform.dart:78`) | **Rework** | Fix `_getTreePosition` centring, depth-sort, reduce dots, support `SliverAppBar` host. |
| `TreePlatform` (`lib/widgets/tree_platform.dart:11`) | **Restructure** | Honest bar label, growth-pulse hook, stage-up moment. |
| `XPBar` / `StreakBadge` (`lib/widgets/xp_bar.dart`) | **Adopt (no change)** | Wire `compact` into Plan header. |
| `_StatChip` (`factor_detail_screen.dart:735`) | **Replace** | Folds into segmented Work History. |
| Gap Analysis trio (`factor_detail_screen.dart:183-232`) | **Replace** | New `LevelClimbTrack` widget. |
| Focus Status card (`factor_detail_screen.dart:282-402`) | **Collapse** | New `StatusRibbon` one-row widget. |
| New: `GoalPulseStrip` | **Create** | Days + `getGoalProgress` bar; Forest + Plan hero. |
| New: `ForestHealthCard`, `NeedsAttentionCard` | **Create** | Forest §3.2. |
| `_SprintGoalCard` (`strategy_screen.dart:1245`) | **Restyle** | Progress hint; buttons → primary + overflow. |
| `EmptyState` (`lib/widgets/empty_state.dart`) | **Adopt** | Use for all three empty states (§10). |

No new dependencies required. `flutter_animate` (already used) covers all motion.

---

## 9. Motion & micro-interactions

Tokens: `AppMotion` (`theme.dart:235-243`), `AppShadows.primaryGlow/successGlow` (`:166-208`).

- **Forest canvas parallax:** trees translate slower than scroll in the `SliverAppBar` collapse — depth feel.
- **Tree entrance (Forest):** staggered `fadeIn + scale(0.9→1)` per tree, ~60ms stagger, `expressive` duration. Keep the existing `goal_detail_screen.dart:157-161` but per-tree.
- **Tree → detail:** hero transition on the tapped tree art; tree "lands" on the platform with a short ease-out settle.
- **Growth pulse (§6.2-B):** on effort gain — tree `scale 1→1.04→1`, effort bar tween old→new (`celebration` dur), 6–10 leaf particles drift up once.
- **Stage-up (§6.2-C):** stage pill cross-fades label, one `primaryGlow` ring expands & fades, caption slides in. ≤900ms total.
- **Level-climb track:** the current-level node does a soft idle breathe; on level change it slides to the new node.
- **Goal progress bar:** animates from 0 to value on screen entry; milestone crossings flash the fill brighter once.
- **Status ribbon health:** color tween between `success`/`warning`/`danger` — never a hard cut.
- **Plan collapsibles:** `AnimatedSize` + chevron rotate (`standard`).
- **Restraint:** `micro`/`standard` for navigation & toggles; `celebration` only for effort/stage/goal moments. Never loop attention-grabbing animation (the current `FactorHealthTree` shimmer-repeat at `factor_health_tree.dart:43-48` should become a single shimmer, not `repeat()`).

---

## 10. Empty, loading & error states

| Screen | Empty | Loading | Error |
|---|---|---|---|
| **Plan** | No goal → illustrated `EmptyState` + "Set your goal" CTA (replaces plain add-row `strategy_screen.dart:78`). No factors → "Dissect your goal into trees" with one-tap add. | `AppState` loads from Hive synchronously after init; show `skeleton_loading.dart` placeholders for goal/factor cards during first frame if needed. | Goal load failure → inline retry card, not a bare string. |
| **Forest** | No factors → keep a card but upgrade to `EmptyState`: a single seed on bare soil + "Plant your first tree" → factor-add sheet (replaces `goal_detail_screen.dart:125-147`). | Forest canvas: skeleton platform (grid only, no trees) while factors resolve. | Goal not found → friendly `EmptyState` with "Back to Plan", not `Center(Text('Goal not found'))` (`:31-36`). |
| **Tree** | New factor, no effort → tree at seed/sprout + "Log work to help this grow"; criteria empty → inline prompt (already partially there `:444-446`). | Skeleton hero while linked tasks/habits/reflections resolve. | Factor not found → `EmptyState` + back, replaces `Center(Text('Factor not found'))` (`:60-65`). |

All three currently have **no loading states** and **bare-text error states** — unify on `EmptyState` + `skeleton_loading.dart` (both already in `lib/widgets/`).

---

## 11. Implementation order

**Phase 0 — shared foundation (unblocks everything)**
1. Adopt the shared `SectionHeader`; delete the three private copies.
2. Extract `FactorTile` (refactor `FactorHealthTree`) with `active/dormant/hero` variants.
3. Wire `EmptyState` + `skeleton_loading` error/empty/loading states on all three screens.

**Phase 1 — Plan page**
4. Goal hero card + `getGoalProgress` bar.
5. Header gamification strip (`XPBar` compact + `StreakBadge`).
6. Dissected trees → `FactorTile`; collapse Time Defense + Sprints.

**Phase 2 — Forest page**
7. Fix `ForestPlatform` positioning + depth-sort + reduce dots.
8. `SliverAppBar` forest canvas + parallax.
9. `GoalPulseStrip`, `ForestHealthCard`, `NeedsAttentionCard`; remove 6-card grid + chip lists.

**Phase 3 — Dissected Tree page**
10. Honest effort bar + `isFactorLevelBehindEffort` nudge.
11. `StatusRibbon`, `LevelClimbTrack`, collapsible criteria, segmented Work History.
12. Move edit to a bottom sheet.

**Phase 4 — gamification motion & flow**
13. Growth pulse, stage-up moment, decay desaturation.
14. Shared-axis / hero transitions Plan↔Forest↔Tree; factor switcher + breadcrumb.
15. Milestone toasts for goal-progress thresholds.

Each phase ends with `flutter analyze` + `flutter build web --no-wasm-dry-run` + a Chrome smoke test per `CLAUDE.md`.

---

## 12. Open questions

1. **Level model:** `currentLevel` is hand-edited yet effort suggests a level (`getRecommendedLevel`). Keep manual + nudge (proposed), or auto-level from effort? This changes the Tree page significantly.
2. **"Dissected" terminology:** the app uses "Dissected" for *dormant* factors (`strategy_screen.dart:276`, `goal_detail_screen.dart:257`) — confusingly, "Dissected Tree page" in this brief means *any* factor detail. Keep "Dissected" for dormant, or rename dormant to "Resting"/"Dormant" to free the word?
3. **Multiple goals:** `state.goals` is a list but UI assumes one `activeGoal`. Should the Forest/Plan support multiple goals, or is single-goal a hard constraint?
4. **Forest scale:** with many factors the 3×4 grid caps at 12 (`forest_platform.dart:141-142`). Max factors expected? Affects canvas layout.
5. **Tree art:** `TreePlatform` uses PNG assets per `treeDesignId` (`tree_platform.dart:330-351`) but `ForestPlatform` uses `CustomPaint`. Unify on one (painted = themeable + animatable; PNG = richer)? Recommend painted for animation control — confirm.
6. **Gamification visibility level:** is a compact XP/streak strip on the Plan page enough, or do you want goal-progress milestones to also fire the full-screen `AchievementNotification`?
7. **`SingleTreePlatform`** (`forest_platform.dart:592`) appears unused — confirm it can be deleted, or is it referenced from a screen outside this scope?
