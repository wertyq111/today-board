# Today Board Apple Design Rules

This project uses `awesome-design-md` as the source index. The Apple entry in this downloaded collection points to `https://getdesign.md/apple/design-md`; this file is the project-local rule set for ArkUI implementation.

## Visual Thesis

The home page should feel like an Apple keynote product moment: black stage, cinematic product imagery, and very few words. Functional pages should feel like Apple system tools: light gray background, white grouped surfaces, calm typography, and direct controls. Main-path controls use black, white, and gray instead of blue.

## Color Roles

| Role | Color | Usage |
| --- | --- | --- |
| Stage black | `#000000` | Home hero and keynote sections |
| Graphite | `#1D1D1F` | Primary light-page text |
| System background | `#F5F5F7` | Checklist, reminders, profile pages |
| Surface | `#FFFFFF` | Grouped lists and input panels |
| Separator | `#D2D2D7` | Thin list dividers only |
| Graphite action | `#1D1D1F` | Primary buttons and current state |
| Muted action | `#EDEDF0` | Secondary buttons and icon containers |
| System green | `#34C759` | Success state |
| System orange | `#FF9F0A` | Missing or unavailable state |

## Typography

- Use the platform sans stack through ArkUI defaults. Do not introduce decorative fonts.
- Home hero title is the largest text. Keep it short enough for three lines.
- Utility pages use 34px page titles, 16-17px row titles, and 12-15px supporting text.
- Letter spacing stays at `0`.

## Layout Rules

- Home first screen is a poster, not a dashboard grid.
- Do not put cards inside cards.
- Use grouped list surfaces for Checklist, Reminders, and Profile.
- Bottom nav is compact, fixed, black translucent, and does not consume the first screen.
- Main-path buttons, icons, navigation, and status text use neutral black/gray tones. Do not use blue as an accent.

## Data Rules

- Never invent weather, calendar, location, or checklist values.
- If a system ability is unavailable, show the unavailable state directly.
- Manual weather tags are allowed because they are explicit user input.
- Weather comes only from HMS WeatherServiceKit after real location is ready. If HMS capability is missing, empty, or errors, keep the matching state visible.

## Asset Rules

- `tb_apple_hero.png` is the home keynote visual.
- The four current Tabs and service-card UI use `AppIcon` + `SymbolGlyph($r('sys.symbol.*'))`.
- Navigation symbols are home, checklist, reminders, and profile. Weather symbols are clear, rain, cloud, and unknown.
- Active navigation uses white on the dark bottom bar; inactive navigation uses gray.
- Existing `tb_*` bitmap icons are legacy or hero-support assets. Do not expand the cartoon bitmap icon set for current Tab UI.
- Do not add Apple logos or copied Apple product imagery.
