// Lädt den Optimierer ohne Skriptfehler und rechnet eine Luftlinien-Tour mit den Beispieldaten.
// Aufruf (im Repo-Ordner):  npm i jsdom  &&  node tests/test-laden.js
const fs = require('fs');
const path = require('path');
const { JSDOM, VirtualConsole } = require('jsdom');
const root = path.join(__dirname, '..');
let failures = 0;
function check(label, cond){ console.log((cond ? 'OK   ' : 'FEHLER ') + label); if(!cond) failures++; }
const sleep = ms => new Promise(r => setTimeout(r, ms));

function load(file){
  const errors = [];
  const vc = new VirtualConsole();
  vc.on('jsdomError', e => { if(!/canvas|getContext|Not implemented/i.test(String(e.message))) errors.push(e.message); });
  const html = fs.readFileSync(path.join(root, file), 'utf8');
  const dom = new JSDOM(html, { runScripts: 'dangerously', pretendToBeVisual: true, virtualConsole: vc,
    beforeParse(win){
      // jsdom kann kein Canvas zeichnen: Zeichenbefehle ins Leere laufen lassen.
      const noop = () => {};
      const ctx = new Proxy({}, { get: (t, k) => (k in t ? t[k] : (k === 'measureText' ? () => ({ width: 0 }) : noop)), set: (t, k, v) => { t[k] = v; return true; } });
      win.HTMLCanvasElement.prototype.getContext = () => ctx;
    } });
  return { w: dom.window, errors };
}
async function feedGpx(w){
  const text = fs.readFileSync(path.join(root, 'beispiele', 'beispiel-wegpunkte.gpx'), 'utf8');
  const input = w.document.getElementById('file');
  Object.defineProperty(input, 'files', { value: [{ name: 'beispiel-wegpunkte.gpx', text: async () => text }] });
  input.dispatchEvent(new w.Event('change'));
  await sleep(200);
}

(async () => {
  for(const file of ['wegpunkt-optimierer.html']){
    console.log('\n== ' + file);
    const { w, errors } = load(file);
    await sleep(100);
    await feedGpx(w);
    const status = w.document.getElementById('status').textContent;
    check('Beispiel-GPX geladen (' + status.slice(0, 60) + ')', /25 Wegpunkte/.test(status));
    if(file === 'wegpunkt-optimierer.html'){
      w.document.getElementById('budget').value = '2';
      w.document.getElementById('btnRun').click();
      for(let i=0; i<60 && !/Fertig/.test(w.document.getElementById('status').textContent); i++) await sleep(250);
      const st = w.document.getElementById('status').textContent;
      check('Luftlinien-Optimierung fertig (' + st.slice(0, 70) + ')', /Fertig/.test(st));
      check('Ergebnis enthält alle 25 Punkte', w.eval('bestResult && new Set(bestResult.order).size') === 25);
    }
    check('Keine Skriptfehler' + (errors.length ? ': ' + errors.join(' | ') : ''), errors.length === 0);
    w.close();
  }
  console.log(failures === 0 ? '\nAlle Tests bestanden.' : `\n${failures} Test(s) fehlgeschlagen.`);
  process.exit(failures === 0 ? 0 : 1);
})();
