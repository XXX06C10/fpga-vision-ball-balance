from pathlib import Path
import hashlib, json, re, shutil, subprocess, sys

R = Path(__file__).resolve().parent
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):
    b = p.read_bytes()
    return b.decode('utf-16' if b.startswith((b'\xff\xfe', b'\xfe\xff')) else 'utf-8-sig')
def require(ok, why):
    if not ok: raise RuntimeError(why)
def capture():
    return {str(p.relative_to(R)).replace('\\', '/'): sha(p)
            for folder in ('rtl', 'user_source', 'td_project')
            for p in (R/folder).rglob('*') if p.is_file()}
def adc(p):
    result = {}
    for line in read(p).splitlines():
        if line.lstrip().startswith('#'): continue
        m = re.search(r'set_pin_assignment\s*\{\s*(.*?)\s*\}\s*\{(.*?)\}', line)
        if m: result[m[1]] = {k.strip(): v.strip() for k, v in re.findall(r'(\w+)\s*=\s*([^;]+);', m[2])}
    return result
def pins(p):
    result = {}
    for line in read(p).splitlines():
        f = line.split()
        if len(f) >= 8 and f[1] in ('INPUT', 'OUTPUT', 'INOUT'): result[f[0]] = f[1:8]
    return result
def verify():
    require(capture() == json.loads(read(R/'motor_precise6_build_sources.json')), 'sources changed during build')
    info = json.loads(read(R/'motor_precise6_integration.json'))
    for rel, h in info['imported_release_hashes'].items(): require(sha(R/rel) == h, 'precise6 RTL mismatch '+rel)
    for rel, change in info.get('serial_area_optimization', {}).items(): require(sha(R/rel) == change['after'], 'serial formatter changed '+rel)
    if 'serial_area_optimization' in info:
        require('SERIAL_BYTE_EQUIVALENCE_PASS VIS_indices=1048576 D2_indices=524288' in read(R/'evidence/serial_area/test.log'), 'serial byte equivalence failed')
        require(sha(R/'rtl/vision_monitor_all.v') == info['composed_sha256'], 'composed RTL changed')
    for rel, h in info['preserved_source_hashes'].items(): require(sha(R/rel) == h, 'preserved source changed '+rel)
    log = read(R/'build_motor_precise6.log')
    require('MERGED_VISION_MOTOR_PRECISE6_UARTFIX_BUILD_COMPLETE' in log, 'build completion marker absent')
    require(not re.search(r'Undriven net:.*(?:u_camera_control|u_vision_monitor|S_roi_|S_detect_rst)', log), 'undriven control net')
    critical = []
    for line in log.splitlines():
        if 'CRITICAL-WARNING' in line:
            require(bool(re.match(r'^PHY-5060 CRITICAL-WARNING: Clock net candidate (u_uicfgcs500/uii2c_inst/scl_clk|O_cam_24m_syn_\d+) has mixed fanouts', line) or re.match(r'^PHY-5079 CRITICAL-WARNING: Marked \d+ clock net\(s\) utilize the local routing resources', line)), 'unreviewed critical: '+line)
            critical.append(line)
    run = R/'motor_precise6_Runs/phy_1'
    timing = read(run/'logo_phy.ts')
    slack = {k: float(re.search(k+r':\s*([-\d.]+)ns', timing)[1]) for k in ('SWNS', 'STNS', 'HWNS', 'HTNS')}
    require(all(v >= 0 for v in slack.values()), 'routed timing failed '+str(slack))
    bit = run/'merged_vision_motor_logo_brake_precise6_uartfix.bit'
    require(b'# Package: PH1P35MDG324' in bit.read_bytes()[:500], 'wrong device')
    routed = pins(run/'logo_phy.area')
    baseline = pins(R/'logo_Runs/phy_1/logo_phy.area')
    require(set(routed) == set(baseline), 'routed ports changed')
    for port, fields in baseline.items(): require(routed[port][:3] == fields[:3] and routed[port][5] == fields[5], 'original routed pin changed '+port)
    constraints = adc(R/'user_source/constraints_source/pin.adc')
    for port, values in constraints.items():
        require(port in routed and routed[port][1] == values['LOCATION'] and routed[port][2] == values['IOSTANDARD'] and routed[port][5] == values['PULLTYPE'], 'routed electrical mismatch '+port)
    official = R.parents[1]/'2_Example/32_cs500_mipi_hdmi/pin/pin.adc'
    for port, values in adc(official).items():
        port = {'I_sys_clk_25m': 'I_sys_clk', 'O_clk_24m': 'O_cam_24m'}.get(port, port)
        require(all(constraints[port][k] == values[k] for k in ('LOCATION', 'IOSTANDARD')), 'official board pin mismatch '+port)
    netlist = read(R/'motor_precise6_routed_netlist.v')
    diagnostic_rows = [line for line in read(run/'logo_phy.area').splitlines() if '|vision_cascade_diag ' in line]
    require(len(diagnostic_rows) == 1 and int(diagnostic_rows[0].split('|')[6].strip()) == 0, 'D2 framing unexpectedly mapped into ERAM')
    ram_instances = re.findall(r'PH1P_PHY_ERAM(?:_V2)?\s*#\([^;]*?\)\s*(\\[^\s]+)\s*\(', netlist, re.S)
    require(all('/cascade_diag/' not in name for name in ram_instances), 'D2 ERAM in routed netlist')
    uart_evidence = json.loads(read(R/'uart_fix_verification.json'))
    require(uart_evidence['status'] == 'PREBUILD_TESTS_PASS', 'UART fix evidence missing')
    for path, h in uart_evidence['files'].items(): require(sha(R/path) == h, 'UART fix evidence changed '+path)
    drivers = {}
    for port in ('O_motor_step', 'O_motor_step_v2', 'O_motor_dir', 'O_motor_dir_v1', 'O_motor_en', 'O_motor_en_u2'):
        m = re.search(r'\b'+port+r'_syn_\d+\s*\(\s*\.doq\(\{([^}]+)\}\),\s*\.opad\('+port+r'\)\);', netlist)
        require(m is not None, 'missing motor pad '+port)
        drivers[port] = m[1].split(',')[-1].strip()
    for a, b in (('O_motor_step', 'O_motor_step_v2'), ('O_motor_dir', 'O_motor_dir_v1'), ('O_motor_en', 'O_motor_en_u2')):
        require(drivers[a] == drivers[b] and drivers[a] not in ("1'b0", "1'b1"), 'motor mirror mismatch '+a)
    resources = {key: int(re.search(r'^#'+label+r'\s+(\d+)', read(run/'logo_phy.area'), re.M)[1]) for key, label in (('slice', 'slice'), ('register', 'reg'), ('IO', 'IO'), ('ERAM', 'eram'), ('DSP', 'dsp'))}
    osd = info.get('area_optimization')
    if osd:
        require('OSD_PIXEL_EQUIVALENCE_PASS compared=786432' in read(R/osd['equivalence_log']), 'OSD equivalence failed')
        require(sha(R/osd['file']) == osd['current_sha256'], 'OSD changed after equivalence')
    equivalence = json.loads(read(R/'area_equivalence_verification.json'))
    for name, evidence in equivalence.items():
        require(evidence['status'] == 'PASS', 'area equivalence failed '+name)
        for path, h in evidence['inputs'].items(): require(sha(R/path) == h, 'equivalence input changed '+path)
        for kind in ('combined', 'log'):
            item = evidence[kind]
            require(sha(R/item['path']) == item['sha256'], 'equivalence evidence changed '+name+'/'+kind)
    report = {'status': 'ROUTING_PASS', 'device': 'PH1P35MDG324', 'timing_ns': slack, 'resources': resources, 'sha256': sha(bit), 'mirror_drivers': drivers, 'preserved_sources': len(info['preserved_source_hashes']), 'known_reference_clock_notices': critical, 'physical_validation': 'PENDING', 'programmed': False, 'osd_equivalence': osd, 'serial_equivalence': info.get('serial_area_optimization'), 'uart_fix': uart_evidence}
    (R/'motor_precise6_routing_verification.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2), flush=True)
    return bit

if __name__ == '__main__':
    if '--verify-only' in sys.argv:
        verify()
    else:
        subprocess.run([sys.executable, str(R/'compose.py')], cwd=R, check=True)
        (R/'motor_precise6_build_sources.json').write_text(json.dumps(capture(), indent=2), encoding='utf-8')
        td = Path('D:/Anlogic/TD_6.2.1_Engineer_6.2.168.116/bin/td_commands_prompt.exe')
        with (R/'build_motor_precise6.log').open('w', encoding='utf-8') as out:
            subprocess.run([str(td)], input='source build_motor_precise6.tcl\n', text=True, cwd=R, stdout=out, stderr=subprocess.STDOUT, check=True)
        bit = verify()
        print('BUILD_AND_ROUTING_VERIFIED '+str(bit), flush=True)
