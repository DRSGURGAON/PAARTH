import '../models/quest.dart';

/// World 4 — Magic Kingdom quest content. Data only, no UI. Two quests
/// per location (the Royal Castle's second quest is the world boss),
/// Class 2 / age ~7 difficulty: addition and subtraction within 20,
/// simple patterns, picture words.
class MagicQuests {
  MagicQuests._();

  static const List<Quest> all = [
    // ── Castle Gate ────────────────────────────────────
    Quest(
      id: 'gate_riddle',
      locationId: 'castle_gate',
      title: 'The Gate Riddle',
      npc: QuestNpc(name: 'Pip the Pixie', emoji: '🧚'),
      storyIntro: 'Pip the Pixie guards the castle gate with riddles! '
          'Answer them to enter the Magic Kingdom.',
      introDialogue: [
        'Halt! Who goes there?',
        'Oh! A Super Kid — how exciting!',
        'The gate opens only for clever visitors.',
        'Ready for my riddles?',
      ],
      storyOutro: 'The great gate swings open with a shower of sparkles. '
          'Welcome to the Magic Kingdom!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the gate bells!',
          visual: '🔔🔔🔔 🔔🔔🔔 🔔',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Three, three, and one more!',
          rewardLabel: 'Gate Bell',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🗝️ ✨ 🗝️ ✨ 🗝️ ❓',
          options: ['✨', '🗝️', '🔔'],
          correctIndex: 0,
          hint: 'Key, sparkle, key, sparkle...',
          rewardLabel: 'Sparkle Key',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🏰',
          options: ['CASTLE', 'CANDLE', 'CATTLE'],
          correctIndex: 0,
          hint: 'A king and queen live in it!',
          rewardLabel: 'Welcome Scroll',
        ),
      ],
    ),
    Quest(
      id: 'knights_parade',
      locationId: 'castle_gate',
      title: "The Knights' Parade",
      storyIntro: 'The friendly knights are lining up for the parade! '
          'Help them count and march in order.',
      storyOutro: 'Clip-clop, clip-clop! The parade marches perfectly '
          'and everyone waves at you.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '9 knights + 7 knights. How many in the parade?',
          visual: '🛡️',
          options: ['15', '16', '17'],
          correctIndex: 1,
          hint: 'Start at 9 and count up 7 more!',
          rewardLabel: 'Parade Banner',
        ),
        MathDashChallenge(
          prompt: 'The parade drummer taps out number puzzles! Solve '
              'them to keep the beat.',
          questionCount: 3,
          rewardLabel: 'Parade Drum',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The march goes: what comes next?',
          visual: '🐴 🐴 🎺 🐴 🐴 🎺 🐴 🐴 ❓',
          options: ['🎺', '🐴', '🛡️'],
          correctIndex: 0,
          hint: 'Two horses, one trumpet — again and again!',
          rewardLabel: 'Golden Trumpet',
        ),
      ],
    ),

    // ── Enchanted Forest ───────────────────────────────
    Quest(
      id: 'glowing_mushrooms',
      locationId: 'enchanted_forest',
      title: 'The Glowing Mushrooms',
      storyIntro: 'The forest path lights up with glowing mushrooms! '
          'Count them to find the fairy village.',
      storyOutro: 'The mushrooms twinkle brighter and reveal the tiny '
          'fairy village. The fairies cheer!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the glowing mushrooms!',
          visual: '🍄🍄🍄🍄🍄 🍄🍄🍄🍄🍄 🍄',
          options: ['10', '11', '12'],
          correctIndex: 1,
          hint: 'Five, five, and one more!',
          rewardLabel: 'Glow Jar',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '13 fireflies. 4 fly home. How many are left?',
          options: ['8', '9', '10'],
          correctIndex: 1,
          hint: 'Take 4 away from 13!',
          rewardLabel: 'Firefly Lamp',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🌳',
          options: ['TREE', 'THREE', 'FREE'],
          correctIndex: 0,
          hint: 'It has leaves and branches!',
          rewardLabel: 'Fairy Map',
        ),
      ],
    ),
    Quest(
      id: 'fairy_lights',
      locationId: 'enchanted_forest',
      title: 'The Fairy Light Dance',
      storyIntro: 'The fairies dance in light patterns every night! '
          'Learn their patterns to join the dance.',
      storyOutro: 'You dance with the fairies until the stars come '
          'out. What a magical night!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The dance goes: what comes next?',
          visual: '💛 💜 💛 💜 💛 ❓',
          options: ['💜', '💛', '💚'],
          correctIndex: 0,
          hint: 'Yellow, purple, yellow, purple...',
          rewardLabel: 'Dance Shoes',
        ),
        PatternPowerChallenge(
          prompt: 'The fairy lights flash in patterns! Discover them '
              'all to learn the dance.',
          questionCount: 3,
          rewardLabel: 'Fairy Wings',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '8 fairies dancing + 8 more join. How many fairies?',
          options: ['15', '16', '17'],
          correctIndex: 1,
          hint: '8 and 8 — doubles!',
          rewardLabel: 'Moonlight Ribbon',
        ),
      ],
    ),

    // ── Wizard Tower ───────────────────────────────────
    Quest(
      id: 'wizard_homework',
      locationId: 'wizard_tower',
      title: "The Wizard's Homework",
      storyIntro: 'Wizard Wobble lost his homework spells! Help him '
          'solve them before magic class.',
      storyOutro: 'Wizard Wobble gets a gold star in magic class — and '
          'he says it belongs to you!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Spell 1: 11 sparks + 6 sparks. How many sparks?',
          visual: '✨',
          options: ['16', '17', '18'],
          correctIndex: 1,
          hint: 'Start at 11 and count up 6 more!',
          rewardLabel: 'Spark Spell',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Spell 2: 20 bubbles. 8 pop! How many are left?',
          options: ['11', '12', '13'],
          correctIndex: 1,
          hint: 'Take 8 away from 20!',
          rewardLabel: 'Bubble Spell',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Spell 3: which word matches the picture?',
          visual: '🪄',
          options: ['WAND', 'WIND', 'SAND'],
          correctIndex: 0,
          hint: 'A wizard waves it to cast spells!',
          rewardLabel: 'Homework Star',
        ),
      ],
    ),
    Quest(
      id: 'potion_class',
      locationId: 'wizard_tower',
      title: 'Potion Class',
      storyIntro: 'Time to brew a rainbow potion! Follow the recipe '
          'numbers exactly — no explosions, please!',
      storyOutro: 'POOF! The potion turns into a beautiful rainbow that '
          'arches over the whole tower!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The recipe needs 14 petals. We have 9. How many more?',
          visual: '🌸🌸🌸🌸🌸🌸🌸🌸🌸',
          options: ['4', '5', '6'],
          correctIndex: 1,
          hint: 'Count up from 9 to 14!',
          rewardLabel: 'Petal Pouch',
        ),
        MathDashChallenge(
          prompt: 'The potion book asks number questions! Answer them '
              'to stir the potion just right.',
          questionCount: 3,
          rewardLabel: 'Stirring Spoon',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Stir the potion: what comes next?',
          visual: '🔵 🔵 🟣 🔵 🔵 🟣 🔵 ❓',
          options: ['🔵', '🟣', '🟢'],
          correctIndex: 0,
          hint: 'Two blues, one purple — where are we in the pattern?',
          rewardLabel: 'Rainbow Vial',
        ),
      ],
    ),

    // ── Treasure Cave ──────────────────────────────────
    Quest(
      id: 'treasure_count',
      locationId: 'treasure_cave',
      title: 'The Treasure Count',
      storyIntro: 'The royal treasure needs counting before the big '
          'feast! Help the counting dragon keep track.',
      storyOutro: 'Every coin counted! The counting dragon happily '
          'stamps your treasure report.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the gold coins!',
          visual: '🪙🪙🪙🪙🪙 🪙🪙🪙🪙🪙 🪙🪙🪙',
          options: ['12', '13', '14'],
          correctIndex: 1,
          hint: 'Five, five, and three more!',
          rewardLabel: 'Coin Pouch',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '10 rubies + 9 emeralds. How many gems?',
          options: ['18', '19', '20'],
          correctIndex: 1,
          hint: '10 and 9 make...',
          rewardLabel: 'Gem Box',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🗝️',
          options: ['KEY', 'BEE', 'SEA'],
          correctIndex: 0,
          hint: 'It opens the treasure chest!',
          rewardLabel: 'Dragon Stamp',
        ),
      ],
    ),
    Quest(
      id: 'gem_sorter',
      locationId: 'treasure_cave',
      title: 'The Gem Sorting Machine',
      storyIntro: 'The gem sorting machine is jumbled! Teach it the '
          'right patterns so it sorts again.',
      storyOutro: 'Clink, clink, clink — the machine sorts every gem '
          'perfectly. You fixed it!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The sorter goes: what comes next?',
          visual: '💎 ❤️ 💎 ❤️ ❓',
          options: ['💎', '❤️', '⭐'],
          correctIndex: 0,
          hint: 'Gem, heart, gem, heart...',
          rewardLabel: 'Sorter Lever',
        ),
        PatternPowerChallenge(
          prompt: 'The machine learns by patterns! Discover them to '
              'teach it sorting.',
          questionCount: 3,
          rewardLabel: 'Machine Manual',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count by 2s: 12, 14, 16, … what comes next?',
          options: ['17', '18', '20'],
          correctIndex: 1,
          hint: 'Add 2 more to 16!',
          rewardLabel: 'Shiny Gear',
        ),
      ],
    ),

    // ── Royal Castle ───────────────────────────────────
    Quest(
      id: 'royal_feast',
      locationId: 'royal_castle',
      title: 'The Royal Feast',
      storyIntro: 'The castle is preparing a grand feast! Help the '
          'royal cooks count and share everything.',
      storyOutro: 'The feast is magnificent! The cooks give you the '
          'first slice of the giant cake.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the cupcakes!',
          visual: '🧁🧁🧁🧁 🧁🧁🧁🧁 🧁🧁🧁🧁',
          options: ['11', '12', '13'],
          correctIndex: 1,
          hint: 'Four, four, and four — count them all!',
          rewardLabel: 'Cupcake Tray',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '16 chairs at the table. 7 are taken. How many free?',
          options: ['8', '9', '10'],
          correctIndex: 1,
          hint: 'Take 7 away from 16!',
          rewardLabel: 'Royal Chair',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🎂',
          options: ['CAKE', 'LAKE', 'RAKE'],
          correctIndex: 0,
          hint: 'You eat it at birthday parties!',
          rewardLabel: 'Feast Invitation',
        ),
      ],
    ),
    Quest(
      id: 'crown_of_wisdom',
      locationId: 'royal_castle',
      title: 'The Crown of Wisdom',
      npc: QuestNpc(name: 'Queen Lumina', emoji: '👸'),
      storyIntro: 'Queen Lumina keeps the Crown of Wisdom for the '
          'kindest, cleverest heroes. Pass her four royal trials!',
      introDialogue: [
        'Welcome to my castle, dear Super Kid.',
        'I am Queen Lumina.',
        'The Crown of Wisdom waits for a true hero.',
        'Shall we begin the royal trials?',
      ],
      storyOutro: 'Queen Lumina smiles warmly. "The kingdom will sing '
          'of you, Super Kid!" Beyond the clouds, city lights blink...',
      resolutionSteps: [
        '👸 Queen Lumina reviews your four trial treasures...',
        '👑 The Crown of Wisdom sparkles on your head!',
        '🎺 The royal trumpets play your victory song!',
        '🎆 Fireworks bloom over the whole kingdom!',
        '🤖 Beyond the clouds, a robot city powers up...',
      ],
      starReward: 3,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Wisdom Trial: 12 candles + 8 candles. How many?',
          visual: '🕯️',
          options: ['19', '20', '21'],
          correctIndex: 1,
          hint: 'Start at 12 and count up 8 more!',
          rewardLabel: 'Candle Ring',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Crown Trial: what comes next?',
          visual: '👑 💎 👑 💎 💎 👑 💎 💎 💎 👑 ❓',
          options: ['💎', '👑', '🕯️'],
          correctIndex: 0,
          hint: 'One gem, two gems, three gems... then?',
          rewardLabel: 'Crown Jewel',
        ),
        MemoryChallenge(
          prompt: 'Who bowed in the throne room?',
          itemsToRemember: '🧚 🛡️ 🐴 🧙',
          options: ['🧚 🛡️ 🐴 🧙', '🧚 🐴 🛡️ 🧙', '🛡️ 🧚 🐴 🧙'],
          correctIndex: 0,
          studyPrompt: 'Remember the royal court!',
          hint: 'Pixie first, knight second — say the order out loud!',
          rewardLabel: 'Court Scroll',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Word Trial: which word matches the picture?',
          visual: '👸',
          options: ['QUEEN', 'GREEN', 'QUIET'],
          correctIndex: 0,
          hint: 'She rules the kingdom with the king!',
          rewardLabel: 'Crown of Wisdom',
        ),
      ],
    ),
  ];
}
