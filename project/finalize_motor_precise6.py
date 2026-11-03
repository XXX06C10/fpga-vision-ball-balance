from pathlib import Path
import hashlib, json, shutil
from build_motor_precise6 import verify

R = Path(__file__).resolve().parent
bit = verify()
tests = json.loads((R/'motor_precise6_regression.json').read_text(encoding='utf-8'))
required = json.loads((R/'motor_precise6_required_suites.json').read_text(encoding='utf-8'))
assert set(tests) == set(required)
for name, result in tests.items():
    assert result['status'] == 'PASS', name
    assert hashlib.sha256((R/'sim/results'/f'{name}.log').read_bytes()).hexdigest() == result['log_sha256'], name+' stale log'
    assert (R/'rtl/vision_monitor_all.v').read_text(encoding='utf-8') in (R/'sim/results'/f'{name}.combined.v').read_text(encoding='utf-8'), name+' stale RTL'
out = R/'output'
out.mkdir(exist_ok=True)
for name in ('merged_vision_motor_logo_brake_precise6_uartfix.bit', 'merged_vision_motor_logo_brake_precise6.bit', 'merged_vision_motor_logo.bit'):
    shutil.copy2(bit, out/name)
report = json.loads((R/'motor_precise6_routing_verification.json').read_text(encoding='utf-8'))
report.update(status='SOFTWARE_AND_ROUTING_PASS_PHYSICAL_PENDING', suites=tests, bit='output/merged_vision_motor_logo_brake_precise6_uartfix.bit', original_video_and_logo_preserved=True, motor_source='brake_precise6', display_prediction_imported=False)
(R/'motor_precise6_verification.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
(out/'merged_vision_motor_logo_brake_precise6_sha256.txt').write_text(report['sha256']+'  merged_vision_motor_logo_brake_precise6_uartfix.bit\n', encoding='utf-8')
print('DELIVERY_COMPLETE '+str(out/'merged_vision_motor_logo_brake_precise6_uartfix.bit'))
