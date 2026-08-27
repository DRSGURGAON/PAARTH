import '../models/quest.dart';

/// World 3 — Dino Island quest content. Data only, no UI. Two quests
/// per location (the Ancient Temple's second quest is the world boss),
/// Class 2 / age ~7 difficulty: addition and subtraction within 20,
/// simple patterns, picture words.
class DinoQuests {
  DinoQuests._();

  static const List<Quest> all = [
    // ── Dino Camp ──────────────────────────────────────
    Quest(
      id: 'dino_breakfast',
      locationId: 'dino_camp',
      title: 'Dino Breakfast Time',
      npc: QuestNpc(name: 'Tara the Triceratops', emoji: '🦕'),
      storyIntro: 'Tara the Triceratops is serving leafy breakfast to '
          'the little dinos! Help her share it fairly.',
      introDialogue: [
        'Good morning, Super Kid!',
        'The little dinos are SO hungry.',
        'But my leaf piles are all mixed up!',
        'Will you help me serve breakfast?',
      ],
      storyOutro: 'Every little dino munches happily. Tara stomps a '
          'gentle thank-you dance!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the breakfast leaves!',
          visual: '🍃🍃🍃🍃 🍃🍃🍃🍃',
          options: ['7', '8', '9'],
          correctIndex: 1,
          hint: 'Four and four more!',
          rewardLabel: 'Leaf Plate',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '12 leaves. The dinos eat 5. How many are left?',
          options: ['6', '7', '8'],
          correctIndex: 1,
          hint: 'Take 5 away from 12!',
          rewardLabel: 'Berry Bowl',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🥚',
          options: ['EGG', 'LEG', 'BAG'],
          correctIndex: 0,
          hint: 'Baby dinos hatch from it!',
          rewardLabel: 'Breakfast Bell',
        ),
      ],
    ),
    Quest(
      id: 'footprint_trail',
      locationId: 'dino_camp',
      title: 'The Footprint Trail',
      storyIntro: 'Giant footprints lead into the ferns! Follow the '
          'trail by solving its puzzles.',
      storyOutro: 'The trail leads to a friendly brachiosaurus who '
          'lifts you up for the best view ever!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🐾 🐾 🌿 🐾 🐾 🌿 🐾 🐾 ❓',
          options: ['🌿', '🐾', '🦴'],
          correctIndex: 0,
          hint: 'Two footprints, one fern — again and again!',
          rewardLabel: 'Trail Map',
        ),
        MathDashChallenge(
          prompt: 'Each footprint hides a number puzzle! Solve them to '
              'follow the trail.',
          questionCount: 3,
          rewardLabel: 'Explorer Hat',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count by 5s: 5, 10, 15, … what comes next?',
          options: ['16', '20', '25'],
          correctIndex: 1,
          hint: 'Add 5 more to 15!',
          rewardLabel: 'Binoculars',
        ),
      ],
    ),

    // ── Fossil Valley ──────────────────────────────────
    Quest(
      id: 'fossil_hunt',
      locationId: 'fossil_valley',
      title: 'The Great Fossil Hunt',
      storyIntro: 'Fossil Valley is full of buried treasures! Dig '
          'carefully and count what you find.',
      storyOutro: 'What a haul! The museum tent gives you a shiny '
          'Fossil Finder badge.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the fossils you dug up!',
          visual: '🦴🦴🦴 🦴🦴🦴 🦴🦴🦴 🦴',
          options: ['9', '10', '11'],
          correctIndex: 1,
          hint: 'Three, three, three, and one more!',
          rewardLabel: 'Digging Brush',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '6 shells + 7 bones. How many fossils in all?',
          options: ['12', '13', '14'],
          correctIndex: 1,
          hint: 'Start at 7 and count up 6 more!',
          rewardLabel: 'Fossil Crate',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🦴',
          options: ['BONE', 'CONE', 'PHONE'],
          correctIndex: 0,
          hint: 'Dogs love to chew on it!',
          rewardLabel: 'Finder Badge',
        ),
      ],
    ),
    Quest(
      id: 'bone_puzzle',
      locationId: 'fossil_valley',
      title: 'The Big Bone Puzzle',
      storyIntro: 'The museum tent found a mixed-up dino skeleton! Use '
          'pattern power to put it back together.',
      storyOutro: 'The skeleton stands tall and proud. You built a '
          'whole dinosaur!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The tail bones go: big, small, big, small. What next?',
          visual: '🦴 🦷 🦴 🦷 🦴 ❓',
          options: ['🦷', '🦴', '🥚'],
          correctIndex: 0,
          hint: 'Big bone, small bone, big bone...',
          rewardLabel: 'Tail Piece',
        ),
        PatternPowerChallenge(
          prompt: 'The skeleton chart is full of patterns! Discover '
              'them to place every bone.',
          questionCount: 3,
          rewardLabel: 'Rib Cage',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The neck needs 11 bones. We placed 8. How many more?',
          options: ['2', '3', '4'],
          correctIndex: 1,
          hint: 'Count up from 8 to 11!',
          rewardLabel: 'Dino Skull',
        ),
      ],
    ),

    // ── Volcano ────────────────────────────────────────
    Quest(
      id: 'volcano_rumble',
      locationId: 'volcano',
      title: 'The Volcano Rumble',
      storyIntro: 'The volcano is rumbling! Count the smoke puffs and '
          'warn the dinos in time.',
      storyOutro: 'Every dino reaches the safe meadow before the big '
          'sneeze of smoke. Phew — well done!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the smoke puffs!',
          visual: '💨💨💨💨💨 💨💨💨💨💨 💨💨',
          options: ['11', '12', '13'],
          correctIndex: 1,
          hint: 'Five, five, and two more!',
          rewardLabel: 'Warning Horn',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '15 dinos in the valley. 9 reached safety. '
              'How many still need help?',
          options: ['5', '6', '7'],
          correctIndex: 1,
          hint: 'Take 9 away from 15!',
          rewardLabel: 'Rescue Rope',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The rumble goes: what comes next?',
          visual: '💥 💨 💨 💥 💨 💨 💥 ❓',
          options: ['💨', '💥', '🌋'],
          correctIndex: 0,
          hint: 'One boom, two puffs — one boom, two puffs!',
          rewardLabel: 'Safety Flag',
        ),
      ],
    ),
    Quest(
      id: 'lava_stepping_stones',
      locationId: 'volcano',
      title: 'Lava Stepping Stones',
      storyIntro: 'Cooled lava stones make a path across the slope — '
          'but only the numbered ones are safe!',
      storyOutro: 'Hop, hop, hop — you crossed the whole slope without '
          'a single wobble!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'The safe stones count by 10s: 10, 20, … what next?',
          options: ['25', '30', '40'],
          correctIndex: 1,
          hint: 'Add 10 more to 20!',
          rewardLabel: 'Heat Boots',
        ),
        MathDashChallenge(
          prompt: 'Each stepping stone shows a number puzzle! Solve '
              'them to hop across safely.',
          questionCount: 3,
          rewardLabel: 'Lava Lantern',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Which number is smaller?',
          options: ['16', '12'],
          correctIndex: 1,
          hint: 'Which comes first when you count up?',
          rewardLabel: 'Cool Stone',
        ),
      ],
    ),

    // ── Dino Nest ──────────────────────────────────────
    Quest(
      id: 'egg_patrol',
      locationId: 'dino_nest',
      title: 'Egg Patrol',
      storyIntro: 'The dino mums asked you to watch the nests! Count '
          'the eggs and keep them cozy.',
      storyOutro: 'Crack, crack! Three eggs hatch while you watch. The '
          'babies think YOU are their hero!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Count the eggs in the nests!',
          visual: '🥚🥚🥚🥚🥚 🥚🥚🥚🥚🥚 🥚🥚🥚🥚',
          options: ['13', '14', '15'],
          correctIndex: 1,
          hint: 'Five, five, and four more!',
          rewardLabel: 'Cozy Straw',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '14 eggs. 6 hatch into babies. How many eggs are left?',
          options: ['7', '8', '9'],
          correctIndex: 1,
          hint: 'Take 6 away from 14!',
          rewardLabel: 'Egg Blanket',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🐣',
          options: ['BABY', 'BOOK', 'BALL'],
          correctIndex: 0,
          hint: 'A tiny new dino is a...',
          rewardLabel: 'Patrol Badge',
        ),
      ],
    ),
    Quest(
      id: 'lullaby_patterns',
      locationId: 'dino_nest',
      title: 'The Dino Lullaby',
      storyIntro: 'The baby dinos cannot sleep! Sing the lullaby '
          'patterns to help them doze off.',
      storyOutro: 'Zzz... every baby dino is fast asleep, hugging your '
          'lullaby in their dreams.',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'The lullaby goes: what comes next?',
          visual: '🎵 🎵 🌙 🎵 🎵 🌙 🎵 🎵 ❓',
          options: ['🌙', '🎵', '⭐'],
          correctIndex: 0,
          hint: 'Two notes, one moon — two notes, one moon!',
          rewardLabel: 'Soft Drum',
        ),
        PatternPowerChallenge(
          prompt: 'The lullaby is made of gentle patterns! Discover '
              'them to sing it right.',
          questionCount: 3,
          rewardLabel: 'Dream Feather',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: '10 babies sleeping + 4 more doze off. How many asleep?',
          options: ['13', '14', '15'],
          correctIndex: 1,
          hint: '10 and 4 make...',
          rewardLabel: 'Night Light',
        ),
      ],
    ),

    // ── Ancient Temple ─────────────────────────────────
    Quest(
      id: 'temple_of_claws',
      locationId: 'ancient_temple',
      title: 'The Temple of Claws',
      storyIntro: 'The ancient dino temple is carved with claw riddles! '
          'Solve them to open the stone gate.',
      storyOutro: 'The stone gate rumbles open. Inside, golden dino '
          'statues sparkle in the torchlight!',
      starReward: 2,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'What number comes next? 4, 8, 12, …',
          options: ['14', '16', '20'],
          correctIndex: 1,
          hint: 'Add 4 more to 12!',
          rewardLabel: 'Claw Key 1',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'What comes next?',
          visual: '🦖 🦕 🦕 🦖 🦕 🦕 🦖 ❓',
          options: ['🦕', '🦖', '🐊'],
          correctIndex: 0,
          hint: 'One rex, two long-necks — again and again!',
          rewardLabel: 'Claw Key 2',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Which word matches the picture?',
          visual: '🚪',
          options: ['DOOR', 'DEER', 'DEAR'],
          correctIndex: 0,
          hint: 'You knock on it to come in!',
          rewardLabel: 'Claw Key 3',
        ),
      ],
    ),
    Quest(
      id: 'dino_king',
      locationId: 'ancient_temple',
      title: 'The Dino King',
      npc: QuestNpc(name: 'Rex the Gentle King', emoji: '🦖'),
      storyIntro: 'Rex the Gentle King rules Dino Island. Pass his four '
          'royal trials to earn the Dino Crown!',
      introDialogue: [
        'ROAR... oh, pardon me. Hello, Super Kid!',
        'I am Rex, king of Dino Island.',
        'My four royal trials await you.',
        'Show me a hero\'s heart!',
      ],
      storyOutro: 'Rex roars a happy roar! "Dino Island salutes you, '
          'Super Kid!" Across the sea, castle towers sparkle...',
      resolutionSteps: [
        '🦖 Rex inspects your four trial treasures...',
        '👑 The Dino Crown is placed on your head!',
        '🦕 Every dino on the island stomps a happy beat!',
        '🌋 Even the volcano puffs a smoke heart!',
        '🏰 Far across the sea, a magic castle glitters...',
      ],
      starReward: 3,
      challenges: [
        ChoiceChallenge(
          category: ChallengeCategory.math,
          prompt: 'Royal Trial: 7 gems + 9 gems. How many gems?',
          visual: '💎',
          options: ['15', '16', '17'],
          correctIndex: 1,
          hint: 'Start at 9 and count up 7 more!',
          rewardLabel: 'Royal Gems',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.logic,
          prompt: 'Stomp Trial: what comes next?',
          visual: '🦶 🦶 💥 🦶 🦶 💥 🦶 🦶 ❓',
          options: ['💥', '🦶', '🦖'],
          correctIndex: 0,
          hint: 'Stomp, stomp, BOOM — stomp, stomp, BOOM!',
          rewardLabel: 'Stomp Drum',
        ),
        MemoryChallenge(
          prompt: 'Who marched in the royal parade?',
          itemsToRemember: '🦖 🦕 🐊 🐢',
          options: ['🦖 🦕 🐊 🐢', '🦖 🐊 🦕 🐢', '🦕 🦖 🐊 🐢'],
          correctIndex: 0,
          studyPrompt: 'Remember the royal parade!',
          hint: 'Rex leads the parade — say the order out loud!',
          rewardLabel: 'Parade Flag',
        ),
        ChoiceChallenge(
          category: ChallengeCategory.english,
          prompt: 'Word Trial: which word matches the picture?',
          visual: '👑',
          options: ['CROWN', 'CLOWN', 'BROWN'],
          correctIndex: 0,
          hint: 'A king wears it on his head!',
          rewardLabel: 'Dino Crown',
        ),
      ],
    ),
  ];
}
