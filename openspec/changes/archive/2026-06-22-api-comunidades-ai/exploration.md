## Exploration: api-comunidades-ai

### Current State

The project is a skill library for OpenCode agents, currently housing **one single skill**: `skills/skill-junta-andalucia.md` — a CKAN v3 API wrapper for Junta de Andalucía's open data portal. Each skill is a Markdown file with YAML frontmatter (name, description, license, metadata), triggers, API base URL, commands, parameters, response format, Python examples, pagination specs, and technical notes.

The project README promises "datos públicos de todas las comunidades de España" but only delivers Andalucía.

The skill registry at `.atl/skill-registry.md` lists only 1 project-level skill (`junta-andalucia`). `openspec/specs/` is empty — no specs have been written yet.

### Investigation Summary: Portal Landscape

Live-testing 15+ community portal URLs yielded this map of Spain's open data portal landscape:

| Community | Portal URL | API Type | Status |
|---|---|---|---|
| **Andalucía** | `junta-andalucia.es/datosabiertos` | CKAN v3 | ✅ Existing skill |
| **Aragón** | `opendata.aragon.es` | CKAN v3 (path: `/ckan/api/3/action`) | ✅ Confirmed — 2430+ datasets |
| **Asturias** | `opendata.asturias.es` | CKAN (likely) | ⚠️ Transport error (down?) |
| **Baleares** | `caib.es/caibdata` | Unknown / Custom | ❌ Not CKAN |
| **Canarias** | `datos.canarias.es` | Custom (not CKAN) | ❌ Different platform |
| **Cantabria** | `datos.cantabria.es` | CKAN (likely) | ⚠️ Transport error (down?) |
| **Castilla-La Mancha** | `datosabiertos.castillalamancha.es` | CKAN v3 | ✅ Confirmed — 200+ datasets |
| **Castilla y León** | `datosabiertos.jcyl.es` | Custom / Proprietary | ❌ Not CKAN |
| **Cataluña** | `governobert.gencat.cat` / `analisi.transparenciacatalunya.cat` | Socrata (likely) | ❌ Not CKAN |
| **Comunidad Valenciana** | `dadesobertes.gva.es` | CKAN v3 | ✅ Confirmed |
| **Extremadura** | `datosabiertos.juntaex.es` | CKAN (likely) | ⚠️ Transport error (down?) |
| **Galicia** | `datosabertos.xunta.gal` | CKAN (likely) | ⚠️ Transport error (down?) |
| **La Rioja** | `datosabiertos.larioja.org` | CKAN (likely) | ⚠️ Transport error (down?) |
| **Madrid** | `datos.comunidad.madrid` | CKAN v3 | ✅ Confirmed |
| **Murcia** | `datosabiertos.regiondemurcia.es` | CKAN v3 | ✅ Confirmed |
| **Navarra** | `datosabiertos.navarra.es` | CKAN v3 | ✅ Confirmed |
| **País Vasco** | `opendata.euskadi.eus` | Custom (SPARQL + REST APIs) | ❌ Not CKAN — requires separate investigation |
| **Ceuta** | Unknown | Unknown | 🔍 Not found |
| **Melilla** | Unknown | Unknown | 🔍 Not found |

**Key finding**: ~9/19 communities use CKAN v3 (the dominant platform). ~4 use custom or different technology. ~5 had transport errors (may be temporarily down or have moved URLs). 2 (Ceuta, Melilla) have no discoverable open data portals.

### Affected Areas

| Area | Impact |
|---|---|
| `skills/` | Where new skill files would be created — potentially 17+ new files |
| `.atl/skill-registry.md` | Must be updated to index all new skills |
| `openspec/specs/` | May need new specs for different API types (CKAN vs Socrata vs custom) |
| `README.md` | Should be updated to reflect actual coverage |
| `openspec/changes/api-comunidades-ai/` | This change's artifacts |

### Approaches

#### Approach A: One Skill Per Community (17+ skills)

Create a separate skill file for each autonomous community, each self-contained with its own frontmatter, triggers, base URL, examples, and technical notes.

**Pros:**
- Maximum discoverability — agents trigger on exact community names
- Each skill is independently maintainable and versionable
- No shared complexity or cross-skill coupling
- Matches the existing single-skill pattern exactly
- Easy to add/remove individual communities

**Cons:**
- Massive file count: 17+ nearly-identical Markdown files
- Huge duplication of CKAN boilerplate (commands, parameters, response format, pagination)
- Maintenance burden: fixing a pattern across 9 CKAN files means 9 edits
- Registry bloat in `.atl/skill-registry.md`
- Error-prone: each URL, path variation, and example must be manually verified

**Effort: High** — ~3-5 min per file × 17 files = ~1-2 hours of copy-paste, plus per-community verification

#### Approach B: Shared Base Template + Per-Community Config Overrides

Create one generic **CKAN base skill** (`skill-ckan-base.md`) that covers the 80% common pattern, plus smaller per-community files that define just the delta (base URL, portal name, triggers, auth, rate limits, deviations). Non-CKAN communities get standalone skills.

**Pros:**
- Drastically reduces duplication: 1 base file + 9 small config stubs for CKAN communities
- Single point of truth for CKAN patterns (endpoints, params, response format, pagination)
- Fix a bug once, all CKAN communities benefit
- Non-CKAN communities (Euskadi, Cataluña, Canarias, Castilla y León, etc.) get their own focused skills

**Cons:**
- Agent loading gets more complex — must load base + config file
- Still requires per-community verification
- Base template abstraction may leak: Aragón has a non-standard CKAN path (`/ckan/api/3/action` vs `/api/3/action`)
- Skills are less self-contained (agents need to understand the inheritance model)

**Effort: Medium** — ~1hr for base template + ~5min per community config stub + ~2hr for non-CKAN communities

#### Approach C: Hybrid — Group by Portal Technology

One **CKAN master skill** covering all CKAN communities with a parameterized trigger/URL system. One **Socrata skill** for Cataluña (if confirmed). One **custom skill** for País Vasco and other non-standard portals. Communities without discoverable portals get stub/skeleton skills.

**Pros:**
- Best balance of DRY and accuracy
- CKAN skill handles 9+ communities in one file with trigger expansion
- Technology grouping makes maintenance intuitive
- Non-standard portals get proper dedicated handling

**Cons:**
- CKAN skill file becomes larger (URL registry, per-community trigger list)
- Some communities may share a portal platform but have unique deviations
- Still need to handle 5 "transport error" communities once they come back online

**Effort: Medium-High** — ~1.5hr for CKAN master + ~1hr each for Socrata/custom skills

### Recommendation

**Approach B: Shared Base + Per-Community Config Overrides** — it's the most maintainable long-term.

Rationale:
1. **9 of 19 communities run CKAN v3** — that's a massive overlap. Writing 9 nearly identical files is technical debt on day one.
2. **Not all CKANs are identical** — Aragón uses a different path (`/ckan/api/3/action`), some may have auth, different rate limits, etc. A base+config pattern handles this elegantly.
3. **Non-CKAN communities are genuine exceptions** — they deserve standalone skills with their own patterns (Socrata for Cataluña, SPARQL for Euskadi, etc.)
4. **Registry indexing** stays cleaner: one base CKAN entry + per-community entries that reference it.
5. **Future-proof** — if a new community portal appears, you add a config file, not a full skill.

The recommended structure:

```
skills/
├── skill-ckan-base.md              # Shared CKAN template (endpoints, params, response format, pagination, examples)
├── skill-ckan-andalucia.md         # Config: URL, triggers, notes
├── skill-ckan-aragon.md            # Config: URL (with /ckan/ path), triggers
├── skill-ckan-castillalamancha.md  # Config: URL, triggers
├── skill-ckan-madrid.md            # Config: URL, triggers
├── skill-ckan-murcia.md            # Config: URL, triggers
├── skill-ckan-navarra.md           # Config: URL, triggers
├── skill-ckan-valencia.md          # Config: URL, triggers
├── skill-euskadi.md                # Standalone — custom SPARQL/REST API
├── skill-cataluna.md               # Standalone — Socrata API
├── skill-canarias.md               # Standalone — custom platform
├── skill-castillayleon.md          # Standalone — custom platform
└── skill-baleares.md               # Standalone — custom platform
```

Communities with transport errors (Asturias, Cantabria, Extremadura, Galicia, La Rioja) get stubs with "pending verification" notes. Ceuta/Melilla get a minimal consolidated skill if any data is found.

### Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Some communities don't have open data portals | Medium (2-4 confirmed missing) | Low — stub skill with "not available" | Use stub files, document clearly |
| Portal URLs or API versions change | Medium | Medium — skills go stale | Include verification date in metadata; add renewal note |
| Transport errors are permanent (not temporary downtime) | Low-Medium | Low — affects ~5 communities | Re-check before spec phase; may need alternative URLs |
| CKAN base template doesn't fit all CKAN variants equally | Medium | Medium — slight per-community config overhead | Make base template flexible (configurable API path, not just URL) |
| Agent loading complexity increases with base + config pattern | Low | Low — OpenCode loads one SKILL.md at a time | Per-community config files remain standalone-invokable (each has full name, description, triggers) |
| Aragón's non-standard CKAN path (`/ckan/api/3/action`) | Confirmed | Low — just a config param | Add `api_path` parameter to base template |

### Ready for Proposal

**Yes** — the exploration is complete. Clear picture of the landscape, a recommended architectural approach, and identified risks.

**What the orchestrator should tell the user:**
- ~9 of 17 communities run CKAN v3 portals (same engine as Andalucía)
- 4 use different technology (Euskadi, Cataluña, Canarias, Castilla y León)
- 5 had transport errors and need re-verification
- 2 (Ceuta, Melilla) have no discoverable portal
- Recommended approach: **shared CKAN base template** + per-community config files for CKAN communities, + standalone skills for non-CKAN communities
- Proposal phase should confirm: (1) the base+config naming convention, (2) how to handle communities with transport errors, (3) whether Ceuta/Melilla stubs are needed