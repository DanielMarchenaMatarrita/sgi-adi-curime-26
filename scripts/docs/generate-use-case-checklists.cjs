#!/usr/bin/env node
'use strict';

// Convierte el catálogo CSV versionado en checklists por vista DCU.
// Uso: node scripts/docs/generate-use-case-checklists.cjs [--check]
// Sin dependencias fuera de Node.js.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

const ROOT = path.resolve(__dirname, '../..');
const BASE = path.join(ROOT, 'docs/functional/use-cases');
const CAT = path.join(BASE, 'catalogo.csv');
const DEST = path.join(BASE, 'checklists');
const CHECK = process.argv.includes('--check');
assert(process.argv.length === (CHECK ? 3 : 2), 'Argumentos inválidos');

function csvRows(source) {
  const rows = [];
  let row = [];
  let cell = '';
  let quote = false;
  for (let i = 0; i < source.length; i++) {
    const char = source[i];
    if (quote) {
      if (char === '"' && source[i + 1] === '"') { cell += '"'; i++; }
      else if (char === '"') quote = false;
      else cell += char;
    } else if (char === '"') {
      assert.equal(cell, '', 'Comilla inesperada en CSV');
      quote = true;
    } else if (char === ',') {
      row.push(cell); cell = '';
    } else if (char === '\r' || char === '\n') {
      if (char === '\r' && source[i + 1] === '\n') i++;
      row.push(cell); cell = '';
      if (row.some(x => x !== '')) rows.push(row);
      row = [];
    } else cell += char;
  }
  assert(!quote, 'CSV con comillas sin cerrar');
  if (cell !== '' || row.length) { row.push(cell); rows.push(row); }
  return rows;
}

const [columns, ...data] = csvRows(fs.readFileSync(CAT, 'utf8'));
assert(columns?.includes('id') && columns.includes('estado_implementacion'));
const records = data.map(values => {
  assert.equal(values.length, columns.length, 'Columnas CSV inconsistentes');
  return Object.fromEntries(columns.map((name, index) => [name, values[index]]));
});
assert.equal(records.length, 155, 'El catálogo debe tener 155 CU');
const ids = records.map(r => r.id);
assert.equal(new Set(ids).size, 155, 'Identificadores duplicados');
for (let i = 1; i <= 155; i++) {
  assert.equal(ids[i - 1], `CU-${String(i).padStart(2, '0')}`, 'Secuencia de CU incorrecta');
}
const validStatuses = new Set(['SIN_FLUJO_ACREDITADO', 'PARCIAL', 'INTEGRADO', 'VERIFICADO']);
for (const item of records) {
  assert(validStatuses.has(item.estado_implementacion), `Estado inválido: ${item.id}`);
  assert(['PENDIENTE', 'EN_REVISION', 'VERIFICADO'].includes(item.estado_qa));
  if (item.estado_qa === 'VERIFICADO') assert.equal(item.estado_implementacion, 'VERIFICADO');
}
const dcus = [...new Set(records.map(r => r.dcu))].sort();
assert.deepEqual(dcus, Array.from({length: 15}, (_, i) => `DCU-${String(i + 1).padStart(2, '0')}`));
const count = (rs, state) => rs.filter(r => r.estado_implementacion === state).length;
const verified = rs => rs.filter(r => r.estado_implementacion === 'VERIFICADO' && r.estado_qa === 'VERIFICADO').length;
const changed = [];
function emit(filename, contents) {
  const desired = contents.join('\n').trimEnd() + '\n';
  const prior = fs.existsSync(filename) ? fs.readFileSync(filename, 'utf8') : '';
  if (prior === desired) return;
  if (CHECK) { changed.push(path.relative(ROOT, filename)); return; }
  fs.mkdirSync(path.dirname(filename), { recursive: true });
  fs.writeFileSync(filename, desired, 'utf8');
}
const summary = [
  '# Resumen del catálogo de CU', '',
  '> ARCHIVO GENERADO: no editar. Fuente: [`../catalogo.csv`](../catalogo.csv).', '',
  'Un caso solo está cerrado si **implementación y QA son VERIFICADO**.', '',
  `- Total: **${records.length}**`,
  `- Integrados (QA pendiente o en revisión): **${count(records, 'INTEGRADO')}**`,
  `- Parciales: **${count(records, 'PARCIAL')}**`,
  `- Sin flujo acreditado: **${count(records, 'SIN_FLUJO_ACREDITADO')}**`,
  `- Verificados: **${verified(records)}**`, '',
  '| Vista | Total | Integrados | Parciales | Sin acreditar | Verificados |',
  '|---|---:|---:|---:|---:|---:|',
];
for (const dcu of dcus) {
  const rows = records.filter(r => r.dcu === dcu);
  summary.push(`| [${dcu}](${dcu}.md) | ${rows.length} | ${count(rows, 'INTEGRADO')} | ${count(rows, 'PARCIAL')} | ${count(rows, 'SIN_FLUJO_ACREDITADO')} | ${verified(rows)} |`);
  const body = [
    `# ${dcu} · Checklist de casos de uso`, '',
    '> ARCHIVO GENERADO: actualizar `catalogo.csv`, luego ejecutar `node scripts/docs/generate-use-case-checklists.cjs`.', '',
    'La casilla solo se marca cuando el caso tiene implementación y QA **VERIFICADO**.', '',
  ];
  for (const r of rows) {
    const checked = r.estado_implementacion === 'VERIFICADO' && r.estado_qa === 'VERIFICADO' ? 'x' : ' ';
    const evidence = r.evidencia_codigo ? ` · Evidencia: ${r.evidencia_codigo.replaceAll(';', ', ')}` : '';
    body.push(`- [${checked}] **${r.id}** · ${r.titulo} — \`${r.estado_implementacion}\` · QA \`${r.estado_qa}\`${evidence}`);
  }
  emit(path.join(DEST, `${dcu}.md`), body);
}
emit(path.join(DEST, 'RESUMEN.md'), summary);
if (changed.length) {
  console.error(`DESACTUALIZADOS: ${changed.join(', ')}`);
  process.exitCode = 1;
} else console.log('OK: 155 CU, 15 DCU y checklists sincronizados');
