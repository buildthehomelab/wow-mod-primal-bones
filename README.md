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
  | 3,333 | Red, Black or Green Primal Raptor, Palehide Direhorn |
  | 500 | Zandalari Kneebiter, Anklerender, Footslasher, Toenibbler, Shinchomper, Baby Zandalari Raptor; Pygmy, Tiny or Stunted Direhorn |
  | 250 | Direhorn Hatchling, Diemetradon Hatchling |

  Everything is paid from the same pile, so a pet now means the white raptor later. A mount or
  pet you already know drops off the list.
- **Primal Bones** drop from Un'Goro's beasts **only for players on his quest or who have done
  it**. Raptors, diemetradons and pterrordaxes drop 3-6, the tar elementals 2-4, stegodons and
  devilsaurs 15-25, and the crater's rares far more. That's roughly twelve hours of hunting for the
  full 9,999 alone, less in a group. Bones are soulbound and stack to 9,999.
- **Primal Eggs** drop now and then (1 in 200 from beasts, 1 in 50 from elites, often from rares),
  again only for players on his quest or past it. An egg hatches **three days** later, offline time
  included, into a Hatched Primal Egg. Open it: 9% of the time it's one of the three primal
  raptors, 36% one of the six Zandalari raptor pets, otherwise 100-200 bones.
- **Tarborn Tyrants**, rare elite primal devilsaurs that claw their way out of the tar on one of
  three spots around the pits, three hours after the last one was killed. There are five, one for
  each of retail's striped primal devilsaur skins, and whichever skin comes up drops its own
  mount (10%): dark the Cobalt Primordial Direhorn, blue the Zandalari Direhorn, green the Savage
  Raptor, pale the Swift Albino Raptor, brown the Golden Primal Direhorn. All ground mounts, like
  the beasts that drop them. They fight like King Mosh and also drop 200-250 bones and an egg.
- **Zandalari Warbringers**: rare elite Zandalari riding a Slate, Amber or Jade Primordial
  Direhorn or a Crimson Primal Direhorn. One is out at a time, on one of five spots across the
  crater; an hour after a kill another one rides in, in any colour at any spot. Each drops 60-100 bones, often an egg, and
  sometimes (10%) the direhorn it rides.
- Both rares announce themselves to the whole crater when they appear.

## Requirements

- [wow-mod-retail-collection](https://github.com/buildthehomelab/wow-mod-retail-collection): the
  mounts and pets the shop sells and the rares and eggs drop are its items (400000+ and 410000+).
- [wow-mod-retail-library](https://github.com/buildthehomelab/wow-mod-retail-library) and its
  client patches: the Warbringers ride its direhorn looks, and the Tarborn Tyrant wears its
  striped primal devilsaur looks (displays 247249, 247271, 247272, 247273 and 276972).

- **The shop's prices in your client patch.** A price in items is an ItemExtendedCost row, and the
  client needs it too: without it the vendor window shows no price and won't buy.
  `tools/build_patch.py` copies the patch that carries your realm's `ItemExtendedCost.dbc` and adds
  the module's four rows (90430-90433) at the end, leaving every other row and file as it was:

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

Creature, quest, npc_text, gossip menu, reference loot, pool and spawn guids 9506000-9506099;
ItemExtendedCost 90430-90439.
Items 1963, 20798 and 23357 (repurposed). New loot rows on 22 stock Un'Goro creatures (bones and
an egg reference only; their own loot is untouched).

## License

MIT.
