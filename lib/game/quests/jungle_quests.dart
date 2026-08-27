import '../models/quest.dart';

/// All Jungle Adventure quest content — data only, no UI. Two quests per
/// location (the Jungle Temple adds a third: the world-boss quest),
/// 3 challenges each (4 for the boss), aimed at Class 2 / age ~7
/// (addition and subtraction within 20, simple patterns and sequences,
/// picture words).
///
/// Star economy: each quest's base reward is 2 stars (a perfect run
/// earns a bonus — see QuestRewardService), and every location's
/// threshold is coverable from base rewards alone — verified by
/// `jungle_quests_test.dart`.
class JungleQuests {
  JungleQuests._();

  static List<Quest> forLocation(String locationId) =>
      all.where((quest) => quest.locationId == locationId).toList();

  static const List<Quest> all = [
    // ── Tree House ─────────────────────────────────────
    Quest(
      id: 'jungle_bridge_repair',
      locationId: 'tree_house',
      title: 'Repair the Jungle Bridge',
      npc: QuestNpc(name: 'Momo the Monkey', emoji: '🐒'),
      storyIntro: 'Oh no! The jungle bridge is broken and a baby monkey is '
          'stuck on the other side. Collect the parts to fix it!',
      introDialogue: [
        'Uh-oh!',
        'The jungle bridge is broken!',
        'A little animal is stuck on the other side.',
        'Can you help repair the bridge, Super Kid?',
      ],
      storyOutro: 'You repaired the jungle bridge! The baby monkey runs '
          'across and gives you a big hug. Hooray!',
      resolutionSteps: [
        '🦸 You arrive at the broken bridge...',
        '🧩 Your bridge pieces float into place!',
        '🔧 The repair tool tightens everything up!',
        '🌉 The bridge is fixed!',
        '🐒 The baby monkey scampers across safely!',
        '🎊 The whole jungle cheers for you, Super Kid!',
      ],
      starReward: 2,
      challenges: [
        MathDashChallenge(
          prompt: 'The monkey needs bananas for the jungle camp! '
              'Solve the number puzzles to earn the first bridge piece.',
          questionCount: 3,
          rewardLabel: 'Bridge Piece #1',
        ),
        MemoryMasterChallenge(
          prompt: 'The jungle friends are hiding! Remember who you see '
              'to earn the repair tool.',
          questionCount: 3,
          rewardLabel: 'Repair Tool',
        ),
        PatternPowerChallenge(
          prompt: 'The bridge has a magical lock! It only opens when you '
              'discover its patterns.',
          questionCount: 3,
          rewardLabel: 'Bridge Piece #2',
        ),
      ],
    ),
    Quest(
      id: 'treehouse_ladder',
      locationId: 'tree_house',
      title: 'The Treehouse Ladder',
      storyIntro: 'The ladder to the treehouse lost some rungs! '
          'Help build new ones so we can climb up.',
      storyOutro: 'The ladder is fixed! You climb up and can see the '
          'whole jungle from the top!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '3 rungs + 4 rungs. How many rungs in all?',
          visual: '🪜',
          options: ['6', '7', '8'],
          correctIndex: 1,
          rewardLabel: 'New Rung',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '⭐ 🌙 ⭐ 🌙 ❓',
          options: ['🌙', '☀️', '⭐'],
          correctIndex: 2,
          rewardLabel: 'Strong Rope',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🐱',
          options: ['CAT', 'BAT', 'HAT'],
          correctIndex: 0,
          rewardLabel: 'Golden Nail',
        ),
      ],
    ),

    // ── Monkey Camp ────────────────────────────────────
    Quest(
      id: 'banana_breakfast',
      locationId: 'monkey_camp',
      title: 'Banana Breakfast',
      storyIntro: 'The monkeys are hungry! '
          'Help share the bananas for breakfast.',
      storyOutro: 'Yum! Every monkey got a banana. '
          'They cheer and do a happy dance!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'There are 10 bananas. The monkeys eat 4. '
              'How many are left?',
          visual: '🍌🍌🍌🍌🍌🍌🍌🍌🍌🍌',
          options: ['5', '6', '7'],
          correctIndex: 1,
          rewardLabel: 'Banana Basket',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🍌 🍃 🍌 🍃 ❓',
          options: ['🍃', '🍌', '🥥'],
          correctIndex: 1,
          rewardLabel: 'Leaf Plate',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the monkeys!',
          visual: '🐒🐒🐒🐒🐒',
          options: ['4', '5', '6'],
          correctIndex: 1,
          rewardLabel: 'Breakfast Bell',
        ),
      ],
    ),
    Quest(
      id: 'lost_drum',
      locationId: 'monkey_camp',
      title: 'The Lost Drum',
      storyIntro: 'The camp drum is lost! Follow the clues to find it '
          'before the jungle party starts.',
      storyOutro: 'Boom boom! You found the drum and the jungle party '
          'begins!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'What number comes next? 2, 4, 6, …',
          options: ['7', '8', '9'],
          correctIndex: 1,
          rewardLabel: 'First Clue',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🥁',
          options: ['DRUM', 'DOOR', 'DUCK'],
          correctIndex: 0,
          rewardLabel: 'Second Clue',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is bigger?',
          options: ['7', '9'],
          correctIndex: 1,
          rewardLabel: 'Drum Sticks',
        ),
      ],
    ),

    // ── Waterfall ──────────────────────────────────────
    Quest(
      id: 'rainbow_mist',
      locationId: 'waterfall',
      title: 'Rainbow Mist',
      storyIntro: 'A rainbow hides in the waterfall mist! '
          'Solve the water puzzles to make it appear.',
      storyOutro: 'Whoosh! A big beautiful rainbow appears over the '
          'waterfall!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the fish!',
          visual: '🐟🐟🐟🐟🐟🐟🐟',
          options: ['6', '7', '8'],
          correctIndex: 1,
          rewardLabel: 'Blue Drop',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🔴 🟡 🔵 🔴 🟡 ❓',
          options: ['🔵', '🔴', '🟡'],
          correctIndex: 0,
          rewardLabel: 'Yellow Drop',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '5 drops + 5 drops. How many?',
          visual: '💧💧💧💧💧 💧💧💧💧💧',
          options: ['9', '10', '11'],
          correctIndex: 1,
          rewardLabel: 'Red Drop',
        ),
      ],
    ),
    Quest(
      id: 'slippery_stones',
      locationId: 'waterfall',
      title: 'The Slippery Stones',
      storyIntro: 'The stepping stones are slippery! Put them in the '
          'right order to cross the stream.',
      storyOutro: 'Hop hop hop! You crossed the stream without getting '
          'wet!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is missing? 1, 2, 3, ❓, 5',
          options: ['4', '6', '7'],
          correctIndex: 0,
          rewardLabel: 'Stone 1',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'There are 12 stones. 2 wash away. How many are left?',
          options: ['9', '10', '11'],
          correctIndex: 1,
          rewardLabel: 'Stone 2',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🐸',
          options: ['FROG', 'FLAG', 'FOG'],
          correctIndex: 0,
          rewardLabel: 'Stone 3',
        ),
      ],
    ),

    // ── Lion Cave ──────────────────────────────────────
    Quest(
      id: 'sleepy_lion_snack',
      locationId: 'lion_cave',
      title: "The Sleepy Lion's Snack",
      storyIntro: 'The friendly lion is hungry after his long nap. '
          'Help make his favorite fruit snack!',
      storyOutro: 'The lion munches happily and purrs a big thank-you '
          'roar!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '6 berries + 3 berries. How many?',
          visual: '🫐🫐🫐🫐🫐🫐 🫐🫐🫐',
          options: ['8', '9', '10'],
          correctIndex: 1,
          rewardLabel: 'Fruit Bowl',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which plate has more mangoes?',
          visual: '🥭',
          options: ['8 mangoes', '6 mangoes'],
          correctIndex: 0,
          rewardLabel: 'Honey Jar',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🦁 🐾 🐾 🦁 🐾 🐾 🦁 ❓',
          options: ['🦁', '🐾', '🌿'],
          correctIndex: 1,
          rewardLabel: 'Cozy Blanket',
        ),
      ],
    ),
    Quest(
      id: 'echo_echo',
      locationId: 'lion_cave',
      title: 'Echo Echo',
      storyIntro: 'The cave is full of echoes! Solve the echo riddles '
          'to find the shiny crystal.',
      storyOutro: 'Sparkle! You found the crystal and the whole cave '
          'lights up!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the bats!',
          visual: '🦇🦇🦇🦇🦇🦇🦇🦇',
          options: ['7', '8', '9'],
          correctIndex: 1,
          rewardLabel: 'Echo Map',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'There are 14 water drips. 4 stop. How many are left?',
          options: ['10', '11', '12'],
          correctIndex: 0,
          rewardLabel: 'Torch',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🦁',
          options: ['LION', 'LEMON', 'LINE'],
          correctIndex: 0,
          rewardLabel: 'Shiny Crystal',
        ),
      ],
    ),

    // ── Mountain ───────────────────────────────────────
    Quest(
      id: 'eagle_delivery',
      locationId: 'mountain',
      title: "The Eagle's Delivery",
      npc: QuestNpc(name: 'Ela the Eagle', emoji: '🦅'),
      storyIntro: 'Ela the Eagle must deliver berries to the mountain top, '
          'but the wind mixed up her baskets! Help her sort them out.',
      storyOutro: 'Ela soars to the top and delivers every basket. '
          'She gives you a feather of honor!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Ela has 9 berries. She delivers 4. How many are left?',
          visual: '🫐🫐🫐🫐🫐🫐🫐🫐🫐',
          options: ['4', '5', '6'],
          correctIndex: 1,
          hint: 'Count all 9, then take 4 away!',
          rewardLabel: 'Berry Basket',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🦅 ⛰️ ⛰️ 🦅 ⛰️ ⛰️ 🦅 ❓',
          options: ['⛰️', '🦅', '🌲'],
          correctIndex: 0,
          hint: 'Eagle, mountain, mountain — say it out loud!',
          rewardLabel: 'Wind Map',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🦅',
          options: ['EAGLE', 'APPLE', 'ANGLE'],
          correctIndex: 0,
          hint: 'It starts with E and flies high!',
          rewardLabel: 'Feather of Honor',
        ),
      ],
    ),
    Quest(
      id: 'snowy_summit',
      locationId: 'mountain',
      title: 'The Snowy Summit',
      npc: QuestNpc(name: 'Ela the Eagle', emoji: '🦅'),
      storyIntro: 'The path to the snowy summit is hidden! Solve the '
          'mountain puzzles to find the way up.',
      storyOutro: 'You reach the summit and see the whole jungle below. '
          'What a view, Super Kid!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the snowflakes!',
          visual: '❄️❄️❄️ ❄️❄️❄️ ❄️❄️',
          options: ['7', '8', '9'],
          correctIndex: 1,
          hint: 'Count them one by one — go slowly!',
          rewardLabel: 'Snow Boots',
        ),
        MathDashChallenge(
          prompt: 'The mountain steps are numbered! Solve the number '
              'puzzles to climb higher.',
          questionCount: 3,
          rewardLabel: 'Climbing Rope',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is bigger?',
          options: ['14', '11'],
          correctIndex: 0,
          hint: 'Count up — which comes later?',
          rewardLabel: 'Summit Flag',
        ),
      ],
    ),

    // ── Jungle Temple ──────────────────────────────────
    Quest(
      id: 'temple_door_code',
      locationId: 'jungle_temple',
      title: 'The Temple Door Code',
      storyIntro: 'The old temple door is locked with a puzzle code! '
          'Crack it to peek inside.',
      storyOutro: 'Click! The great door slides open. The temple is '
          'full of friendly fireflies!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'What number comes next? 5, 10, 15, …',
          options: ['18', '20', '25'],
          correctIndex: 1,
          rewardLabel: 'Code Stone 1',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🔺 🔻 🔺 🔻 ❓',
          options: ['🔻', '🔺', '⭕'],
          correctIndex: 1,
          rewardLabel: 'Code Stone 2',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '9 fireflies + 6 fireflies. How many?',
          options: ['14', '15', '16'],
          correctIndex: 1,
          rewardLabel: 'Code Stone 3',
        ),
      ],
    ),
    Quest(
      id: 'golden_star',
      locationId: 'jungle_temple',
      title: 'The Golden Star',
      storyIntro: 'Legends say a golden star sleeps inside the temple. '
          'Solve the final riddles to wake it up!',
      storyOutro: 'The golden star floats up and shines over the whole '
          'jungle. You are a true Super Kid!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '10 coins + 7 coins. How many?',
          options: ['16', '17', '18'],
          correctIndex: 1,
          rewardLabel: 'Star Key',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '⭐',
          options: ['STAR', 'STIR', 'SEAT'],
          correctIndex: 0,
          rewardLabel: 'Star Song',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is bigger?',
          options: ['15', '12'],
          correctIndex: 0,
          rewardLabel: 'Star Light',
        ),
      ],
    ),
    Quest(
      id: 'jungle_guardian',
      locationId: 'jungle_temple',
      title: 'The Jungle Guardian',
      npc: QuestNpc(name: 'Raja the Guardian Tiger', emoji: '🐯'),
      storyIntro: 'Raja the Guardian Tiger protects the jungle. Pass his '
          'four great trials to become a Guardian of the Jungle too!',
      introDialogue: [
        'Welcome, brave Super Kid.',
        'I am Raja, guardian of this jungle.',
        'Only a true hero can pass my four trials.',
        'Are you ready to become a Guardian too?',
      ],
      storyOutro: 'Raja bows his great head. "You did it, Super Kid! The '
          'jungle will always be your friend." A new world appears on the '
          'horizon...',
      resolutionSteps: [
        '🐯 Raja watches you finish the last trial...',
        '🏅 The Guardian Medal glows on your chest!',
        '🌴 All the jungle animals gather around you!',
        '🎆 Fireworks of fireflies light up the sky!',
        '🚀 Far away, a rocket blinks — a new adventure is calling!',
      ],
      starReward: 3,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Trial of Numbers: 8 drums + 7 drums. How many drums?',
          visual: '🥁',
          options: ['14', '15', '16'],
          correctIndex: 1,
          hint: 'Start at 8 and count up 7 more!',
          rewardLabel: 'Drum of Courage',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Trial of Patterns: what comes next?',
          visual: '🐯 🌴 🐯 🌴 🌴 🐯 🌴 🌴 🌴 🐯 ❓',
          options: ['🌴', '🐯', '⭐'],
          correctIndex: 0,
          hint: 'One palm, two palms, three palms... then?',
          rewardLabel: 'Pattern Paw',
        ),
        MemoryChallenge(
          prompt: 'Who marched past the temple?',
          itemsToRemember: '🐒 🦁 🦅 🐘',
          options: ['🐒 🦁 🦅 🐘', '🐒 🦁 🐘 🦅', '🦁 🐒 🦅 🐘'],
          correctIndex: 0,
          hint: 'Say their order out loud: monkey, lion, eagle, elephant!',
          rewardLabel: 'Memory Gem',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Trial of Words: which word matches the picture?',
          visual: '🐯',
          options: ['TIGER', 'TOWER', 'TIRE'],
          correctIndex: 0,
          hint: 'It starts with TI and roars!',
          rewardLabel: 'Guardian Medal',
        ),
      ],
    ),
  ];
}
