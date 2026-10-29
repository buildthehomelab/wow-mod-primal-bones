#!/usr/bin/env python3
"""Adds Ju'zaro's bone prices to your realm's spell and item patch.

    python3 build_patch.py --patch <live patch with ItemExtendedCost.dbc> --out <new patch>

A vendor price in items is an ItemExtendedCost row, and the client needs the row too: without it
the vendor window shows no price and the client refuses to buy. This copies --patch to --out and
replaces only its DBFilesClient\\ItemExtendedCost.dbc, with the module's rows added at the end (the
rows already there keep their order and values). Every other file in the patch is untouched.

The same rows are in the module's world SQL (itemextendedcost_dbc), for the server. Keep the two
the same: COSTS below and the SQL's itemextendedcost_dbc block.

Needs StormLib (STORMLIB=/path/to/libstorm.dylib, default /usr/local/lib/libstorm.dylib).
"""
import argparse
import ctypes
import os
import shutil
import struct
import sys
import tempfile

BONE = 1963
# ItemExtendedCost id: Primal Bones. 90430-90439 are this module's.
COSTS = {90430: 9999, 90431: 3333, 90432: 500, 90433: 250}
OWN_IDS = range(90430, 90440)
TABLE = b"DBFilesClient\\ItemExtendedCost.dbc"
# id, honor, arena points, arena bracket, 5 items, 5 counts, rating, purchase group
FIELDS, ITEM, COUNT = 16, 4, 9


def stormlib():
    lib = ctypes.CDLL(os.environ.get("STORMLIB", "/usr/local/lib/libstorm.dylib"))
    H = ctypes.c_void_p
    lib.SFileOpenArchive.argtypes = [ctypes.c_char_p, ctypes.c_uint, ctypes.c_uint, ctypes.POINTER(H)]
    lib.SFileOpenFileEx.argtypes = [H, ctypes.c_char_p, ctypes.c_uint, ctypes.POINTER(H)]
    lib.SFileGetFileSize.argtypes = [H, ctypes.POINTER(ctypes.c_uint)]
    lib.SFileGetFileSize.restype = ctypes.c_uint
    lib.SFileReadFile.argtypes = [H, ctypes.c_void_p, ctypes.c_uint, ctypes.POINTER(ctypes.c_uint), ctypes.c_void_p]
    lib.SFileAddFileEx.argtypes = [H, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_uint, ctypes.c_uint, ctypes.c_uint]
    for fn in (lib.SFileCloseArchive, lib.SFileCloseFile):
        fn.argtypes = [H]
    for fn in (lib.SFileOpenArchive, lib.SFileOpenFileEx, lib.SFileReadFile, lib.SFileAddFileEx,
               lib.SFileCloseArchive, lib.SFileCloseFile):
        fn.restype = ctypes.c_bool
    return lib, H


def read_table(lib, H, mpq):
    h, f, got = H(), H(), ctypes.c_uint()
    if not lib.SFileOpenArchive(mpq.encode(), 0, 0x100, ctypes.byref(h)):
        sys.exit("can't open " + mpq)
    if not lib.SFileOpenFileEx(h, TABLE, 0, ctypes.byref(f)):
        sys.exit("%s has no %s" % (mpq, TABLE.decode()))
    size = lib.SFileGetFileSize(f, None)
    buf = ctypes.create_string_buffer(size)
    lib.SFileReadFile(f, buf, size, ctypes.byref(got), None)
    lib.SFileCloseFile(f)
    lib.SFileCloseArchive(h)
    return buf.raw[:got.value]


def add_costs(raw):
    magic, count, fields, size, strsize = struct.unpack_from("<4s4I", raw, 0)
    if magic != b"WDBC" or fields != FIELDS or size != FIELDS * 4:
        sys.exit("ItemExtendedCost.dbc isn't the 3.3.5a layout")
    rows = [list(struct.unpack_from("<%dI" % FIELDS, raw, 20 + i * size)) for i in range(count)]
    strings = raw[20 + count * size:20 + count * size + strsize]
    for r in rows:
        if r[0] in OWN_IDS and r[ITEM] != BONE:
            sys.exit("ItemExtendedCost row %d is taken by something else" % r[0])
    # Earlier builds of ours go, everything else stays where it is; ours go at the end.
    rows = [r for r in rows if r[0] not in OWN_IDS]
    for cost, bones in sorted(COSTS.items()):
        row = [0] * FIELDS
        row[0], row[ITEM], row[COUNT] = cost, BONE, bones
        rows.append(row)
    out = struct.pack("<4s4I", b"WDBC", len(rows), FIELDS, FIELDS * 4, len(strings))
    out += b"".join(struct.pack("<%dI" % FIELDS, *r) for r in rows)
    return out + strings


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--patch", required=True, help="your realm's live patch that ships ItemExtendedCost.dbc")
    ap.add_argument("--out", required=True, help="the new patch")
    args = ap.parse_args()
    lib, H = stormlib()
    table = add_costs(read_table(lib, H, args.patch))
    shutil.copyfile(args.patch, args.out)
    with tempfile.TemporaryDirectory() as tmp:
        local = os.path.join(tmp, "ItemExtendedCost.dbc")
        with open(local, "wb") as f:
            f.write(table)
        h = H()
        if not lib.SFileOpenArchive(args.out.encode(), 0, 0, ctypes.byref(h)):
            sys.exit("can't open %s for writing" % args.out)
        # MPQ_FILE_REPLACEEXISTING | MPQ_FILE_COMPRESS, zlib
        if not lib.SFileAddFileEx(h, local.encode(), TABLE, 0x80000200, 0x02, 0x02):
            lib.SFileCloseArchive(h)
            sys.exit("can't replace %s in %s" % (TABLE.decode(), args.out))
        if not lib.SFileCloseArchive(h):
            sys.exit("can't finish " + args.out)
    if read_table(lib, H, args.out) != table:
        sys.exit("%s doesn't read back" % args.out)
    print("wrote %s: ItemExtendedCost.dbc with %d bone prices (%s)" % (
        args.out, len(COSTS), ", ".join("%d: %d bones" % kv for kv in sorted(COSTS.items()))))


if __name__ == "__main__":
    main()
