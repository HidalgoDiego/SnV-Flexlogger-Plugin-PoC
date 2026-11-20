"""Decode NI-XNET raw CAN frames logged by FlexLogger (TDMS) with a DBC.
Usage: python decode_flexlogger_can.py <log.tdms> <db.dbc> [raw channel name] -> <log>_CAN.csv
"""
import sys, struct, csv
import numpy as np, cantools
from nptdms import TdmsFile

def frames(raw):
    i = 0
    while i + 16 <= len(raw):
        ts, ident, typ, flags, info, ln = struct.unpack_from('<QIBBBB', raw, i)
        yield ts, ident & 0x1FFFFFFF, raw[i+16:i+16+ln]
        i += 16 + max(8, (ln + 7) // 8 * 8)

def main(tdms, dbc, chan=None):
    db = cantools.database.load_file(dbc)
    log = TdmsFile.read(tdms)['Log']
    chan = chan or next(c.name for c in log.channels() if 'Raw Logging' in c.name)
    raw = bytes(np.asarray(log[chan][:], dtype=np.uint8))
    names = [f'{m.name}.{s.name}' for m in db.messages for s in m.signals]
    t0, last, rows = None, {}, []
    for ts, ident, payload in frames(raw):
        try: m = db.get_message_by_frame_id(ident)
        except KeyError: continue
        t0 = t0 if t0 is not None else ts
        for k, v in m.decode(payload, decode_choices=False).items():
            last[f'{m.name}.{k}'] = v
        rows.append([(ts - t0) / 1e7, m.name] + [last.get(n, '') for n in names])  # XNET ts = 100 ns ticks
    out = tdms.rsplit('.', 1)[0] + '_CAN.csv'
    with open(out, 'w', newline='') as f:
        w = csv.writer(f); w.writerow(['t (s)', 'frame'] + names); w.writerows(rows)
    print(f'{len(rows)} frames -> {out}')
    return out

if __name__ == '__main__':
    main(*sys.argv[1:])
