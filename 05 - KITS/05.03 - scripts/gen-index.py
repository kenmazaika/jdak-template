#!/usr/bin/env python3
"""Regenerate index.md from frontmatter. Run from the vault root."""
import re, glob, os, datetime

def fm_get(text, field):
    m = re.search(rf'^{field}:\s*(.+)$', text[:1500], re.M)
    return m.group(1).strip().strip('"\'') if m else None

sections = {
    '02 - AREAS/02.02 - goals': '🎯 Goals',
    '03 - PERMANENT/03.01 - concepts': '📚 Concepts (permanent)',
    '04 - RESOURCES/04.01 - references': '🔗 References (curated links)',
    '09 - FLEETING/09.02 - concepts': '🌅 Fleeting — concepts',
    '09 - FLEETING/09.03 - entities': '🏛️ Entities (fleeting)',
    '09 - FLEETING/09.04 - comparisons': '⚖️ Comparisons (fleeting)',
    '09 - FLEETING/09.05 - questions': '❓ Questions (fleeting)',
}
lines = []
lines.append('# JDAK Index\n')
lines.append('> Auto-generated from frontmatter. Regenerate with `05 - KITS/05.03 - scripts/gen-index.py`.')
lines.append(f'> Generated: {datetime.date.today().isoformat()}\n')
for folder, title in sections.items():
    files = sorted(glob.glob(f'{folder}/*.md'))
    if not files: continue
    lines.append(f'## {title} ({len(files)})\n')
    for f in files:
        text = open(f, encoding='utf-8', errors='replace').read()
        t = fm_get(text, 'title') or os.path.basename(f)[:-3]
        kind = fm_get(text, 'kind')
        status = fm_get(text, 'status')
        body = re.sub(r'^---\n.*?\n---\n', '', text, flags=re.S).strip()
        first = re.sub(r'[#>*`\-\[\]]', '', body.split('\n')[0] if body else '').strip()
        meta = ' · '.join(x for x in [kind, status] if x)
        lines.append(f'- **[[{t}]]** — {first[:120]}{(" [" + meta + "]") if meta else ""}')
    lines.append('')
lines.append('## 🛠️ Production\n')
_roots = {
    'projects (01)': '01 - PROJECTS',
    'working (08.02)': '08 - PRODUCTION/working',
    'drafts (08.01)': '08 - PRODUCTION/drafts',
}
for label, sub in _roots.items():
    n = len(glob.glob(f'{sub}/**/*.md', recursive=True))
    lines.append(f'- `{sub}/` — {n} files')
lines.append('')
open('index.md', 'w', encoding='utf-8').write('\n'.join(lines))
print(f'index.md regenerated ({sum(1 for _ in open("index.md"))} lines)')
