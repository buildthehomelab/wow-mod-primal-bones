# Primal Bones

An [AzerothCore](https://www.azerothcore.org/) (WotLK 3.3.5a) module that turns Un'Goro Crater
into a level 60 hunting ground. A Zandalar bonewright, Ju'zaro, has camped on the rim of the
Lakkari Tar Pits. Bring him **9,999 Primal Bones** and the tar gives up a **Bone-White Primal
Raptor**.

> Da Zandalar been raisin' raptors since before your kingdoms had names. But a primal raptor...
> dat takes a rite. Ten thousand bones of da crater's beasts. Bring Ju'zaro nine thousand, nine
> hundred and ninety-nine. Da last bone? Dat one grows inside da egg.

## What's in it

- **Ju'zaro, Zandalar Bonewright**, on the northern rim of the Lakkari Tar Pits. He talks to
  anyone, but he only gives out quests from level 60. His greeting changes as your pile of bones
  grows.
- **Primal Bones** drop from Un'Goro's beasts, but **only while one of Ju'zaro's quests is in your
  quest log**. Raptors, diemetradons and pterrordaxes drop 3-6, the tar elementals 2-4, stegodons
  and devilsaurs 15-25, and the crater's rares far more. That's roughly twelve hours of hunting for
  the full 9,999 alone, less in a group. Bones are soulbound and stack to 9,999.
- **Sixteen quests, one bone pile.** "The Ten-Thousandth Bone" takes 9,999 bones and gives the
  Bone-White Primal Raptor. The others are trades you can each make once:

  | Bones | Reward |
  | ----: | --- |
  | 3,333 | Red, Black or Green Primal Raptor (one quest each), Palehide Direhorn |
  | 500 | Zandalari Kneebiter, Anklerender, Footslasher, Toenibbler, Shinchomper, Baby Zandalari Raptor; Pygmy, Tiny or Stunted Direhorn |
  | 250 | Direhorn Hatchling, Diemetradon Hatchling |

  Every quest takes bones from the same pile, so a pet now means the white raptor later.
- **Primal Eggs** drop now and then (1 in 200 from beasts, 1 in 50 from elites, often from rares),
  again only for players on one of the quests. An egg hatches **three days** later, offline time
  included, into a Hatched Primal Egg. Open it: 9% of the time it's one of the three primal
  raptors, 36% one of the six Zandalari raptor pets, otherwise 100-200 bones.
- **Tarborn Tyrants**, rare elite primal devilsaurs that claw their way out of the tar on one of
  three spots around the pits, three hours after the last one was killed. There are five, one for
  each of retail's striped primal devilsaur skins, and whichever skin comes up drops its own
  mount (10%): dark the Cobalt Primordial Direhorn, blue the Cobalt Pterrordax, green the Jade
  Pterrordax, pale the Swift Albino Raptor, brown the Golden Primal Direhorn. They fight like King
  Mosh and also drop 200-250 bones and an egg.
- **Zandalari Warbringers**: rare elite Zandalari riding Slate, Amber or Jade Primordial
  Direhorns. One is out at a time, on one of five spots across the crater; an hour after a kill
  another one rides in, in any colour at any spot. Each drops 60-100 bones, often an egg, and
  sometimes (10%) the direhorn it rides.
- Both rares announce themselves to the whole crater when they appear.

## Requirements

- [wow-mod-retail-collection](https://github.com/buildthehomelab/wow-mod-retail-collection): the
  mounts and pets the quests and drops give are its items (400000+ and 410000+).
- [wow-mod-retail-library](https://github.com/buildthehomelab/wow-mod-retail-library) and its
  client patches: the Warbringers ride its direhorn looks, and the Tarborn Tyrant wears its
  striped primal devilsaur looks (displays 247249, 247271, 247272, 247273 and 276972).

No client patch of its own: the bones and eggs reuse three items Blizzard never used (Deprecated
Bone Chips 1963, NPC Equip 20798 and 23357), whose rows the client already has with bone and egg
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

Creature, quest, npc_text, gossip menu, reference loot, pool and spawn guids 9506000-9506099.
Items 1963, 20798 and 23357 (repurposed). New loot rows on 22 stock Un'Goro creatures (bones and
an egg reference only; their own loot is untouched).

## License

MIT.
