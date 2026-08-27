import '../models/quest.dart';

/// World 2 — Space Mission quest content. Data only, no UI. Two quests
/// per location (the Space Portal's second quest is the world boss),
/// same Class 2 / age ~7 difficulty band as the jungle: addition and
/// subtraction within 20, simple patterns, picture words. Embedded
/// mini-game challenges alternate Math Dash and Pattern Power; Memory
/// Master embeds stay jungle-only because its generated rounds are
/// jungle-themed.
class SpaceQuests {
  SpaceQuests._();

  static const List<Quest> all = [
    // ── Space Station ──────────────────────────────────
    Quest(
      id: 'rocket_checkup',
      locationId: 'space_station',
      title: 'Rocket Check-Up',
      npc: QuestNpc(name: 'Captain Nova', emoji: '👩‍🚀'),
      storyIntro: 'Captain Nova is getting the rocket ready for launch! '
          'Help her check everything before blast-off.',
      introDialogue: [
        'Welcome aboard, Super Kid!',
        'Our rocket launches today!',
        'But first we must check everything twice.',
        'Will you be my co-pilot?',
      ],
      storyOutro: '3... 2... 1... BLAST OFF! The rocket zooms into the '
          'stars with you aboard, co-pilot!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the rocket boosters!',
          visual: '🔥🔥🔥 🔥🔥🔥',
          options: ['5', '6', '7'],
          correctIndex: 1,
          hint: 'Count each flame one by one!',
          rewardLabel: 'Booster Badge',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'We need 12 fuel cans. We have 8. How many more?',
          visual: '🛢️🛢️🛢️🛢️🛢️🛢️🛢️🛢️',
          options: ['3', '4', '5'],
          correctIndex: 1,
          hint: 'Count up from 8 to 12!',
          rewardLabel: 'Fuel Tank',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🚀',
          options: ['ROCKET', 'POCKET', 'RACKET'],
          correctIndex: 0,
          hint: 'It starts with R and flies to space!',
          rewardLabel: 'Launch Key',
        ),
      ],
    ),
    Quest(
      id: 'countdown_control',
      locationId: 'space_station',
      title: 'Countdown Control',
      storyIntro: 'The countdown computer is confused! Fix its numbers '
          'so the launch can begin.',
      storyOutro: 'The computer beeps happily — the countdown works '
          'perfectly now. Great fixing!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Counting DOWN: 10, 9, 8, … what comes next?',
          options: ['7', '6', '11'],
          correctIndex: 0,
          hint: 'Count backwards from 10 on your fingers!',
          rewardLabel: 'Countdown Chip',
        ),
        MathDashChallenge(
          prompt: 'The control panel asks number questions! Answer them '
              'to unlock the launch button.',
          questionCount: 3,
          rewardLabel: 'Launch Button',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🔴 🟢 🔴 🟢 ❓',
          options: ['🟢', '🔴', '🔵'],
          correctIndex: 1,
          hint: 'Red, green, red, green...',
          rewardLabel: 'Blinking Light',
        ),
      ],
    ),

    // ── Moon Base ──────────────────────────────────────
    Quest(
      id: 'moon_crater_count',
      locationId: 'moon_base',
      title: 'The Moon Crater Count',
      storyIntro: 'The moon robots are mapping craters! Help them count '
          'everything they find.',
      storyOutro: 'Map complete! The moon robots beep a thank-you song '
          'just for you.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the craters!',
          visual: '🕳️🕳️🕳️ 🕳️🕳️🕳️ 🕳️🕳️🕳️',
          options: ['8', '9', '10'],
          correctIndex: 1,
          hint: 'Three rows of three — count them all!',
          rewardLabel: 'Crater Map',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '7 moon rocks + 6 moon rocks. How many?',
          options: ['12', '13', '14'],
          correctIndex: 1,
          hint: 'Start at 7 and count up 6 more!',
          rewardLabel: 'Rock Bag',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🌙',
          options: ['MOON', 'MOP', 'SPOON'],
          correctIndex: 0,
          hint: 'It glows in the night sky!',
          rewardLabel: 'Moon Sticker',
        ),
      ],
    ),
    Quest(
      id: 'moonwalk_training',
      locationId: 'moon_base',
      title: 'Moonwalk Training',
      storyIntro: 'Moonwalking is bouncy! Learn the bounce patterns to '
          'hop safely across the moon.',
      storyOutro: 'Boing, boing, boing! You moonwalk like a pro '
          'astronaut now!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '👣 👣 🦘 👣 👣 🦘 👣 👣 ❓',
          options: ['🦘', '👣', '🌙'],
          correctIndex: 0,
          hint: 'Step, step, jump — step, step, jump!',
          rewardLabel: 'Bounce Boots',
        ),
        PatternPowerChallenge(
          prompt: 'The moonwalk trainer shows bounce patterns! Discover '
              'them all to pass training.',
          questionCount: 3,
          rewardLabel: 'Training Medal',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'You bounce 15 times. Then 5 more. How many bounces?',
          options: ['19', '20', '21'],
          correctIndex: 1,
          hint: '15 and 5 make a nice round number!',
          rewardLabel: 'Moonwalk Diploma',
        ),
      ],
    ),

    // ── Alien Garden ───────────────────────────────────
    Quest(
      id: 'alien_flower_show',
      locationId: 'alien_garden',
      title: 'The Alien Flower Show',
      storyIntro: 'The friendly aliens grow amazing space flowers! Help '
          'them get ready for the big flower show.',
      storyOutro: 'The flower show wins first prize! The aliens wiggle '
          'their antennas with joy.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the space flowers!',
          visual: '🌸🌸🌸🌸 🌸🌸🌸',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Count the first row, then keep going!',
          rewardLabel: 'Flower Pot',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🌸 🌸 🌺 🌸 🌸 🌺 🌸 🌸 ❓',
          options: ['🌺', '🌸', '🌵'],
          correctIndex: 0,
          hint: 'Two pink, one big — two pink, one big!',
          rewardLabel: 'Magic Seeds',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '⭐',
          options: ['STAR', 'CAR', 'JAR'],
          correctIndex: 0,
          hint: 'It twinkles in space!',
          rewardLabel: 'Prize Ribbon',
        ),
      ],
    ),
    Quest(
      id: 'space_veggie_soup',
      locationId: 'alien_garden',
      title: 'Space Veggie Soup',
      storyIntro: 'The aliens are cooking veggie soup for lunch! Help '
          'them measure the ingredients.',
      storyOutro: 'Slurp! The soup is delicious. The aliens give you '
          'the biggest bowl!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The pot needs 16 veggies. We picked 9. How many more?',
          visual: '🥕🥕🥕🥕🥕🥕🥕🥕🥕',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Count up from 9 to 16!',
          rewardLabel: 'Veggie Basket',
        ),
        MathDashChallenge(
          prompt: 'The alien recipe is full of number puzzles! Solve '
              'them to finish the soup.',
          questionCount: 3,
          rewardLabel: 'Golden Spoon',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is bigger?',
          options: ['13', '17'],
          correctIndex: 1,
          hint: 'Count up — which comes later?',
          rewardLabel: 'Soup Bowl',
        ),
      ],
    ),

    // ── Asteroid Field ─────────────────────────────────
    Quest(
      id: 'asteroid_dodge',
      locationId: 'asteroid_field',
      title: 'Asteroid Dodge',
      storyIntro: 'Floating rocks ahead! Plot a safe path for the rocket '
          'through the asteroid field.',
      storyOutro: 'You steered through every asteroid! Captain Nova '
          'salutes you, ace pilot!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '18 asteroids ahead. We dodge 8. How many are left?',
          options: ['9', '10', '11'],
          correctIndex: 1,
          hint: 'Take 8 away from 18!',
          rewardLabel: 'Pilot Wings',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The safe path goes: what comes next?',
          visual: '⬆️ ➡️ ⬆️ ➡️ ⬆️ ❓',
          options: ['➡️', '⬆️', '⬇️'],
          correctIndex: 0,
          hint: 'Up, right, up, right...',
          rewardLabel: 'Star Compass',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🪨',
          options: ['ROCK', 'SOCK', 'LOCK'],
          correctIndex: 0,
          hint: 'Asteroids are big space ones of these!',
          rewardLabel: 'Space Rock',
        ),
      ],
    ),
    Quest(
      id: 'comet_tail_patterns',
      locationId: 'asteroid_field',
      title: 'Comet Tail Patterns',
      storyIntro: 'A comet is painting glittery patterns across the sky! '
          'Read them to follow it home.',
      storyOutro: 'The comet twirls a thank-you loop and sprinkles '
          'stardust on your rocket!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '✨ 💫 💫 ✨ 💫 💫 ✨ ❓',
          options: ['💫', '✨', '🌟'],
          correctIndex: 0,
          hint: 'One sparkle, two swirls — again and again!',
          rewardLabel: 'Stardust Jar',
        ),
        PatternPowerChallenge(
          prompt: 'The comet tail is made of patterns! Discover them to '
              'keep up with the comet.',
          questionCount: 3,
          rewardLabel: 'Comet Ribbon',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count by 2s: 2, 4, 6, … what comes next?',
          options: ['7', '8', '10'],
          correctIndex: 1,
          hint: 'Add 2 more to 6!',
          rewardLabel: 'Glitter Trail',
        ),
      ],
    ),

    // ── Space Portal ───────────────────────────────────
    Quest(
      id: 'portal_power_up',
      locationId: 'space_portal',
      title: 'Portal Power-Up',
      storyIntro: 'The great space portal needs energy crystals to open! '
          'Gather and count them all.',
      storyOutro: 'The portal hums and glows with power. It is almost '
          'ready to open!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the energy crystals!',
          visual: '💎💎💎💎 💎💎💎💎 💎💎',
          options: ['9', '10', '11'],
          correctIndex: 1,
          hint: 'Four, four, and two more!',
          rewardLabel: 'Crystal Case',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The portal needs 20 sparks. We have 14. How many more?',
          options: ['5', '6', '7'],
          correctIndex: 1,
          hint: 'Count up from 14 to 20!',
          rewardLabel: 'Spark Charger',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '💎 ⚡ 💎 ⚡ 💎 ❓',
          options: ['⚡', '💎', '🌙'],
          correctIndex: 0,
          hint: 'Crystal, spark, crystal, spark...',
          rewardLabel: 'Portal Key',
        ),
      ],
    ),
    Quest(
      id: 'galaxy_guardian',
      locationId: 'space_portal',
      title: 'The Galaxy Guardian',
      npc: QuestNpc(name: 'Zorb the Star Keeper', emoji: '👽'),
      storyIntro: 'Zorb the Star Keeper guards the space portal. Pass '
          'his four starry trials to earn the Galaxy Medal!',
      introDialogue: [
        'Greetings, Earth friend!',
        'I am Zorb, keeper of the stars.',
        'The portal opens only for true space heroes.',
        'Show me your star power!',
      ],
      storyOutro: 'Zorb spins with joy! "The galaxy is proud of you, '
          'Super Kid!" Through the portal, a green island appears...',
      resolutionSteps: [
        '👽 Zorb counts your four trial rewards...',
        '🏅 The Galaxy Medal floats onto your suit!',
        '🌌 The portal swirls open with rainbow light!',
        '⭐ Every star in the sky twinkles for you!',
        '🦕 Through the portal, a dinosaur waves hello!',
      ],
      starReward: 3,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Star Trial: 9 stars + 8 stars. How many stars?',
          visual: '⭐',
          options: ['16', '17', '18'],
          correctIndex: 1,
          hint: 'Start at 9 and count up 8 more!',
          rewardLabel: 'Star Cluster',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Planet Trial: what comes next?',
          visual: '🪐 🌍 🪐 🌍 🌍 🪐 🌍 🌍 🌍 🪐 ❓',
          options: ['🌍', '🪐', '☀️'],
          correctIndex: 0,
          hint: 'One Earth, two Earths, three Earths... then?',
          rewardLabel: 'Planet Ring',
        ),
        MemoryChallenge(
          prompt: 'Which ships flew past the portal?',
          itemsToRemember: '🚀 🛸 ⭐ 🌙',
          options: ['🚀 🛸 ⭐ 🌙', '🚀 ⭐ 🛸 🌙', '🛸 🚀 ⭐ 🌙'],
          correctIndex: 0,
          studyPrompt: 'Remember these space travelers!',
          hint: 'Rocket first, saucer second — say the order out loud!',
          rewardLabel: 'Memory Star',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Word Trial: which word matches the picture?',
          visual: '🛸',
          options: ['SHIP', 'SHOP', 'SHEEP'],
          correctIndex: 0,
          hint: 'Zorb flies a space one of these!',
          rewardLabel: 'Galaxy Medal',
        ),
      ],
    ),
  ];
}
