# Primal Bones

An [AzerothCore](https://www.azerothcore.org/) (WotLK 3.3.5a) module that turns Un'Goro Crater
into a level 60 hunting ground. A Zandalar bonewright, Ju'zaro, has camped on the rim of the
Lakkari Tar Pits. Bring him **9,999 Primal Bones** and the tar gives up a **Bone-White Primal
Raptor**.

> Da Zandalar been raisin' raptors since before your kingdoms had names. But a primal raptor...
> dat takes a rite. Ten thousand bones of da crater's beasts. Bring Ju'zaro nine thousand, nine
> hundred and ninety-nine. Da last bone? Dat one grows inside da egg.

## What's in it

- **Ju'zaro, Zandalar Bonewright**, on the western rim of the Lakkari Tar Pits. He talks to
  anyone, but he only deals from level 60. His greeting changes as your pile of bones grows.
- **His quest opens his shop.** "The Bonewright's Price" asks for 100 Primal Bones: proof you can
  hunt. Once it's done he shows his wares, priced in bones only:

  | Bones | Wares |
  | ----: | --- |
  | 9,999 | Bone-White Primal Raptor |
  | 500 | Zandalari Kneebiter, Anklerender, Footslasher, Toenibbler, Shinchomper, Baby Zandalari Raptor; Pygmy, Tiny or Stunted Direhorn |
  | 250 | Direhorn Hatchling, Diemetradon Hatchling |

  Everything is paid from the same pile, so a pet now means the white raptor later. A mount or
  pet you already know drops off the list. The Red, Black and Green Primal Raptors, the Savage
  Raptor and the Swift Albino Raptor aren't for sale: they only hatch from Primal Eggs. Nor are the direhorns: all eight colours drop from the
  crater's rares.
- **Primal Bones** drop from Un'Goro's beasts **only for players on his quest or who have done
  it**. Raptors, diemetradons and pterrordaxes drop 3-6, the tar elementals 2-4, stegodons and
  devilsaurs 15-25, and the crater's rares far more. That's roughly twelve hours of hunting for the
  full 9,999 alone, less in a group. Bones are soulbound and stack to 9,999.
- **Primal Eggs** are how you get the Red, Black and Green Primal Raptors, the Savage Raptor
  and the Swift Albino Raptor. Ju'zaro once sold the primal ones for 3,333 bones, so an egg takes about as many kills as 3,333 bones: 1 in 740 beasts,
  1 in 1,100 tar elementals, 1 in 170 stegodons and devilsaurs (0.135%, 0.09%, 0.6%), and from the
  rares Ravasaur Matriarch 1.95%, Gruff 3.75%, King Mosh 6%, a Warbringer 2.4%, a Tyrant 6.75%.
  Again only for players on his quest or past it. An egg hatches **three days** later, offline
  time included, into a Hatched Primal Egg. Open it and it's always a primal raptor, one you don't
  have yet. Once you have all five, an egg holds 25 Tarnished Undermine Reals (boss coins)
  instead.
- **Tarborn Tyrants**, rare elite primal devilsaurs that claw their way out of the tar on one of
  three spots around the pits, three hours after the last one was killed. There are five, one for
  each of retail's striped primal devilsaur skins. They drop no mount: the direhorns are the
  Warbringers' and the raptors hatch from eggs. They fight like King Mosh and also drop 200-250 bones, and sometimes an egg.
- **Zandalari Warbringers**: rare elite Zandalari, eight of them, one for each colour of the
  direhorn mount: Slate, Amber, Jade or Cobalt Primordial, Crimson or Golden Primal, Palehide or
  Zandalari Direhorn. One is out at a time, on one of five spots across the
  crater; an hour after a kill another one rides in, in any colour at any spot. Each drops 60-100 bones, now and then an egg, and
  sometimes (10%) the direhorn it rides.
- Both rares announce themselves to the whole crater when they appear.

## Requirements

- [wow-mod-retail-collection](https://github.com/buildthehomelab/wow-mod-retail-collection): the
  mounts and pets the shop sells and the rares and eggs drop are its items (400000+ and 410000+).
- [wow-mod-boss-coins](https://github.com/buildthehomelab/wow-mod-boss-coins): its coin (item
  90410) is what an egg holds once you have all five raptors. Without it those eggs are
  empty.
- [wow-mod-retail-library](https://github.com/buildthehomelab/wow-mod-retail-library) and its
  client patches: the Warbringers ride its direhorn looks, and the Tarborn Tyrant wears its
  striped primal devilsaur looks (displays 247249, 247271, 247272, 247273 and 276972).

- **The shop's prices in your client patch.** A price in items is an ItemExtendedCost row, and the
  client needs it too: without it the vendor window shows no price and won't buy.
  `tools/build_patch.py` copies the patch that carries your realm's `ItemExtendedCost.dbc` and adds
  the module's three rows (90430, 90432 and 90433) at the end, leaving every other row and file as it was:

  ```bash
  python3 tools/build_patch.py --patch <your spell and item patch>.MPQ --out <new patch>.MPQ
  ```

  Needs [StormLib](https://github.com/ladislav-zezula/StormLib). Give the new patch to your players
  in place of the old one. If your patches don't ship `ItemExtendedCost.dbc` yet, add the client's
  own copy (`DBFilesClient\ItemExtendedCost.dbc` from the locale MPQs) to one first.

The bones and eggs need no patch: they reuse three items Blizzard never used (Deprecated Bone
Chips 1963, NPC Equip 20798 and 23357), whose rows the client already has with bone and egg
icons.

## Installing

Clone the repo into the server's `modules` folder under the name `mod-primal-bones` (AzerothCore
names the module's loader after its folder), then rebuild:

```bash
git clone https://github.com/buildthehomelab/wow-mod-primal-bones.git modules/mod-primal-bones
```

The world database SQL in `data/sql/db-world` is applied on the next start.

## Uninstalling

Remove the module, rebuild, and run `data/sql/uninstall/mod_primal_bones_uninstall_world.sql` on
the world database. It puts the three repurposed items back the way stock AzerothCore has them;
see the file's header for what happens to bones and eggs players still carry.

## IDs

Creature, gameobject template, quest, npc_text, gossip menu, reference loot, pool and spawn guids
9506000-9506099;
ItemExtendedCost 90430-90439.
Items 1963, 20798 and 23357 (repurposed). New loot rows on 22 stock Un'Goro creatures (bones and
an egg reference only; their own loot is untouched).

## License

MIT.
