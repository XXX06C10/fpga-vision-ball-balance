from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import hashlib, json, subprocess, time

R = Path(__file__).resolve().parent
suites = json.loads((R/'motor_precise6_required_suites.json').read_text())
def run(bench):
    start = time.monotonic()
    p = subprocess.run(['powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', str(R/'run_sim.ps1'), '-Testbench', bench], cwd=R, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (R/'sim/results'/f'{bench}.runner.log').write_bytes(p.stdout)
    log = (R/'sim/results'/f'{bench}.log')
    raw = log.read_bytes() if log.exists() else b''
    data = raw.decode('utf-16' if raw.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig')
    ok = p.returncode == 0 and 'PASS' in data and 'FATAL' not in data and 'FAIL:' not in data
    print(('PASS ' if ok else 'FAIL ')+bench+f' {time.monotonic()-start:.1f}s', flush=True)
    if not ok: print(p.stdout.decode(errors='replace')[-3000:], flush=True)
    return bench, {'status': 'PASS' if ok else 'FAIL', 'seconds': round(time.monotonic()-start, 2), 'log_sha256': hashlib.sha256(log.read_bytes()).hexdigest() if log.exists() else None}
with ThreadPoolExecutor(max_workers=3) as pool:
    results = dict(f.result() for f in as_completed([pool.submit(run, b) for b in suites]))
(R/'motor_precise6_regression.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
if any(v['status'] != 'PASS' for v in results.values()): raise SystemExit(1)
print(f'ALL_{len(results)}_MOTOR_PRECISE6_SUITES_PASS', flush=True)
